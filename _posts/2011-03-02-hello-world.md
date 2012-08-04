---
layout: post
title: 'putStrLn "hello, world"'

---

I am going to attempt to write down longer thoughts specific to programming in the enterprise and whatever comes my way in part-time hacking.

I'm sure that the speed of posts will be slow, but I am hoping to dig at some things about our profession that I don't feel are often well-addressed by my daily reading.

## Minor Thoughts

* I have come around to Java as the best 'compromise' language available.  There are a lot of warts with Java 15 years in, but in my opinion it is still capable of expressing object oriented concepts better than any other available language [1].

* Haskell seems to have a 'silver bullet' of sort for future program language design -- I believe that explicitly expressing data dependency through the monadic style can lead to a new generation of languages and runtimes.  The main challenge going forward is specifying these dependencies in a way that does not involve mentioning any concepts from category theory.

* I am interested in seeing how functional languages can scale to a decent size (30,000+ SLOC) and still end up as (relatively) easy to understand as a well-written object-oriented application.  Many concepts that enable scalability in OO (unit tests/mocks/dependency injection) do not have direct analogues.

[1] I do not presently have experience with .NET; however my understanding is that any statement about Java/JVM can be translated into a statement about C#/.NET.
