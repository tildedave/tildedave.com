---
layout: post
title: 'A Fundamental Concept'
is_unlisted: 1
---

Something that interests me is program structure.  My last project had been maintained by at least four separate development teams with shifting team members over the course of six years.  Though coding styles made it obvious which team was last "in the code", the underlying program structure remained the common thread.  Data was consumed through an Enterprise Service Bus in XML or a SQL database, turned into objects through technologies like JAXB/Hibernate, and moved forward through the system until it was consumed by the `Action` classes (controllers) and rendered into a JSP template.  _Architecture_ is what abstractions are introduced in order to start talking about business logic and stop talking about technologies.  However, without a firm understanding of how data flowed through the project, it was impossible to take know the best way to adapt the project's codebase to meet its current needs.

Choosing certain technologies drastically affects how you structure your program.  Technologies that deliver concurreny in a single-threaded event loop, such as Twisted Python and JavaScript engines like V8, demand major concessions in how you structure your program.

# Callbacks

In an event loop environment, rather than implementing in a straight line, you break apart the program into its underlying data flows.  Certain library operations that take a long time take a callback as an argument and pass the result that is eventually computed to this callback for processing.

The practical reason for this change in structure is that in an event loop, you cannot wait for certain long-running operations to succeed: getting a database connection may take a whole second, during which the reactor is blocked and no new requests can be served.

```javascript
function respond(req) {
  getDatabaseConnection(function (dbConn) {
    dbConn.executeSql('SELECT * FROM accounts ...', function (accountData) {
      getElasticsearchConnection(function (esConn) {
        esConn.query({
          fields: ['account_id', accountData.get('id')]
        }, function (account_search_data) {
          // use data from elasticsearch to populate the response
          req.write(account_search_data.get('last_billing_invoice_amount')
          req.finish();
      });
    });
  });
```

This programming style is sometimes described as "callback hell" and there are great resources online about how to set up your callbacks to avoid a tangled mess of dependencies.

The programming style that you force yourself into while writing callback-style programs is very similar to [continuation-passing style](http://matt.might.net/articles/by-example-continuation-passing-style/) (CPS), an intermediate form used by functional compilers.  Instead of producing code like:

```javascript
function doIt(b, c) {
  return b + doSomethingElse(c) * 5;
}
```

This code is transformed by the compiler into:

```javascript
// addition and multiplication also pass their computed value forward to a
// continuation, e.g. *(5,6,k) passes '30' to the function k

function doIt(b, c, k) {
  // k1 is the value from doSomethingElse(c)
  doSomethingElse(c, function (k1) {
    // k2 is the value from doSomethingElse(c) * 5
    *(k1, 5, function (k2) {
      // pass the value from k2 + b to k
      +(k2, b, k);
    });
  });
}
```

Here as each expression in the program (such as `c * 5`) is computed, its value is 'passed forward' to the next computation that needs to be performed.

A major application of the CPS transform is to convert recursive calls with a potentially unbounded stack into tail calls.

```javascript
function factorial(n) {
  if (n === 1) {
    return 1;
  }

  return n * factorial(n - 1)
}
```

The above function with a non-tail call: the return result from the recursive `factorial` call has a computation applied to it before being returned.  This means that calling `factorial` must create a new stack frame.

By converting the program into continuation-passing style, it can be implemented with constant stack space to be used and making a recursive call as costly as a `goto`.  This is done by taking the value that was created through an unbounded call stack and explicitly passing it forward through the program.

```javascript
function factorial(n, k) {
  factorialHelper(n, 1, k)
}

function factorialHelper(n, a, k) {
  if (n === 1) {
    // the accumulator is the final value and is passed to the original
    // continuation
    (k a)
  } else {
    -(n, 1, function (k1) {
      *(n, a, function (k2) {
        factorialHelper(k1, k2, k)
      });
    });
  }
}
```

Humans are not expected to program in this style -- this conversion is performed by the compiler as part of code generation.

When programming callback-style within an event loop such as a browser's JavaScript engine, programmers must explicitly manage the data flow between certain operations.  Just like other aspects of your codebase, if poorly managed, the way data flow is represented can result in overly complicated code, leading to defects.

## Looking for Something Better

Callbacks do some things well. If you're writing a small program, they're really easy to get started.  It's usually pretty clear what's going on from looking at the code, especially if it's a simple straight-line "do A, do B, do C" like the above "callback hell" example.  Callback-style programming makes it really easy to pass values from one computation to the next through the creation of closures (in JavaScript, through the creation of a closure through an anonymous `function` declaration).

However as your program gets larger, callback-style programming can emphasize the wrong things.  Certain abstractions remain hidden because the callback structure is tuned towards a procedural mindset: things that are done, rather than turning common behaviors across the code into a shared concept.

# Deferreds

Deferreds are one solution to the problem of making data flow in an evented system explicit.  A deferred has a few main behaviors:

* `addCallback`: a function to call on success, taking a produced value
* `callback`: a function to invoke the callbacks on a deferred

(I'll be sticking mainly to Twisted's Deferred implementation here and won't be talking about `errback`, though deferreds also clean up error handling drastically.)

## Deferreds, Quickly

Deferreds make it easy to express flow between functions while passing values forward.  Once a deferred's callback is executed, it moves on to the next callback.  When a deferred's `callback` function is invoked it is said to 'fire'. Once all callbacks are finished it is said to be "done".

```python
from twisted.internet.defer import Deferred

def one(value):
    puts "executing one, value is {0}".format(value)
    return value * 2

def two(value):
    puts "executing two, value is {0}".format(value)
    return value * 3

def done(value):
    print "All done!  Value is {0}".format(value)

d = Deferred()
d.addCallback(one)
d.addCallback(two)
d.addCallback(done)

d.callback(5)
> "Executing one, value is 5"
> "Executing two, value is 10"
> "All done!  Value is 30"
```

Here the deferred fires with a value of 5.  As each function is the callback chain is completed, it passes the value returned forward to the next function.

## A More Advanced Example

Deferreds can indicate that more work needs to be done before it is finished by returning another deferred object.  Here's an example of how you can break dwon the recursive factional function into a set of steps by passing an accumulator forward.  Similar to the CPS-style factorial earlier, we create an accumulator and pass it forward between the deferred callbacks.

```python
from twisted.internet.defer import Deferred

def finished(value):
    print "All done!  Value is {0}".format(value)

def factorial(acc, value):
    print("acc is {0}, value {1}".format(acc, value))
    if value == 1:
        return acc

    d = Deferred()
    d.addCallback(factorial, value - 1)
    d.callback(acc * value)
    # return is important because other d's callback is not associated with
    # the original deferred
    return d

d = Deferred()
d.addCallback(factorial, 5)
d.addCallback(finished)
d.callback(1)
> "acc is 1, value 5"
> "acc is 5, value 4"
> "acc is 20, value 3"
> "acc is 60, value 2"
> "acc is 120, value 1"
> "All done!  Value is 120"
```

## Making Callback-Style Programming Use Deferreds

You can convert a callback-style program into one that uses deferreds easily.  In the original code, the value is passed forward to a function that will consume the value; this function should pass its value to a deferred that is returned from a wrapper around the original function.

```python
from twisted.internet.defer import Deferred

def deferred_wrapper(fn):
  d = Deferred()

  def on_finished(value):
    d.callback(value)

  fn(on_finished)
  return d

def func(on_finished):
  # do stuff
  on_finished(3)

def done(value):
  print "All done!  Value is {0}".format(value)

d = deferred_wrapper(func)
d.addCallback(done)
> "All done!  Value is 3"
```

Through these examples it should be clear how deferreds handle data flow and why they might be preferred in some situations over a callback-like structure.  Deferreds explicitly represent the computation to be performed as a value; the next step is defined by attaching handlers to it.  More advanced concepts exist: the `DeferredList` runs operations in parallel and passes results forward afterwards.

# Data Flows Are a Fundamental Concept

These concepts -- CPS-style programming, callbacks, and deferreds -- are concerned with how data flows through a program between inputs and outputs.  However, these are only examples of a general problem with a general solution: [monadic computation](http://www.haskell.org/haskellwiki/Monads_as_computation).

There are enough [monad tutorials](http://www.haskell.org/haskellwiki/Monad_tutorials_timeline) in the technical blogosphere; some of them are rather good.  However, more of them are frustrating for a few common reasons:

* No motivation ("You've read monad tutorials and don't understand them -- time for another one!")
* Bad motivation ("You need monads to do I/O in Haskell" -- a true statement, but a problem I and most programmers don't have!)
* Conflating functional programming with pure programming (Lisp has had `setq` since the start -- is it not functional?)
* Getting too technical -- it's really hard to motivate the introduction of category theory outside of mathematical posts

Wadler's [original paper](http://homepages.inf.ed.ac.uk/wadler/papers/marktoberdorf/baastad.pdf) suggesting the use of monads in pure functional programming gives a wonderful motivating principle:

> "Pure functional languages have this advantage: all flow of data is made
> explicit.  And this disadvantage: sometimes it is painfully explicit."

The paper goes on to clearly identify the problem that this new concept is trying to solve -- abstracting data flow so that the same program can roughly be used to support several very different concepts, such as exception and output.

I'm disappointed that somewhere after this very clear introduction we have ended up in a place where the motivations behind this fundamental concept are unclear and we end up talking about the [wrong things](http://www.haskell.org/haskellwiki/What_a_Monad_is_not) over and over again.  (I remember my own learning procedure for monads and could have done with a good dose of clear motivation... maybe I was reading the wrong tutorials!)

# Why Should You Care?

If you aren't a web programmer, you may not care about creating two `XMLHttpRequest` objects and doing an operation only when both of them are finished with a 200 status code.

If you aren't a distributed systems programmer, you may not care about event-driven architecture and what operations are safe to perform in the event loop.

If you don't program in Haskell, you probably aren't likely to care about pure functional languages or what techniques allow you to sequence I/O in them.

All of these problem domains deal with the same underlying fundamental problem: how to sequence and abstract data between operations in different environments.  The solutions all have a similar flavor: abstract computation as a value that manages the data flows for you -- passing results forward in closures (Callbacks), returning objects with explicit data flows (Deferreds), or defining what it means for one computation to interact with another (Monads).

A solid understanding of these fundamental concepts will let you switch between stacks more than any new technology.  The newest "hot topics" are very frequently really just the old concepts with a new name.

![](/images/2013-06-12-plt-hulk-tweet.png)

_I recently gave an introductory tech talk on this topic at the Rackspace Blacksburg office: [Event Loops and Deferreds](/talks/event-loops-and-deferreds.pdf)._
