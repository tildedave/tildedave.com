---
layout: post
title: "A Perl Skeptic's Guide to Perl"
---

The original version of Tilt was built in Perl, which always tends to get a reaction from people.  "Perl?  I used that back in the 90s for CGI scripts!" or something along those lines.  Four years into the company (YC 2012) our API code is still primarily written in Perl.  I'm not sure that odd language choices are really *that* unusual in young business.  Our CTO wrote an [article](http://web.archive.org/web/20120914031745/http://dsog.info/blog/Perl/Hacking/Technology/2012/08/31/why-did-i-choose-perl-for-crowdtilt/) talking about the choice - at an early stage startup I think the technology choice usually comes down to what language the early engineers know really well, as the main point is moving really fast as the business changes around you.

Perl was the first language I really learned outside of BASIC and what I was learning in school (more traditional languages like Java and C++).  I used Perl to convert a bunch of awful Microsoft Word-generated HTML into slightly cleaner HTML for my old Planescape fan site and I loved how easy it was to open a file, run strings through a regular expression, and output it again.  (I remember same operation to be particularly awful in Java.)  In 1999, I remember the old Perl book was a sort of status symbol among the nerd crew at school.  Back then Perl was part of the curriculum - it was just something you were going to learn if you were programming, similar to then-more traditional languages like Java and C++.

Unfortunately the freedom of old-school Perl seems to have resulted in a lot of programmer fatigue around maintaining someone else's thousand line Perl script.  Talking to people about our current codebase, I always have to add a bunch of caveats: no, it's not hacked up CGI scripts, yes, we have tests ... it's basically Python in a camel costume.  The Perl community and the "[Modern Perl](http://onyxneon.com/books/modern_perl/)" movement found a beautiful subset of the language, added libraries to support basic things like function arguments (named and unnamed), dynamic type checking, and way less `@_` gibberish.

For example, here's a function I wrote that converts the cents string "100" (currency major unit) into the dollar string "1.00" (currency minor unit).  `fun` syntax is provided by the `Function::Parameters` module and argument typing is provided by `Moose::Util::TypeConstraints`.

```perl
fun to_dollars(Str $value) {
    # NOTE(davek): we intentionally avoid math here
    $value = sprintf('%03d', $value);
    $value =~ s/(.{2})$/.$1/;

    return $value;
}
```

This is a pretty straightforward function, but it has some "new" things - `fun` means we can give our subroutines implicitly bound variables (rather than shifting them off the `@_` array as in ye olden days), `Str` will do a runtime check of `$value` to make sure it's actually a string when passed in, and so give you a better error message if you ended up passing in an integer ... or nothing.  The rest of the function is a pretty standard transformation where you turn the string into a left-padded 0 string of at least 3 digits, take the last two characters in the string and add a "." before them.  I imagine this would look similar in most any language.

## Diving into Perl

However, you can also end up with stuff like this, where we need to take a list of user uuids from the client and rewrite them internally to numeric ids so they can access into one of our auto-increment ID tables through a foreign key relationship (group members has an foreign key by ID on the users table).  I'm also to blame for this one.

```perl
fun _rewrite_uuids_to_ids(ArrayRef $members) {
    # filter out specified members that aren't users because we don't care about
    # them right now
    my @member_uuids = map $_->{user_id}, grep $_->{user_id}, @$members;

    my $user_id_rs = app->tilt_db->rset('User')->search(
        { 'me.uuid' => { -in => \@member_uuids } },
        { columns => [ qw/uuid id/ ] }
    );

    my %member_uuid_to_ids = map { $_->uuid => $_->id } $user_id_rs->all;

    # convert member uuids (strings) into member ids (integers)
    # the owner is already in the $members list as an number so we don't need
    # to convert that one
    for my $member (@$members) {
        next if !$member->{user_id} || is_int $member->{user_id};

        my $user_id = $member_uuid_to_ids{$member->{user_id}};

        die exc 400 => ERR_ID_NO_SUCH_USER_WITH_ID,
            "No such user $member->{user_id} to add to group"
            unless $user_id;

        $member->{user_id} = $user_id;
    }
}
```

Obviously this function is doing something kind of complicated, but even beyond what it's doing something certainly doesn't feel _right_ about it.  Some of it is that our ORM uses keywords like `-in` as hash keys to stand in for a SQL clause, some of it is how language keywords and built-in functions just float next to each other, and there are those `$` and `@` symbols floating throughout.  I'll pick out one particularly odd line that's our idiomatic way to raise an exception from bad user data:

```perl
die exc 400 => ERR_ID_NO_SUCH_USER_WITH_ID,
  "No such user $member->{user_id} to add to group"
  unless $user_id;
```

* `die` is a built-in function ... but to give you a sense of my certainty I double-checked this on Google.
* `exc` is our own function that we load into the global namespace and do not explicitly import anywhere in the file (this tends to be confusing).
* `ERR_ID_NO_SUCH_USER_WITH_ID` is a constant we load into the global namespace through reading a config file that lists out our error codes.
* What's the string "No such user" associated with?  The `die` or the `exc`, or is it something else?  The line _reads_ well, but what's actually happening?

Even the little gem `[ qw/uuid id/ ]` is a bit confusing - what is that?  Well, it's a reference to the list of two strings `'uuid'` and `'id'`.  This differs from  `qw/uuid id/` which is the list itself, which is a fancy way of writing `('uuid', 'id')`.  The reason to put this list in square brackets `[ ]` is because the library that we're for our ORM using expects its arguments to be in scalar context.

Languages that replaced Perl in the "hacker community" like Python and Ruby just got rid of the reference/value dichotomy and we pass the references to these complicated data-structures around as values.  Ruby doesn't need to have variables like `$item` and `@list` because the syntactic forms for lists just take scalars.  I think the justification for having different contexts was primarily a linguistic one - it may read better, but if I'm calling `include?` on a variable in a Ruby script it's pretty obvious to me that it's an array of some kind (or else it's gonna blow up when I run it!).

## Something Nice About List Context

There's one thing about list context that I really like - the ability to seamlessly extract named arguments you use in multiple places into an argument that returns list context, which is then passed into other functions.  Here's some code where we format a number of very similar messages around interactions with a user's comment - each of them needs the same arguments to link to the comment.

```perl
my $formatter = Tilt::Formatters::NotificationCenter->new;

# "Posted a photo" message
$results->{data}  = $formatter->comment_photo(
    _comment_args($comment),
    user_name      => $comment->user->full_name,
    locale         => $message->receiver->locale_string,
);

# "Replied to your comment message"
$results->{data} = $formatter->comment_replied(
    _comment_args($comment),
    user_names    => \@user_names,
    locale        => $message->receiver->locale_string,
);

# "Liked your comment message"
$results->{data} = $formatter->comment_replied(
    _comment_args($comment),
    user_names    => \@user_names,
    total_likes   => $total_likes,
    locale        => $message->receiver->locale_string,
);

fun _comment_args(Comment $comment) {
    return (
        comment_uuid  => (
            $comment->is_reply ? $comment->parent->uuid : $comment->uuid
        ),
        comment_body  => $comment->body,
    );
}
```

Since `_comment_args` is returned in list context, you can just include it in the list of the argments to the `comment_replied` and `comment_photo` functions, and those functions will pick up the same arguments.  Of course, Python can do this with `**` and `**kwargs* if you manually combine the dictionaries that you're passing in ... but isn't it nicer to just pass it in as argument?  So there's at least one point in favor of list context.

(How this works internally is kind of cool ... if the method signature is `f(Int :$a, :$b)` (named arguments `a` and `b`) the function call `f(a => 1, b => 2)` becomes `f('a', 1, 'b', 2)` and then `Function::Parameters` matches up the string arguments to the keys in the function's method signature to assign values to the variables.)

## Looking Back

The nerd community of my undergraduate days was weirder and rougher around the edges.  I spent a lot of time programming in MUSHCode, a lispy sort of language that was used to do various things on PennMUSH servers (text-based roleplaying before MMOs really took on).  My friends programmed in C++ and OpenGL.  There was a higher barrier to entry - it felt like we were part of a secret group of people who knew how to program.  I remember switching from Internet Explorer to Firefox and installing Red Hat Linux.  My box ended up getting owned and port-scanning the internet ... so I had to walk across campus after a snowstorm to find the network guy and convince him that I should be allowed to have my internet back.  WiFi didn't exist.  I wasn't sure what my career would end up being - I talked to some IBM recruiters but it felt weird to imagine living in upstate New York.  I ended up getting a dual degree in math because I was interested in it, took some courses in logic and set theory, did a lot of Scheme programming, and went to graduate school.

While the Perl language is the same, at some point how we evaluated technologies changed.  CPAN was one of the first centralized library systems in a day where getting the right binaries and headers installed was a nightmare (no default apt sources!), but at some point being first just wasn't enough.  Perl worked really well at string processing, but then so did Python, and you got a lot more out of the box ("batteries included") instead of needing to pull in libraries to support try/catch constructs (a real thing you need to do).  It wasn't enough to work, it had to be really simple to get started, and it had to be really simple to learn.  The less concepts you had to explain the better.  Development today is so easy - you can build real things very quickly using frameworks like Rails, and it's easy to get started on these technologies for anyone with an internet connection.  It's an objectively better world to be a programmer in, especially if you're looking to accomplish a task or build a business.

Still, I can't quite bring myself to hate the language, as frustrating as it can be when I've messed up the difference between and array and an array ref for the third time that hour.  Perl's always been a little weird, and the language always pushes me to be a little better, to think a little more about every line that I'm writing, to try to turn six kind of mindless lines into three much more concise ones.  It's almost fun to sit back and think about the 1999 various of Dave and what he'd think about the situation - fifteen years have past and the programming world's completely different, but Perl's still this little spot that keeps that old and strange culture of my undergraduate days alive.