---
layout: post
title: 'Greenbar: Browser-Based TDD for Python'
is_unlisted: 1

---

I am not a fan of dynamic languages.  Ultimately I believe they solve the wrong problems: static languages prevent a lot of boneheaded mistakes by allowing you to give guarantees to your code before it is even executed.  I've written before about how one of Java's backdoor features is that jamming operations together becomes a mess.

When developing in dynamic languages like Python and Ruby, it is even more important to provide a comprehensive unit test suite describing the low-level contract of the system than usual.  You have no compiler step to save you from yourself -- the interpreter assumes that you know what you're doing, leading you to rely on tests more than ever.

I'm going to talk about my favorite way to write tests for dynamic languages.  I think it hits a sweet spot that is viscerally satisfying -- a sweet spot that is only possible because of the absence of a compilation phase.

## In JavaScript

One of the coolest features of JavaScript is that, because everything is in the browser, you can tie a unit test framework into a web page.  The one I'm most familiar with is [Jasmine](http://pivotal.github.com/jasmine/).  In writing Jasmine tests, you slowly grow a <b>Spec Runner</b>, an HTML file that points to your source files (`Calculator.js`) and your JavaScript specification files (`CalculatorSpec.js`).

The speed at which Jasmine specifications run is extremely satisfying, making the traditional <a href="http://c2.com/cgi/wiki?TestDrivenDevelopment">TDD cycle</a> go very fast.

* Write a test
* Reload browser, see failure (<b>RED BAR</b>)
* Write the functionality for that test
* Reload browser, see success (<b>GREEN BAR</b>)
* Refactor, check that all specifications still succeed

In other languages, I can end up impatient with my compilers (especially when using a hog like Maven or when changing one header file causes an entire C++ project to be recompiled) and will sometimes delay writing tests knowing that it will take a ridiculous amount of time to see even the red bar.

## Why the Browser?

I think that my generation has been conditioned to interact with the world through the browser.  Check your favorite news site/RSS feed, read through all the articles -- when you run out, you want to see if there are more ... refresh the browser.

Reloading the browser to see what's new has a powerful psychological effect.  After years of web browsing I have been conditioned to refresh the browser to see what new goodies await.

When I see a failure in a browser-based testing environment, I want to fix it.  I will always have a much deeper emotional commitment to typing the 'reload' key combination on my browser than I ever will to JUnit output.

## In Python

I've just finished up work on the initial version of [Greenbar](https://github.com/tildedave/greenbar), a server that runs in the browser and runs [`nosetests`](http://readthedocs.org/docs/nose/en/latest/) on the specified directory every time you reload the page.

Here is a failed test:

![failing test](http://github.com/tildedave/greenbar/raw/master/redbar.png)

Here is a successful test:

![successful test](http://github.com/tildedave/greenbar/raw/master/greenbar.png)

I hope that Greenbar is useful -- I will definitely be trying using it for my next Python project.

If you haven't tried out browser-based TDD, you are missing out -- the rapid cycle makes developing extremely satisfying and TDD generates a test suite that allows for you to refactor your code without fear of breaking anything.

## Other Similar Projects

* [Jasmine](http://pivotal.github.com/jasmine/)
* [PHPUnit Test Report](http://mattmueller.me/blog/phpunit-test-report-unit-testing-in-the-browser) (PHP)
* [MXUnit](http://mxunit.org) (ColdFusion)
