---
layout: post
title: 'Fix-It Fridays'
is_unlisted: 1
---

This last summer I noticed the team was getting into a bit of a rut.  We were working towards a major product launch.  As a consumer-facing product there's always been an internal culture that everything user-facing had to be _perfect_.

Okay, perfection is the goal.  But how can we accomplish perfection?  One challenge we had was the visual aesthetic was clearly understood by the product and design team, but less understood by the engineering team.  We'd miss the wrong fonts, the wrong margins on visual elements, or gloss over strange interactions that still technically worked.

These defects would end up on a list somewhere - some of these would be ticketed or raised to my attention.  All of them would have a similar effort (an hour or so of work), and I could fudge a user impact number to figure out priority.  Still, this management was a lot of work, and while some people on the team really liked churning through the tickets, it felt like something in our process was a bit broken.  Adding to the backlog was that for a long while the apps hadn't been looked at with the same visual eye, and so there were a number of older screens with a bunch of accumulated visual debt.  These got added to the list with the rest of them.

## Passing Control Over To The Team

Eventually I got a little tired of triaging visual defect tickets.  Something seemed broken if all I was doing was delegating these out to the team members in priority order.  I've always thought of myself as a leader who empowers - how could I empower the team to solve these problems rather than put myself in the middle of it?

A challenge I gave to the team was to try to, every Friday afternoon, work on something 'polish' related.  I intentionally didn't specify a list of tickets.  Rather than tell them what I thought would be polish, I would let them figure that out on their own - hunt through the app or the website for something that looked a bit weird, and then figure out how to improve it.  The one bit of guidance that I tried to give was that it should be something we could finish in an afternoon.  Through my own individual contribution time, I also participated, trying to be a good example of the sorts of changes that we should aim for - small-impact but clearly a user experience upgrade.

This got branded internally as "Fix-It Friday" - where the responsibility for application polish was in _your_ hands.  I tried to keep the ideas as engineering-sourced as possible early on, but after a few weeks the low-hanging polish was mostly gone, our product and design team members were able to suggest ideas that might be picked up and worked on.

A sample of the changes we eventually made:

* iOS: Making all the 'X' buttons to close a view across the app consistent with one another
* iOS: Adding a blocking view to various screens in our 'groups' feature
* iOS: Showing a preview of 2 groups instead of 5 groups on our 'tag friends' screen
* Android: Removing a double flicker from the loading screen
* Website: Vertically centering the 'X' button on our 'tag friends' pill lightboxes
* Website: Being able to click off of our creation lightbox to cancel it

 We did more than 40 changes like this over the course of the summer.  These ranged from very minor changes (a few lines at most) to larger refactorings (~400 lines).  Sometimes it wasn't so clear how to accomplish an improvement.  To close a lightbox when clicking outside of it, one of my interns discovered he had to update our version of the `react-onclickoutside` library, which required converting a number of views to use a higher-order component pattern and change or lightbox configuration code to support the new option.  While this added to the overall work associated with the change, the increase in ownership and learnings he got out of it were definitely worth the tradeoff from my perspective.

## Success?  On To The Next Challenge

After a few months I noticed the momentum behind "Fix-It Friday" had slowed.  A lot of the easy improvements had been done, and our apps were in a pretty great state.  From talking with people or hearing discussions in internal mailing lists, I could tell that the reputation of my team around visual polish had seriously improved.  Through a combination of aggressive closing future improvements, self-directed polish work, and normal bug fixes, we actually got down to less than 5 open tickets on our iOS backlog!  Rather than try to continue with the program, I worked with my product partner to identify some bigger projects where the team could apply a similar polish mindset but to an entire feature area.

We had some time on the roadmap and an area that we always wanted to improve was our credit card selection experience.  An engineer had built a card selector as part of a past project but it wasn't everywhere and the overall experience needed some improvement.  Rather than create a bunch of Sketch files and explicit product specifications, instead I gave the problem to the team - "we want to improve this experience, how can we do it?"  The end result was a newly built card selector whose creation was led by the engineering team.

<img class="img-responsive" style="display: block; margin: auto; max-width: 412px" src="/images/ios-new-card-selector.png" />

Over the last few months we've gone on to build a number of other engineering-driven features (user-visible transaction history, new credit card input screen) - but none of this would be possible if we were still in "take ticket, do ticket" mode.  Building up our polish muscles through these smaller initiatives let us take on these larger user improvements while removing a bottleneck around product and design, and has prepared us to tackle much more ambiguously stated problems in the future.

## Summary

* Giving people ownership over "polish" (without specifying direction) can achieve better results than handling it ticket-by-ticket.
* Turning over the "what to work on" responsibility to the team can have unpredictable results - the good kind of unpredictable.
* Self-directed work can run into unknown issues.  I prefer to work through these issues than try to justify these problems as "too much effort to solve".  While this may be true of individual cases ultimately I'd prefer for my team members to overcome challenges rather than try to consider their time too much of a precious resource.
* Eventually special events like "Fix-It Fridays" grow competencies that can unleashed to tackle projects that would have otherwise been impossible.
