---
layout: post
title: 'Integrating Closure Tools With Third Party Code'
---

My team develops Rackspace's Customer Control Panel, which allows
users to manage their infrastructure by doing things like creating new
servers, connecting load balancers to them, and updating DNS entries.
We develop JavaScript using the [Closure
Tools](https://developers.google.com/closure/); our entire project
(including unit tests) is over 130,000 LOC and growing as we expose
more products and functionality.

## Closure Library

While we use the Closure Compiler and Closure Templates as part of our
project, we spend most of our time interacting with the Closure
Library, which contains a broad class of reusable widgets.

The real advantage to the Closure Library is that they have a wide
range from straightforward (`goog.ui.Button` and `goog.ui.Tooltip`) to
extremely specific (`goog.net.IframeIo` for doing file uploads without
a page refresh, `goog.async.Deferred` for a JavaScript Deferred
implementation).  It's really wonderful when you can rely on a library
to implement a common code pattern.

However, the Closure Library does **not** care about program
structure: it only provides components that help you build your
application.  However, when building a web application you probably
are using an established application structure (such as MVC or
MVVM-style) and the Closure Library unfortunately does not provide you
with out-of-the-box solutions for Backbone.js concepts such as the
App, Router, Models, and Views.

You could roll your own, or you could rely on code that other people
have written and already fixed bugs in...

## Demo: Integrating Closure Tools With a Router

I've put together a
[demo](https://github.com/tildedave/google-closure-plus-routing-demo)
showing how you can integrate the Closure Tools with a third-party
library, in this case the Spine router.

Without using a third-party App/Router solution, you need to roll your
own, either by writing your own detection for history change events,
or wrapping the `goog.History` library class.

I chose to use [Plovr](http://plovr.com/) to integrate the demo with
the Closure Tools.  One of the main advantages of Plovr is that it
provides an "out of the box" method of integrating your code with the
Closure Compiler, both in development (a server that serves what is
required) and production (a compiler that generates the final built
files to be served).

### Using the Router

Using the Spine Controller and Router to display Closure views looks
slightly different: we create a Spine Controller and switch between
views when different routes are activated.

```javascript
var displayView = function (NewViewClass) {
  if (currentView) {
    currentView.dispose();
  }

  currentView = new NewViewClass();
  currentView.render(goog.dom.getElement('main'));
};

var App = Spine.Controller.sub({
  init: /** @this {Spine.Controller} */ function () {
    this.routes({
      "settings": function () {
        displayView(demo.SettingsView);
      },
      "home": function () {
        displayView(demo.HomeView);
      }
    });
  }
});
```

Here `settings` and `home` indicate the code that is called when
different routes (designated by the window's `location href`) are
activated.  This lets you use `a` tags to navigate between views and
so allows you to avoid writing custom logic.

### Defining Our Views

For the purposes of this demo, views are defined by subclasses of
`goog.ui.Component`.  The home view is fairly straightforward,
creating a DOM element with the class `home-view` and setting the text
inside of it.

In general some kind of JavaScript templating solution, either Closure
Templates or another option like Mustache or Underscore templates, are
a better choice than manual DOM construction; I omitted using
templates here to simplify the demo as much as possible.

```javascript
/** @inheritDoc */
demo.HomeView.prototype.createDom = function () {
  var message;

  this.setElementInternal(goog.dom.createDom('div', 'home-view'));

  message = goog.dom.createDom('span');
  goog.dom.setTextContent(message, 'Welcome to a Google Closure demo!');
  goog.dom.appendChild(this.getElement(), message);
};

/** @inheritDoc */
demo.HomeView.prototype.enterDocument = function () {
  goog.base(this, 'enterDocument');

  demo.NavBar.makeActive('home-view');
  document.title = 'Closure Demo Home';
};
```

For those unfamiliar with the Closure Library, the createDom and
enterDocument functions are called (in a specific order) when a view
is displayed, based on the Closure Component lifecycle.  First
`createDom` is called to create the DOM element that will be displayed
on the page.  The `enterDocument` function is called later when the
DOM element is actually inserted into the page.

### Telling the Compiler Which Code is External

In order to compile our code we need to tell the Closure Compiler
which code corresponds to an external library -- in this case, we must
tell the compiler that `Spine` should not be compiled.  Because the
Closure Compiler needs types in order to make its decision we must specify an externs.

Here's a sample from the externs file to give a flavor of what is
required in integrating a third-party library into something used by
the Closure Compiler.

```javascript
var Spine = {};

/** @constructor */
Spine.Controller = function () {};

/** @param {Object} obj */
Spine.Controller.sub = function (obj) {};

/** @param {Object} obj */
Spine.Route.prototype.routes = function (obj) {};

Spine.Controller.prototype.routes = Spine.Route.routes;
Spine.Controller.prototype.navigate = Spine.Route.navigate;
```

By defining this files as an externs file, we prevent the Closure
Compiler from renaming these variables and functions, as well as
provide type checking at the boundaries between our code and the
library.

This matches a common technical in program analysis -- if you have a
portion of your code that the compiler grants special properties (in
this case, type-checking of JavaScript), but your code deals with
external libraries, you specify the how the boundaries of these
external libraries behave.  Several years ago I needed to write a
[tool](https://github.com/tildedave/siggen) for automatically
generating "signature files" which define the security policy of
external code.  This involved running through the code, seeing what
external classes and functions were called, and creating a skeleton
file with these classes and functions defined.

## What's Next?

I'd like to expand this demo in a few ways: I think the most realistic
scenario is that you would split the code for your views between
*modules*.  While there's already a
[demo](http://code.google.com/p/plovr/source/browse/#hg%2Ftestdata%2Fmodules)
for Plovr that shows how modules can split views, this demo is fairly
DOM-centric and I think there is room for showing how a *VC-based
approach can support loading different modules between views.