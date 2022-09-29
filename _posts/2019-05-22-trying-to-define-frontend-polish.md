---
layout: post
title: "Trying To Define What I Consider 'Frontend Polish'"
comments: true
is_unlisted: 1
---

* Page loads quickly - should be able to serve the initial page in < 100ms
* No weird flashes during loading (elements don't "pop in" or rearrange during loading)
* No obvious defects when the page is resized to different screen sizes
* No obvious CPU lag during interactions
* Making a modification to some value on the page updates it everywhere it's used (no page refresh required)
* Interactions don't weirdly lag - if some operation is asynchronous and takes a few seconds, a spinner gets displayed
