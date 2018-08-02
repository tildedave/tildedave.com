---
layout: post
title: 'Why Java: Simple Syntax Leads To Clear Concepts'
is_unlisted: 1
---

I'll start with a bold claim:

<blockquote>Java is unwieldy when it comes to doing complicated operations.  This is often a very good thing.</blockquote>

My experience is that the limited number of syntactic forms in Java make it generally very easy to determine what unknown code is doing, assuming method and class breakdowns are sane.  This, combined with a lower ratio of lines of code to work done, results in syntax that, while sometimes elaborate, is an aid for the working programmer.  If you run into complicated Java code, it is usually a sign that the concepts you are dealing with are not clear.

As software professionals, we must identify what higher level operations we performing and give these operations their own names.  Very few operations that we run into while implementing domain logic are truly unwieldy.  This is the main difference between programming and school and programming for a career: very little is as unclear as the rules for B-tree delete! (Assuming your manager and business representatives are doing their jobs right...)

## More Not Always Less: Syntax in Functional Languages

**Doing more things in less lines is not a virtue by itself!**  It is only a virtue when the abstractions that the language allows are clear and unambiguous.  The 'sweet spot' for including new syntactic forms appears to be around `String` handling.  These features in Java are bulky compared with other "friendlier" languages (Python, Ruby, Perl, PHP, JavaScript).

Functional languages make it *very* easy to chain a lot of functionality into very few expressions.  `fold` takes a list, a starting value, and an accumulator that takes two arguments: the accumulated value and the current list element.  The idiomatic way to solve many problems in functional problems involve folding the result of a mapped or filtered list.  If programmers are not careful, code can quickly spiral out of control.

Here's some Ocaml code from one my thesis projects.  The code takes a vertex cut (`vset`) (vertices corresponding with one side of a graph cut) and a graph and creates a `CutSet` object based on these edges.  This is done through folding over a graph and finding all of the edges that bridge the cut/uncut part of the code.

(Of course, this is not an indictment of Ocaml!  This is just an example of how dense Ocaml code can be, combined with some very bad programming discipline on my part!)

```ocaml
let cutset_from_vertex_cut vset graph =
  FlowGraph.fold_edges_e
    (fun edge -> fun set ->
       let src,dst = FlowGraph.E.src edge,
                        FlowGraph.E.dst edge in
	 if (Enumerater.VS.mem src vset) &&
            not (Enumerater.VS.mem dst vset) then
	   CutSet.add (CutSet.edge_to_cut_elem edge) set
	 else
	   set)
    graph
    CutSet.empty
```

There two main factors that, in my opinion, interfere with readability in functional languages:

* **culture**: short function names are the norm in functional libraries.  Functional programmers tend to be more 'mathy' and concepts in functional languages often require understanding complicated semantics.
* **mindset**: when you are chaining functions together it is very easy to end up with a function that "does too much".  Adding a new function composition is a very innocent operation compared with adding a new class member.

I enjoy functional programming, but I think it is harder to recognize a 'clean' solution as I find functions less intuitive to think about.  Perhaps some day we will figure out what the functional analogue for SOLID is...

## The Java Gutcheck: Why is so much going on here?

In Java, once you start doing anything complicated, the way you express the program in the language starts to get very awkward.  Once what you are writing gets awkward it is a good sign that you should re-examine some basic facts (the Discordians would call this 'consulting your pineal gland'):

* What am I trying to accomplish?
* Why is this hard?
* What is the one responsibility that this class has that requires me to write this code?
* Is this code its own responsibility (and thus, its own class)?

If you are writing a controller for a web framework:

* are you playing just the 'traffic cop', or are you making ORM calls that are their own conceptual unit? (use a Repository or Service!)
* has the 'business logic' crept into your code?  (put it in the Repository!)
* are you spending too much time formatting data for your templating engine? (use a View Model!)

These are the correct instincts to have when working on large projects; abstract concepts that repeat throughout the code must be given names, common functionality pulled out, and your differentiator must be tested.

Java will never be a good language for writing elegant [Project Euler](http://projecteuler.net/) problems, but it will quickly let you know when your code is doing too much, if you listen to what it is telling you.
