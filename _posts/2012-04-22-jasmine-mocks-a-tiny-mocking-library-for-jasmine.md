---
layout: post
title: 'jasmine-mocks: A Tiny Mocking Library for Jasmine'
---

I just released version 0.0.2 of [jasmine-mocks](https://github.com/tildedave/jasmine-mocks), a tiny mocking library for use with Jasmine.

I really like Jasmine as a testing framework -- I've converted my last two teams to using it and I really like how easy and expressive it makes testing.  However, I have some very minor pain points around using Jasmine for larger codebases that include a lot of little objects with very isolated behaviors. jasmine-mocks aims to address issues that arise when writing Jasmine specifications for this kind of codebase.

## Creating Mock Objects From Prototypical Classes

jasmine-mocks allows you to easily create a mock instance from a prototypical class (defining a constructor as a function and methods as functions on the constructor's prototype).  This removes the need for you to explicitly define functions on mock objects.

```javascript
var Dog = function () {};
Dog.prototype.bark = function () {
 alert('bark!');
};

describe('DogTricks', function () {
  var mockDog = mock(Dog);
  var tricks = new DogTricks(mockDog);
  tricks.whistle();

  expect(mockDog.bark).toHaveBeenCalled();
});
```

## Mocks That Can Emit Events

JavaScript frameworks allow firing events on arbitrary objects (two examples: Node's EventEmitter and Closure's EventTarget).  jasmine-mocks allows you to make mock objects that inherit real behavior to allow testing these objects without instantiating a real class.

```javascript
var Dog = function () {};
Dog.prototype = Object.create(EventEmitter.prototype);
Dog.prototype.giveBiscuit = function () {
  ++this.numBiscuits;
};

describe('DogTricks', function () {
  var mockDog = mock(Dog, EventEmitter);
  var tricks = new DogTricks(mockDog);

  mockDog.emit('roll over');

  expect(mockDog.giveBiscuit).toHaveBeenCalled();
});
```

## Basic Matching Functionality

Spies are great, but they don't allow you to be certain you are passing the right values to them.  If you want to make sure that your Jasmine spies are being called with the right arguments you need to add extra asserts, something that shouldn't be necessary.

jasmine-mocks allows you to easily create matchers that give your spies different functionality when different arguments are passed in.  The main benefit to this is not returning good values when bad arguments are passed in.

```javascript
describe('DogFeeder', function () {
  var mockDog = mock(Dog, EventEmitter);

  when(mockDog.likesFood).isCalledWith('biscuit').thenReturn(true);
  when(mockDog.likesFood).isCalledWith('kibble').thenReturn(false);

  var dogFeeder = new DogFeeder(mockDog);
  dogFeeder.addFood('biscuit);
  dogFeeder.addFood('kibble);
  dogFeeder.feed();

  expect(mockDog.feed).toHaveBeenCalledWith('biscuit');
});
```

The source code is available on [Github](https://github.com/tildedave/jasmine-mocks).  I hope that you find it useful!
