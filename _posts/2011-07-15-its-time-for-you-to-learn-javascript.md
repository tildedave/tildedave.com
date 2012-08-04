---
layout: post
title: 'It''s Time For You To Learn JavaScript'

---

My first job was writing C++ applications on Windows (2000-2001, 2002-2003).  My second job was writing C++ applications on Linux (2002-2003).  Along the way I picked up Java in classes and used that for a summer project (2003).  In graduate school I hacked with SML, OCaml, and Java, writing applications in support of programming language research.

The web revolution occurred without me.  I only started writing web applications a little over a year ago (PHP, then Python, then Ruby, then .NET MVC and Java).  I still have a lot to learn on how to build a web application, but I think I understand the basics now.

If you're like me and have been fundamentally a 'backend' programmer most of your life -- if you've programmed more algorithms than applications and haven't ventured into the web application world, you have probably missed out on a vital piece of the new technology stack.

**It's time for you to learn JavaScript.**

## JavaScript Is Everywhere

If you write an application in JavaScript, everyone can use it -- technical, non-technical, developer or consumer.  Fully featured web applications are the direction that the web is going towards, and JavaScript is starting to invade the server through [Rhino](http://www.mozilla.org/rhino/), [SpiderMonkey](https://developer.mozilla.org/en/SpiderMonkey) and [Node](http://nodejs.org/).  (Also, [CommonJS](http://www.commonjs.org/) is attempting to define a non-browser API.)

It's not as obvious that JavaScript has any advantage on the server, but if a standard for file/socket interaction that can run on both the server and the client catches on, watch out: languages don't necessarily win because of technical merit, they win through inertia.  Running different parts on your application in different places on the same technology is a powerful argument for a technology stack.

## JavaScript Is Just Like Any Other Language

You get to take with you all of the skills you've learned from developing in other languages.  Are you a Java developer?  JavaScript has some familiar syntax and some basic object-oriented boilerplate will help you along until you're ready to tackle exactly what a 'prototype' is.  Are you a functional programmer?  JavaScript gives you first class closures.  Libraries like [Underscore](http://documentcloud.github.com/underscore/) allow you to use functional programming concepts in your applications. (sadly, no macros yet, though).

## JavaScript Is Getting Better

Libraries like JQuery, Prototype, and Google Closure Library abstract the browser-specific ugliness of the Document-Object-Model API.  Doing a `jQuery.ajax` means you don't have to wonder if `XMLHttpRequest` is defined or not.

Libraries like Google's V8 are working to bring the speed of virtual machines (like Java's JVM) into the browser.  Faster client applications means a more responsive GMail, Google Docs, Google Plus.

Developers are even starting to step in where the ECMA standards body is not, by providing tools for common language features like dependency management ([RequireJS](http://requirejs.org/), [Sprockets](http://getsprockets.org/)) and static type-checking ([Closure Compiler](http://code.google.com/closure/compiler/)).

There is a ['good JavaScript'](http://www.crockford.com/javascript/) movement determined to write better JavaScript code in the same way that unit testing/clean code has aspired to make developers write better C++/Java/C# code.

JavaScript faces a number of interesting challenges in the path to writing better code: inconsistent DOM API, lots of applications are basically GUIs (difficult to test in the first place), entrenched programmer beliefs about JavaScript not being a 'real' application.

## It's Easy To Learn

Everyone already has a read-eval-print loop for playing around with JavaScript syntax -- it's their browser!  Google Chrome lets you turn on developer tools, go straight to the console and start hacking out JavaScript code.  There are also many in-browser JavaScript [developer environments](http://eloquentjavascript.net/paper.html) available for you to choose from to get immediate feedback.

There are a number of great resources available to help you learn JavaScript the **Language**, not simply JavaScript the browser toy.  Right now my favorite is [Eloquent JavaScript](http://eloquentjavascript.net/) -- it introduces the language by itself without appealing to any libraries like JQuery [1].  I especially like the [Object Oriented Programming chapter](http://eloquentjavascript.net/chapter8.html) -- it makes it very clear how to build objects in a way that's familiar from my years and years of Java/C++ programming.

Once that's finished, I like [JavaScript: the Good Parts](http://www.amazon.com/JavaScript-Good-Parts-Douglas-Crockford/dp/0596517742) and the [JavaScript Garden](http://bonsaiden.github.com/JavaScript-Garden/) for rounding out the parts of the language that are a little more foreign to me.

## Very Flexible For Testing

Because anything can be redefined at runtime, it's easier to create seams to test poorly architected code.  At work, we've redefined the `jQuery.ajax` function to test parts of our code that interacts with the server from the client.

[Jasmine](http://pivotal.github.com/jasmine/) is my testing framework of choice for JavaScript (in part because that's what I used first).  As a developer, the really satisfying thing for me in writing JavaScript tests is how fast they take to run.  Control-Shift-R to reload the browser, all tests ran in 0.075 seconds.  This makes doing TDD for JavaScript really easy (easy enough so that I'll remember to do it!).

## Conclusion

I'm not a JavaScript expert yet, but I'm trying to get better.  If you're also looking to improve I *really* recommend that your next project be in JavaScript.  It doesn't have to be a web application -- it can be anything.  It might not even talk to the browser at all.

JavaScript is just a language like any other.  You still need to write tests.  You still need to write small methods, small objects, and make sure you have seams for testing through dependency injection.  Prototype-based inheritance is a little strange at first, but it's not really too hard once you take some time to see what it's doing.

As developers, we need to take all the great things we've learned about agile development and apply them to JavaScript development.  Having a common platform in the browser and an expanding list of full-featured JavaScript applications means that JavaScript has already won.

### Notes

[1] I like JQuery a lot but it's very important to understand what in your JavaScript code is JavaScript, and what is JQuery.  JQuery is just too useful for Getting Things Done -- this blurs the lines and sometimes makes me forget, yes, JavaScript has for loops!
