---
layout: post
title: "Fixing a JNI Crash in sqlite-jdbc"
comments: true
---

It began with my phone waking me up at 5am in the morning with a phone call from PagerDuty.  The Java service I maintain had suffered from a hard crash; the JVM had just died.  After some quick diagnosis everything is on its way to recovery: [supervisor](http://supervisord.org/) starts the service back up and it's like nothing ever happened.  I don't think much of it until the next day, when PagerDuty calls me again at the exact same time for the exact same reason.

Chartio runs a Java service (for historical reasons named "Dullboy") to retrieve charting data from customer databases.  Java is a good choice for this because basically every database makes a [JDBC](https://www.oracle.com/technetwork/java/javase/jdbc/index.html) driver available, meaning that it's generally straightforward to connect to a new type of database: download driver, write a small amount of integration code, and boom, you're getting chart data.

Each chart also gets written into (and read out of) in-memory SQLite, which unlocks some cool product behavior: in particular, Chartio's ability to join data across multiple databases is implemented by writing data into two different SQLite tables and performing an in-memory join.  However, SQLite is written in C, meaning that in order to use it we need to call into it through the Java Native Interface (JNI).  We use the [sqlite-jdbc](https://github.com/xerial/sqlite-jdbc) library to do this.

JNI code has the unique ability to make things go sideways.  Dullboy is nice and safe in Java code - it runs a bunch of HTTP threads in a Jetty servlet container, we monitor a number of nice things (heap memory used, number of active threads, garbage collector time), it's decently covered by tested, and we have pretty decent error handling.  After you call into C, you have none of those things.  You don't know how much memory is being allocated.  Any memory you do allocate won't be garbage collected.  That memory isn't being garbage collected.  There are no logs being written saying what's happening.  In the distance, a wolf howls.

In my scenario, what's happening is that we have a scheduled job, running at 5am, that calls into SQLite, which does _something_, which then causes the service to die.

## Investigation, and a "Fix"

Through some stroke of luck we determine which chart is causing the service to die (this can frequently be challenging given the number of charts running at any given time).  It's actually a pretty straightforward configuration: do some queries, determine the MEDIAN value of one column.  We're able to make it fail in a test environment, and with a little more digging I've got a [sample project](https://github.com/tildedave/sqlite-jdbc-crash) reproducing the crash.

Hilariously, all that's required is generating a bunch of random floating point numbers, sorting them in descending order, and then running the `MEDIAN` function.  It *doesn't* crash if I sort it in ascending order.  It *doesn't* crash if I just insert in random order.  But it does crash if I sort it from largest to smallest.

```java
List<Double> values = new ArrayList<>();

Random r = new Random();
for (int i = 0; i < 50_000; i++) {
    values.add((double) (r.nextInt(1_400_000)));
}
values.sort((o1, o2) -> -o1.compareTo(o2));

SQLiteConnection connection =
    (SQLiteConnection) DriverManager.getConnection("jdbc:sqlite::memory:");

// Create a table with double values
try (Statement stmt = connection.createStatement()) {
    stmt.execute("CREATE TABLE table_0(\"num\" real NOT NULL)");
}

// Insert the doubles into the table
String insertSQL = "INSERT INTO table_0 VALUES (?)";
try (PreparedStatement stmt = connection.prepareStatement(insertSQL)) {
    for(Double value: values) {
        stmt.setDouble(1, value);
        stmt.execute();
    }
}

// Crash!
try (Statement stmt = connection.createStatement()) {
    stmt.execute("SELECT MEDIAN(\"num\") FROM table_0");
}
```

(But wait, isn't SQLite supposed to be super stable?  No bugs?  Turns out the `MEDIAN` function is not a core SQLite function but is specified through a contributed file which is "use at your own risk".)

I do some an strace of my function and the last signals the process gives out before dying are:

```
[pid 23956] --- SIGSEGV {si_signo=SIGSEGV, si_code=SEGV_ACCERR, si_addr=0x7fda523caff8} ---
[pid 23956] --- SIGSEGV {si_signo=SIGSEGV, si_code=SI_KERNEL, si_addr=0} ---
```

Looking around the internet it seems that this indicates a stack frame violation (ominous foreshadowing music).

So, we have only one customer chart crashing, the median of a dataset is the same regardless of the sort order, and I've got a bunch of other things to do.  I update the chart configuration to sort the data in the reverse order (stops the crash while still returning the right value), open an [issue](https://github.com/xerial/sqlite-jdbc/issues/418) on Github for this strange behavior, and declare temporary victory.  I then go off to do other work.  A small part of my brain wonders what my thesis advisor would say.

## Four Months Later

Of course, I didn't actually solve the problem, so the crash returns a few months later.  (Thankfully this time it's at 9am intead of 5am.)  Through similar logging forensics we determine that it's another chart performing a `MEDIAN` computation.  I roll up my sleeves and it's back to it.

This time I dig through the code which supplies the `MEDIAN` function, supplied in [extension-functions.c](https://github.com/tildedave/sqlite-extension-functions/blob/664b39199ce65363d9fa152cb388a0558545d588/extension-functions.c).  Median is an aggregate function and code involves interacts with a binary tree with left and right children pointers.

```c
typedef struct node{
  struct node *l;
  struct node *r;
  void* data;
  int64_t count;
} node;

typedef struct map{
  node *base;
  cmp_func cmp;
  short free;
} map;
```

It's like I'm back in CS225 in undergrad!  Squinting a bit I parse through the code, add a bunch of fprintf stderr statements, and eventually track down the function where it's crashing:

```c
void node_iterate(node *n, map_iterator iter, void* p){
  if(n){
    if(n->l)
      node_iterate(n->l, iter, p);
    iter(n->data, n->count, p);
    if(n->r)
      node_iterate(n->r, iter, p);
  }
}
```

A little more diagnosis shows that this function isn't segfaulting, it's hitting a stack frame violation (as I should have remembered from my earlier strace).

What's a stack frame violation?  Every function call pushes some information onto the application stack.  (This is how previous local values are still around when returning from a function call!)  When running the code you only have so much space available for the stack, generally set through `rlimit`.  In the JVM the default stack size can be set through `-XX:ThreadStackSize` - some blog post I found indicated that 512k was a [typical default size](http://xmlandmore.blogspot.com/2014/09/jdk-8-thread-stack-size-tuning.html).

A little inspection of the code makes the strange sorting behavior more clear.
* If the data is randomly inserted, the tree roughly has height $$\log(n)$$ which isn't enough to cause a stack frame error.
* If the data is sorted from smallest to greatest, every `n->l` pointer is NULL, meaning only recursive calls to `n->r` are done.  These calls are in the tail position so calling them doesn't push a stack frame (they're basically a GOTO).
* If the data is sorted from greatest to smallest, the tree has height $$n$$ and every call to `node_iterate(n->l, iter, p)` pushes a new frame on the stack, causing everything to crash.

Fixing this is straightforward - I dust off the part of my brain that knows C and put together the following, which just removes the recursion to explicitly use a stack:

```c
typedef struct node_stack{
  node *n;
  struct node_stack *next;
} node_stack;

node_stack* node_stack_create(node *n);
void node_stack_push(node_stack **stack, node *n);
node* node_stack_pop(node_stack **stack);

void node_iterate(map *m, map_iterator iter, void* p){
  node *n = m->base;
  node_stack *s = node_stack_create(n);
  node_stack **stack = &s;
  while(*stack || n){
    if(n){
      node_stack_push(stack, n);
      n = n->l;
      continue;
    }
    n = node_stack_pop(stack);
    n = n->r;
  }
}
```

Recompile, run my test, and nothing's crashing any more.  (Well, I actually had to fix a separate function with roughly the same issue).

## Conclusion

While this alert ended up taking me places, I don't consider this as a particularly difficult problem to fix.  All the source code involved was open source (not the case for some of the JDBC drivers we integrate with - those issues are the stuff of nightmares), and I was able to reproduce the issue pretty quickly on my own.

However, it was a bit of a _different_ issue from the usual stuff.  The cause of the issue ended up being one of those things I learned early on in computer science education and then completely forgot about.  (Like many industry devs, I generally don't use recursion since newer languages provide high-order iteration patterns.)  The SQLite layer of our system ends up being such a black box that it's great to have been able to dig into the guts and come back with a more or less complete understanding of the cause and the solution of this particular problem.

As a postscript: I'm not sure if we're actually going to end up using this updated C code.  The `MEDIAN` function in `extension-functions.c` is actually implemented quite inefficiently.  I reimplemented it in Java in about a half hour - storing each element in an array, sorting it, then taking the middle value ends up being a lot faster than the C implementation.
