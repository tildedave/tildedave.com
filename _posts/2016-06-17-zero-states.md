---
layout: post
title: 'Zero States'
is_unlisted: 1
---

We just finished work on another feature yesterday.  A lot of our day to day software development planning tends to be pretty adhoc - after a few years experience following more formal estimation processes, I've been trying to encourage my teams away from up-front planning (and so towards more team ownership of the delivered work).  This means that stuff can sometimes fall through the cracks, and yesterday I noticed we hadn't done any testing around what things looked like for an initial signup ... which of course was a blank gray screen.

When you're deep in the guts of a building a feature it's easy to deprioritize the "zero state" (no items).  They're usually pretty easy to build - static screen, no real interaction behavior.  Maybe link to another static screen with some more context about the overall product.  After enough time with the same product I don't even bat an eye clicking through screens and screens of zero states - "yeah this is what it looks like when there's nothing, let me get to the screen with that bug so I can make sure I fixed it".  These screens I just sort of gloss over look really different to our customers - when they see that page says "You don't have any X now", they'll be asking _what is an X_, and _what can it do for me_?

It's easy to overlook the question of "why" when you've been working on the same product for a while, but it's a question that your customers are constantly asking.  Why do I need to use your product?  Why do I need to install an app?  What benefit does any of this give me?  These are questions that our designers are constantly thinking through, and it's a funny thing about software development that something so simple and basic to build is so important, and often the thing we'll do last.
