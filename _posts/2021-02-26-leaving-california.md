---
layout: post
title: "Leaving California"
comments: true
---

I moved to California in the fall of 2014.  The main reason I moved here was that I felt like I wanted different experiences than I could get in a small college town, the kind of place I had lived for most of my life up until then.  I wanted work that was more challenging, I wanted a place that I could engage more deeply with, and I wanted some sense of longer-term purpose.

Six years later I would give myself a mixed grade.  I got more challenging work but it came at the cost of some incredibly high stress years and I ended up burning myself out.  Even today, I'm not sure how to measure how "okay" I am.  I've certainly found enjoyment in work again, and I still love to program (yay!).

If you've never lived in the San Francisco Bay Area, it's hard to communicate how incredible it is.  There are so many people living in the area; you live packed in next to each other, the traffic is unbearable, and the place looks like an ant colony from the hills.  At the same time the infrastructure also supports you - great food, great weather, lots of public transportation options and ride-sharing services help you get around.  Worst case, since San Francisco is just this 7x7 mile postage stamp, you can always walk.

Still, there's a darker side of this.  There's an incredible amount of income inequality.  As a tech worker I can't really complain about my salary, but you really need to work in the city in a high-paying job in order to afford anything.  Many of the tech workers I talked to had no sense of how the companies where they worked were affecting society.  I've lived in a slowly gentrifying area and every year, the rent goes up.  If you want to buy a house here it's north of a million dollars.  Wildfire season gets worse every year.  None of these issues were really unknown before I moved, but they've been background noise for my entire time here.

Overall it's been a great time.  I'm happy to have been here when I was.  I'm also happy that I'm moving on to the next thing.

## Work memories

* Rewriting the Tilt React rendering engine to use embedded V8; this let us render React components server-side while still using our legacy Perl application servers.  At the same time it totally removed the need for us to migrate from Perl to Node.JS.  A great outcome for the company (we didn't need to spend nine months rewriting everything) and a less great outcome for the engineering team (we had to deal with the legacy application server code until the company shut down).
* I investigated React's Context feature for Tilt and ended up having the #1 SEO result for "React Context" for a long while, though my article on it wasn't really very good.  Thank goodness they finally documented that feature so I could unlist that post.
* I learned to write iOS code and ended up building out the "quick return" feed pattern in iOS for Tilt's 2016 "back to school" push.  This was a technically challenging bit of pixel manipulation where scrolling down would hide a header, but scrolling up would cause it to reappear, no matter where you were in the feed.  While I did other stuff for the Tilt iOS app, that project was definitely the most fun.
* Seeing two startup acquisitions from the inside - Airbnb's acquisition of Tilt and Atlassian's acquisition of Chartio.  Two really different acquisitions.
* I got to implement a [distributed locking system](https://chartio.com/blog/eliminating-duplicate-queries-using-distributed-locking/) into the Chartio database query engine.  Just an incredibly fun distributed systems project where you get to use all that stuff you read about on Hacker News.  This project also had my favorite bug, where threads that I thought were doing nothing actually stayed alive and continued to execute distributed-lock related commands, in the process causing our Redis server to fall over.  (Just the first of many times that I ended up breaking that server...)
* I built out a feature where we would use custom classloaders so that we could load multiple versions of JDBC drivers into the service so we didn't have to force-deprecate any customers.  One of those places where the Java ClassLoader abstraction actually came in handy!
* Identifying and fixing a [stack explosion]({% post_url 2019-10-03-fixing-a-jni-crash-in-sqlite-jdbc %}) caused by a SQLite extension function.

## Other memories

* Going to a ton of concerts, mostly in my first year.  My favorite was seeing Dinosaur Jr at the Regency Ballroom.  One of those incredible live performances that I feel fortunate that I got to experience.
* Sea to summit from Stinson Beach to the top of Mt Tam.
* Getting a mountain bike ... and having a pretty hard spill on it.  I fractured my ribs and it really hurt to walk for a month or so.  Ouch.
* I did a bunch of backpacking trips (it seems like they give you a backpack when you move to California).  I probably did 10-15 trips in total, but the ones that stand out to me are my solo backpacking trips.  It did a very snowy trip to Lake Tahoe in April -- this was really ill-advised ... the Sierras really aren't hikable before June, and really mid-July is your best bet.  At the same time it ended up being this wonderful otherworldly experience where I huddled in my tend by myself, read a little bit of Ursula Le Guin's _The Dispossessed_, and fell asleep early.  More productively, I did a four day trek around the Timberline Trail where I'd hike during the day and settle in to read _Dune_ for the first time in the evening.
* I ran a sub-4 hour marathon as part of the Oakland Running Festival.  This fact would be pretty amazing to my out-of-shape high school self.
* I learned to ski.  Never thought I'd do that.
* Taught myself Galois theory, complex analysis, and algebraic number thoery.  Incredibly interesting stuff, especially because it isn't really applicable to anything I do at work.
* Programmed [another chess engine](https://github.com/tildedave/ra-chess-engine).  It's finally stronger than my old one.  At least, it crashes a lot less.

Personally I think my best accomplishment has been to chill out a little bit and hopefully have a bit more empathy for the rest of the world.  If I moved here as someone who thought I could change the world, I'm leaving as someone just content to exist in the world.  (Really, that's hard enough.)  Work is still a big part of my self identity but it's great to turn it off and just be Dave in the evenings.
