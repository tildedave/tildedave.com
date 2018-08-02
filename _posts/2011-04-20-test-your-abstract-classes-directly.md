---
layout: post
title: 'Test Your Abstract Classes Directly'
is_unlisted: 1

---

With a good mocking framework, the only limitation to testing your favorite OO system is how your dependencies are structured.  Any time you are writing code that does some unit of work, there should be a test for it, and that test should match your requirements for that particular piece of code.

However, it is not always obvious how to test a piece of code!

A common situation I find myself in is in testing an abstract base class with a fair amount of logic.  The subclasses have very little logic of their own: maybe overriding a callback or adding some specific behavior at some point along the way in the computation.

Testing the subclasses here provides minimal value.  The real unit of work in this system is in the abstract class.

A true unit test infrastructure for this inheritance structure should include:

* test for all the implemented methods of the abstract class, no matter how they are overridden
* tests for all the overridden behavior in the subclasses

However, abstract classes cannot be instantiated as they are missing the implementations for one or more of their methods.  How can we test the logic in the superclass without writing redundant tests?

## The Setup

Let's consider a situation where we have a page for display photos.

* By default, 10 photos are displayed at once
* There is a special "favorite" photo slot for each group of 10.
* The page has backend actions "next page", "previous page", "display all photos", and "display photo range".

```java
public abstract class PhotoAction {

   public ActionForward execute(HttpRequest request) {
      List<Photo> photos = getPhotoList(request);
      request.setAttribute("photoList", photos);
      request.setAttribute("favorite", favoritePhoto(photos));
      setPageAttributes(request);
   }

   private Photo favoritePhoto(List<Photo> photos) {
      for(Photo p : photos) {
         if (p.getRating() == 10) {
             return p;
         }
      }

       return p.get(0);
   }

   public abstract List<Photo> getPhotoList(HttpRequest request);
   public abstract void setPageAttributes(HttpRequest request);
}

public class NextPagePhotoAction extends PhotoAction { ... }
public class PreviousPagePhotoAction extends PhotoAction { ... }
public class AllPhotosAction extends PhotoAction { ... }
public class RangePhotoAction extends PhotoAction { ... }
```

Each of the four classes of `PhotoAction` will set attributes in the page in a different way and get the photo listing in a different way.  However, there is shared functionality between the photo list, namely getting the favorite photo.

We want to verify:

* The 'shared core' of the subclasses in the abstract class
* Each of the subclasses behaves correctly

## Take 1: Test Inheritance

I've done this (and seen this!) too many times in the past.  I do not recommend it.

```java
public abstract class PhotoActionTest {

   @Test
   public void testGetsFavoritePhoto() {
       // test logic
       PhotoAction photoAction = getPhotoAction();
   }

   abstract public PhotoAction getPhotoAction();

}

public class NextPhotoActionTest extends PhotoActionTest {

   // other tests

   @Override
   public PhotoAction getPhotoAction() {
      return new NextPhotoAction();
   }
}
public class PreviousActionTest extends PhotoActionTest { ... }
public class AllPhotoActionTest extends PhotoActionTest { ... }
public class RangePhotoActionTest extends PhotoActionTest { ... }
```

In the above setup, each concrete instantiation of `PhotoActionTest` inherits `testGetsFavoritePhoto` and instantiates `getPhotoAction` to return an instance of the class they are testing.

I don't like this setup for a few reasons:

* Four tests executed for one test of functionality
* Inheritance hierarchy for tests makes no real sense

Test inheritance is something you should use very very carefully.  I view tests as setup, execute, assert loops -- they are scripts and there are no real opportunities for real object polymorphism.  Do not introduce test inheritance into your codebase without being very sure that you know what you are doing!

(I have used test inheritance to prevent code duplication for setup/test construction, which is a programming sin -- not a true application of Liskov substitution.  Unfortunately, I have not found a clear way to handle this better... for now.)

## Take 2: Abstract Stubbing

My favorite way to do this is to stub out the abstract class.

```java
public abstract class PhotoActionTest {

   List<Photo> photoList;

   @Before
   private void setUp() {
       this.photoList = mock(List.class);
   }

   @Test
   public void testGetsFavoritePhoto() {
       // test logic
       PhotoAction photoAction = getPhotoAction();
       // do things
       // verify the right operations were called on photoList
   }

   public PhotoAction getPhotoAction() {
      return new PhotoAction() {
         public List<Photo> getPhotoList(HttpRequest request) {
            return PhotoActionTest.photoList;
         }

         public void setPageAttributes(HttpRequest request) { }
      }
   }

}
```

In the above code we directly test the abstract class's functionality by stubbing out the abstract portions of `PhotoAction`.  For each of the subclasses of `PhotoAction` we can add specific tests that test the inherited methods `getPhotoList` and `setPageAttributes`, allowing the test hierachy for these classes to be specific and focused on the specifics of the overriden implementation.

### Postscript

For languages that do not support anonymous inner classes, a specific subclass, defined as an inner class to the test class, will have to be used.

The overridden stub methods should only do completely general operations, i.e. return general lists.

For testing abstract generic I recommend instantiation with the most general object types, i.e. `ClassDecl<U>` would be tested at an instantiation of `ClassDecl<Object>`, `OtherClassDecl<V extends Foobar>` at `OtherClassDecl<Foobar>`.
