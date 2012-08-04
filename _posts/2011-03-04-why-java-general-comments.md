---
layout: post
title: 'Why Java: general comments'

---

Java doesn't get a lot of respect from developers nowadays -- as any programming thread regarding the language will indicate, it is not the new hotness.  As the drum beats onwards towards more dynamic and interfaceless languages, it is worth examining the things that make Java worthwhile as a <i>programming language</i>.  I believe that Java is a reasonable choice for a developer, even one that is interested in more 'modern' programming languages.

## Reasons to Choose Java

### Clear Syntax

Very few syntactic forms make it easy to understand what is being done.  There are no global variables or user-specified syntax modification.  The few ambiguous forms (static imports) should generally not be used outside of testing code.

### Powerful Tools

Integrated editors like IntelliJ, Netbeans, and Eclipse hook into the virtual machine and can provide an experience similar to read-eval-print loops (REPLs) in other languages.  Mature unit testing and mainstream AOP support.</li>

### Type System

Static types and separate .class compilation together make it easy to manage large projects.  Type System is expressive enough to give most classes the 'correct' types.  Error messages are generally extremely clear.  Generics allow for extremely flexible libraries without getting deep into "STL hell".  The type system enables editors to provide powerful refactoring tools that can be used without fear of breaking compilation: Eclipse's "extract method", "extract local variable", "extract interface", "rename method", "rename class", etc.

## Common Objections

### Verbosity

While Java is often verbose in comparison with other languages, this verbosity is a product of the syntax's C++ heritage.  Scala, Haskell, and OCaml/SML are each languages with powerful type systems (more powerful than Java's).  Each of them has type inference as a fundamental part of the language.

I believe that if Java were designed today it would likely have syntax closer to Scala's, though obviously I cannot speak for the original Java design board.

### AbstractFactoryFactoryInterfaces

Java has a reputation for complicated class structures.  Part of this because in idiomatic OO, developer guidelines like the Single Responsibility Principle (SRP) and Inversion of Control (IoC) encourage extra classes that are generally very small, making it hard to figure out where the beef is in a particular project.

Lots of Java projects are poorly structured.  However, SRP and IoC are critical for maintaning a large codebase.  Inversion of Control allows for your classes to actually be tested through mock objects, while the Single Responsibility Principle reminds us all to keep classes short and sweet.

You can write bad code in any language.  As an industry standard, there are a lot of Java programs out there and a lot of Java programmers.  A bad programmer will be a bad programmer in Java, Python, Ruby, and C++ (probably an even worse programmer in C++).  Java has had the chance to build up a lot of legacy code over the last ten years.  It's a pretty good bet that if you know any language well enough, some day you will be asked to maintain some ugly code written in that language.</li>

### Static Type System Too Unwieldy

My preferred time to locate many common classes of bugs, such as type errors, is at compile time.  I also feel that there is an advantage in specifying an object's interface 'up front' instead of extracting one later from the use of an object in the code.  As projects get bigger these concerns become more important.

## A Note on the JRE

The JVM as a platform does not need defending.  There are countless projects in other languages that attempt to port their languages to the JVM (Jython, JRuby), or design/work on VMs that mimic major functionality of the JVM (<a href="http://rubini.us/">Rubinius</a>).

