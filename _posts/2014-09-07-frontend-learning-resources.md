---
layout: post
title: 'Frontend Learning Resources'
---

So I am starting a new job on Monday with [Tilt](https://tilt.com) as a Frontend Engineer.  In the process of doing this I've been reacquainting myself with the frontend landscape.  In talking with a friend I realized that there is a lot of things to learn and maybe not a lot of guidance.  This is my attempt to compile a set of learning resources that either I found helpful or that I think I would find helpful for someone who was just beginning frontend development from a predominantly server-side role.

This is intentionally uncomplete.  Frontend is a rapidly changing landscape and I have been focused on other things (that are also wonderful) for the last few years.  I understand Angular at a high-to-medium level but haven't dug in enough to consider myself proficient.  I need to take time to evaluate Ember as it seems very good from a distance.  So I am still learning too.

In this collection I want to highlight resources that encourage different ways of thinking about frontend code (new concepts).  While tools like jQuery are great and need to be learned, I don't think that the library really introduces you to many new concepts over what the DOM already provides - it is just a "better" DOM interface.  To handle performance bugs with your code you will need to understand what jQuery is actually doing under the hood.  So knowledge about underlying technologies is very useful.

This is intentionally biased towards things I find interesting (tools that promote fundamentals and libraries built off of "crazy ideas") and away from things I don't ("wrapper" tools that provide a different interface).  It is biased towards particular formats that I like (blog posts and websites) and away from others that I don't (screencasts and books).

## The Basics

[JavaScript Garden](http://bonsaiden.github.io/JavaScript-Garden/)

My favorite learning resource for JavaScript once you understand enough about it to make the page behave.  Talks about all of the important "gotchas" of the language.

[Front-end Development Guidelines](http://taitems.github.io/Front-End-Development-Guidelines/)

I agree with most of the advice here.  The only thing that I don't like is their promotion of the `var self = this` pattern and I recommend you ignore this advice.  Either learn JavaScript `this` or don't use patterns that require `this` (e.g. don't use `new` to make objects).

[JavaScript Weekly](http://javascriptweekly.com/)

Weekly news magazine.

[Eloquent JavaScript](http://eloquentjavascript.net/)

The only book on JavaScript that I would recommend.  It focuses on programming in JavaScript without the aid of frequently-used "helper libraries".

[Vanilla.js](http://vanilla-js.com/) and [You Might Not Need jQuery](http://youmightnotneedjquery.com/)

Web development today is different from it was in the past - it used to focus on browser compatibility and wrapping the DOM into a uniform information.  (I think this is a fair statement: I was not doing frontend development in the days of the IE6 box model hack.)  With modern browsers that auto-update, our attitude towards jQuery and polyfills should be re-evaluated given the current state of browser development.  Sites that challenge the dominance of jQuery are important for this and whether or not you agree with the conclusion you should be aware of what is provided by jQuery and what is provided by the DOM.

[Flight](https://github.com/flightjs/flight)

Lightweight JavaScript component library from Twitter.

[Promises](http://www.html5rocks.com/en/tutorials/es6/promises/)

Promises are a pretty key thing to know for modern JavaScript.  CPS-style chaining of callbacks might have been okay three years ago but jQuery and other libraries (e.g. Angular) are all starting to introduce some sort of promise-like interface.  In a single-threaded computation model asynchronous interfaces need to have a promise-like model to avoid becoming callback hell.  That said, promises do not avoid callback hell in themselves as they still encourage an innately procedural style of thinking.  However, they are an easily composable building block that can be used to build high-level abstractions, whereas handling interleaving callbacks while still handling error scenarios can be quite challenging.  You do handle your errors, right?

## Bigger Ideas About Application Structure

[TODO MVC](http://todomvc.com/)

Reimplements a TODO list application in nearly every frontend framework.

[Flux Application Architecture](http://facebook.github.io/react/docs/flux-overview.html)

Suggested application architecture from facebook -- encourages a 1-way flow of data instead of components that have 2-way bindings.

[React Training Material](https://github.com/rpflorence/react-training/tree/gh-pages/lessons)

Example training material for learning React through building some example React components.

[React vs Ember](https://docs.google.com/presentation/d/1afMLTCpRxhJpurQ97VBHCZkLbR1TEsRnd3yyxuSQ5YY/edit#slide=id.g380053cce_041) and [Angular vs Ember](https://docs.google.com/presentation/d/1e0z1pT9JuEh8G5DOtib6XFDHK0GUFtrZrU3IfxJynaA/preview#slide=id.g177e4bd2b_0253)

Great talks discussing how Ember, React, and Angular relate to each other.  These are the "big three" of 'heavy' JavaScript libraries today (Fall 2014) and understanding what each of them do and how they relate to each other is important.

[Polymer](http://www.polymer-project.org/)

Polymer polyfills web components so that they can be used today.  Goes further and allows you to declare web applications in a fully declarative manner.  I don't think that declarative is an "end goal" that works for everyone but I really admire the commitment to see the idea to its conclusion.

[Om - A ClojureScript interface for React](https://swannodette.github.io/2013/12/17/the-future-of-javascript-mvcs/)

React relies on the idea that you can just rerender everything rather than maintain stateful components.  To do this it relies on diffing the old DOM and the new DOM and only updating the parts of it that have changed.  To do this efficiently it relies on some heuristic algorithms, but these can't always be sure and will sometimes need to do expensive computations to determine whether or not a DOM node has changed.  Om is a ClojureScript library from David Nolen that uses Clojure's immutable data structures to rerender everything efficiently through reference equality.  See also [`immutable.js`](https://github.com/facebook/immutable-js) from Facebook.

## CSS

CSS is not an area of strength for me.  (Not saying I am horrible at it -- just, I would not lead with CSS as a key skill that I will differentiate myself with over another applicant.)  Here are some ideas I think are helpful in turning your interactions with CSS from *"how to do it?"* to _"how to do it **right**?"_

[https://github.com/stubbornella/oocss/wiki](Object-Oriented CSS) and [An Introduction to Object-Oriented CSS](http://www.smashingmagazine.com/2011/12/12/an-introduction-to-object-oriented-css-oocss/)

Object-Oriented CSS has some opinions about how you should be doing CSS (generally: only style classes, don't style ids, don't use descendent styles).  We introduced many of these guidelines onto a past project with good success.

[Medium's CSS Is Actually Pretty Good](https://medium.com/@fat/mediums-css-is-actually-pretty-fucking-good-b8e2a6c78b06)

Talks about the "CSS journey" that Medium has been on.  Highlight antipatterns that the team found themselves in and how they were overcome.

## Other Tools

* bower
* npm
* underscore
* mustache
* sass
* less
* jasmine
* mocha
* sinon
* browserify
* node.js
* socket.io

## Conclusion

Something I love about frontend coding is the incredible diversity of the landscape.  There isn't "one way" to do anything - the community gives you a number of different approaches that you can apply to your project.  The other side of this is that you will frequently adopt one approach, commit to it, and then everything will change around you, leaving you with a big investment to an out-of-date framework or library.  However, if you don't commit to a library or framework you end up with a large amount of code that reinvents the wheel.

I don't think this situation is necessarily bad -- I see it as a natural consequence of having such a vibrant community.  There is something frustrating about seeing a number of options and knowing that no matter what you pick, it will not be the best thing in two years because of circumstances beyond your control.  However over the last five years frontend development has evolved from being primarily polyfill and trivia based (thus necessitating libraries such as jQuery) to focusing on what I'd consider more classical software engineering problems such as application structure.  With browsers adopting faster delivery cycles and focusing on cross-browser standards I hope that we will never need another library that was as universally adopted as jQuery was.  We'll see what happens in a few years.
