---
layout: post
title: 'Mixins Deserve First-Class Status in OO Education'

---

As a profession we have failed to educate new programmers *when* to use inheritance.   The metaphors that are used as to *why* you should inheritance in an introductory class are usually completely off ("reuse" being the top offender).  Based on how we introduce inheritance, programmers with one or two weeks of OO experience usually find it difficult to grasp exactly when this strange new language concept should be used.

## Inheritance Smells

*"That method is in the superclass so that the superclasses can easily call it."* -- Global State v2.0.  The most common abuse of inheritance and the one that hurts me the most.

*"That class is abstract even though it has no abstract members."* -- Then why can't I instantiate one?

*"That method is implemented in the superclass, but I expect the subclasses to override it."* -- Sometimes this can be okay.  This is a warning sign of too much up-front design.  I would proceed very carefully.

## Mixins: *has-a* vs *is-a*

<b>Mixin</b> is a design pattern that corresponds to a way to handle multiple inheritance in a clean way.  (Of course, if programmers don't understand singular inheritance then they definitely don't understand multiple inheritance!)

With a mixin, shared functionality is put into a Mixin class.  I like to think of mixins as showing a *has-a* relationship on a class (this comes from fellow racker Srijak).

Let's suppose you have some functionality for handling Users in your system.

```java
public class BaseWorker {

     public User getUser(String username) {
             // get user from DB
     }

     public User createUser(String username) {
             // add row to DB and create User object
     }

     public boolean deleteUser(String username) {
             // delete user from DB
     }
}

public class MyWorker extends BaseWorker {

	public void run(String username) {
		User u = super.getUser(username);
	}
}
```

Let's pull out all of the user-specific operations into its own UserMixin class.  Now every time the subclass (or parent class) needs to access a user function, they talk to the UserMixin instead of calling the functions that were previously baked into the superclass.

```java
public class UserMixin {
	public User getUser(String username) {
		// get user from DB
	}

	public User createUser(String username) {
		// add row to DB and create User object
	}

	public boolean deleteUser(String username) {
		// delete user from DB
	}
}

public class BaseWorker {

	protected UserMixin userMixin = new UserMixin();
}

public class MyWorker extends BaseWorker {

	public void run(String username) {
		User u = this.userMixin.getUser(username);
	}
}
```

Except of course the above is the well-known 'service' construct.  Let's inject the `UserService` into the constructor of `BaseWorker`.

```java
public class UserService {
	public User getUser(String username) {
		// get user from DB
	}

	public User createUser(String username) {
		// add row to DB and create User object
	}

	public boolean deleteUser(String username) {
		// delete user from DB
	}
}

public class BaseWorker {

	protected UserService userService;

	public BaseWorker(UserService userService) {
		this.userService = userService;
	}
}

public class MyWorker extends BaseWorker {

	public MyWorker(UserService userService) {
		super(userService);
	}

	public void run(String username) {
		User u = this.userService.getUser(username);
	}
}
```

With the `UserService` pulled out and put in the constructor,  we can mock it out and write effective unit tests for parent class and subclass, as well as wire it together with a dependency injection framework.

This third example is a **fundamental** pattern in writing modern OO software, but when we teach inheritance and structuring OO programs, it is usually not mentioned.  Why are we springing this on programmers only when they get to the industry?

We are already take class time to teach *is-a* with numerous examples about why Circle should not be a subclass of Ellipse.  Let's also take the time to teach new programmers *has-a* and why dependency injection is an important pattern to learn in structuring their object oriented programs.

## Notes

In dynamic languages such as Python, 'mixins' are often used as just multiple inheritance, with mixin functions being added to the namespace of the class that is 'mixing in' the others.  This use of mixins breaks dependency injection unless you are 'mixing in' only the mixin field (basically).

Scala traits are similar to mixins.  I think that traits (essentially these are Haskell's type classes) are a great alternative to inheritance in most situations, but like inheritance, the main purpose of a trait is to enable writing a polymorphic code rather than to pull out the dependencies of a class.  [Dependency injection](http://jonasboner.com/2008/10/06/real-world-scala-dependency-injection-di/) is possible for Scala traits, but with a little more overhead than I'd like to see.  I think it would be interesting to see how general trait/type-class mocking can be made.
