---
layout: post
title: 'Pattern: Stubbing Legacy Superclasses with Mockito Spies'
is_unlisted: 1

---

Let's be honest: in practice, dealing with inheritance can be a pain.  Functionality that violates "is-a" relationships gets put into base classes for convenience, with applications built around extending these base classes.  When superclasses have not been built with inversion of control in mind, unit testing your subclass is difficult.

## The Setup

Here's a not-too-uncommon (from the code I've worked on in academics
and real work) situation.

* Your class is expected to extend a superclass because that's how the application is structured.
* The superclass has vital logic that you don't want to (or can't -- it's in another .jar) refactor.
* You have not given up the idea of writing unit tests yet.  [don't give up!](http://www.youtube.com/watch?v=uiCRZLr9oRw)

For clarity, here's some example code.  We have a BaseWorker for handling requests on some queuing system.  There is an amount of common infrastructure built around how BaseWorker interacts with the outside world, but basically none of this is important when writing a new worker.

```java
public abstract class BaseWorker {
     public void JDBCConnection connection;

     protected JDBCConnection getDatabaseHandle() {
          return connection;
     }

     protected User getUserInfo(String username) {
          Rows row = connection.executeQuery( ... );
          // complicated logic to parse rows and retrieve
          // User data
     }

     public abstract void run(String arg);
}
```

```java
public class PhotoWorker extends BaseWorker {
    public void run(String username) {
           User user = this.getUserInfo(username);
           List<Photos> photos = user.getPhotos();
           // process photos, etc
    }
}
```

Every worker will probably call `this.getUserInfo` in the superclass,
which has an external dependency on the database.  To write a good
unit test (without pulling our hair out!), we can't get involved with
this database dependency.  The main problem is: how to unit test
PhotoWorker without playing games with the superclass's external
dependencies?

## Test Design One: Anonymous Inner Classes

Until recently, in order to unit test `PhotoWorker`, I
would have instantiated it as an anonymous inner class.  This
overrides the superclass's behavior, and if you put a mock in there
you can make your superclass do whatever you want.

```
public class PhotoWorkerTest {
    User mockUser;

    @Before
        public void setUp() {
        mockUser = mock(User.class);
    }

    public PhotoWorker getPhotoWorker() {
        return new PhotoWorker() {
            @Override
            protected void getUser(String name) {
                return mockUser;
            }
        };
    }

    @Test
    public void processesNoPhotosCorrectly() {
        PhotoWorker worker = getPhotoWorker();
        when(mockUser.getPhotos()).thenReturn(new LinkedList());
        worker.run("bob");
        // verify etc
    }
}
```

While this does what I want it to (anonymous inner classes are usually
very good at this!), it is not general.  If I were writing 10
different workers I would have to write this same override concept for
all 10 of them (and declare 10 different User mocks, etc).

Because whatever superclass behavior you want to override when must be
declared when you instantiate that anonymous inner class, there is no
'clean' way to write a `BaseWorker` test utility that takes
a class and returns one with the proper behavior stubbed out.

## Test Design Two: Mockito Spies

One of my favorite new hammers when dealing with unruly superclasses
is mockito's
[spy](http://docs.mockito.googlecode.com/hg/org/mockito/Mockito.html#13)
concept.  This allows you to mock out part of a real class in a clean
way (at least in how you specify your tests!)

Just a general note: spies should NOT be used for new code!  They
should *only* be used for testing the legacy components of your
classes.  New code should be written cleanly with all external
dependencies declared in the constructor so that this functionality
can be controlled with proper mock objects.

```java
public class PhotoWorkerTest {
    User mockUser;

    @Before
        public void setUp() {
        mockUser = mock(User.class);
    }

    public PhotoWorker getPhotoWorker() {
        PhotoWorker worker = spy(new PhotoWorker());
        doReturn(mockUser).when(worker).getUser(any(String.class));
        return worker;
    }

    @Test
        public void processesNoPhotosCorrectly() {
        PhotoWorker worker = getPhotoWorker();
        when(mockUser.getPhotos()).thenReturn(new LinkedList());
        worker.run("bob");
        // verify etc
    }
}
```

The syntax is much cleaner here.  Based on comments on the mockito documentation, I prefer to write my spy `when` clauses backwards: if one form of `when` specification works half the time I would just prefer the code to be consistent.

Again however, if we want to set up a number of different `BaseWorker` subclass tests, we are out of luck: we will have to write the above `doReturn` clause in each one.

<h3>Test Design Three: Generic Stubber</h3>

Using Java's generic system, we can write a generic stubber that you can then reuse in all of your other subclass tests.  Here's an example of how this might work.

```java
public class BaseWorkerStubber<T extends BaseWorker> {

    T worker;
    User user;

    public BaseWorkerStubber(T worker) {
        this.worker = spy(worker);
        this.user = mock(user);
        doReturn(user).when(this.worker).getUser(any(String.class));
    }

    public User getUser() {
        return user;
    }

    public T getWorker() {
        return worker;
    }
}

public class PhotoWorkerTest {

    public BaseWorkerStubber<PhotoWorker> getPhotoWorker() {
        return BaseWorkerStubber<PhotoWorker>(new PhotoWorker());
    }

    @Test
    public void processesNoPhotosCorrectly() {
        BaseWorkerStubber<PhotoWorker> stubber = getPhotoWorker();
        LinkedList<Photo> emptyList = new LinkedList<Photo>();
        when(stubber.getUser().getPhotos()).thenReturn(emptyList);
        stubber.getWorker().run("bob");
        // verify etc
    }
}
```

If you need more specific setup, instead of initializing the `when` clauses in the constructor, you can add a `setup` function or create static factory methods that do more specific setup.

## Conclusion

Mockito spying can be a cleaner way to write unit tests for classes that have their functionality intermingled with their superclass.  By taking advantage of Java's generics system, we can create general test utilities classes that reduce the amount of copy/paste setup needed when writing your unit test.

### A Note on Other Languages

For .NET, a cursory Google search indicates that [Moq](http://code.google.com/p/moq/) supports spies.  The only other Java-specific example used above is the `<T extends BaseWorker>` construct, which has a [natural analogue](http://msdn.microsoft.com/en-us/library/dd799517.aspx) in .NET.

I wouldn't recommend using inheritance in Python at all because of the [optional nature](http://fuhm.net/super-harmful/) of superclass initialization.
