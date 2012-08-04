---
layout: post
title: 'How Useful is Theory to the Professional Programmer?'

---

One of the things that I love about working at Rackspace is how much of a focus there is on expanding your skillset.  There are frequent technical talks and a lot of opportunities to expand your skillset.  If you want to learn something about a specific technology that is part of our stack (or even a little outside of it), there is usually someone down the hall that can start you on your journey.

In discussing things that we'd like to learn next, invariably I hear people talk about how they would like to do more work with data structures and algorithms, and I can understand why.  Graph algorithms are fascinating and usually easy to implement, and a lot of datasets have a natural graph representation.  During undergraduate, I would half-start writing a graph library at least 3 times.  At the time I was really interested in graph visualization and wanted to implement some of the drawing algorithms I would dig up from papers in various math journals.

## In Academics

I ended up even more interested in programming language theory.  The work that became my thesis grew out of the question of applying a stronger type system (security-enabled Java) to existing code bases (Java).  The main programming that I used in accomplishing this was in applying graph algorithms more-or-less straight out of [CLRS](http://www.amazon.com/Introduction-Algorithms-Second-Thomas-Cormen/dp/0262032937): max-flow, transitive closure, depth-first search to prune useless nodes.  There was some extra work to compute dominators in order to better present potential cut-sets to the user.

My thesis was a project where knowing my theory helped.  The methods were not new, but they did require a familiarity with the material, especially when trying out algorithms that may or may not have generated publishable results.

## In the Industry

The issues that computer science theory is interested in  (runtime complexity, space complexity) are not generally useful programming in the industry.  Software will 'live beyond you'.  This makes the social dynamics different:

### It has to be simple to read (and change!) your code

Unless there is a commitment to hiring programmers with a specific skillset (for example, you are a compiler company), you have to be writing code for all the programmers that maintain the code after you have left the project.  Favor library methods and standard solutions for design and deployment unless you have _proven_ that these will not work for you.

### You can't optimize the entire stack at once

The modern application stack has a lot of elements.  Javascript, Tomcat/Jetty, your favorite controller framework, your favorite data persistence layer, external services that your application is dependent on ... there are a lot less opportunities for 'instant wins', where by increasing program complexity in one place you achieve an acceptable performance tradeoff.

### Hardware is cheaper than programmers

If you're working for a bigger company, it's probably going to be cheaper to use a less efficient algorithm than to hire a programmer to maintain and understand more complicated code.  (All bets are off on this one for video game programmers...)

I think it's great that computer science theory still has a hold on all of our minds, but the skills required to perform research in computer science and do well at things like [Google Codejam](http://code.google.com/codejam/) are very different from the skills required to build and deploy the kind of application that we work on from day to day.

There are hard and interesting problems outside of theory and data structures (how can I structure my programs?  how do I separate responsibilities?  how do I effectively test this?) that don't quite have the same hold on the imagination of the professional programmer, probably because they are challenges that we deal with every day.  However, these are the skills that we all can improve.

I think where we, as an industry, have work to do is in showing that the kinds of questions we deal with every day can be as enticing and have as conceptually satisfying solutions as computer science theory problems.
