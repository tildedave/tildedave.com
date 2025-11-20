---
layout: post
title: "I'm Still Bad At OCaml"
---

It's been 10 years since I wrote anything serious in OCaml and going through [Everybody Codes](https://everybody.codes/) this year I figured I would give it another shot.  I've always been an "advanced beginner" at OCaml, where I was able to program in it but not particularly well.  I wrote one of my thesis projects in OCaml; [simp](https://github.com/tildedave/simp) (the code no longer makes sense to me, thank goodness) and it ended up having some performance problems that sunk a paper acceptance back in the day; I rewrote it in C++ when we revised the paper.

Unfortunately, I am still awful with this language.  I don't like the way my code looks, I don't like the syntax, and I don't like where it sits in the functional programming landscape.

Interacting with data structures is still horribly verbose and I hate how much code looks.  Here's breadth-first search, adapted from Wikipedia.  Yes, it's using the imperative data structures (more on this later).
```ocaml
let fold m ~init ~f ~neighbors start =
  let queue, visited, acc = (Queue.create (), Hash_set.create m, ref init) in
  Queue.enqueue queue start;
  while not (Queue.is_empty queue) do
    let next = Queue.dequeue_exn queue in
    if not (Hash_set.mem visited next) then (
      Hash_set.add visited next;
      acc := f !acc next;
      List.iter
        ~f:(fun neighbor ->
          if not (Hash_set.mem visited neighbor) then
            Queue.enqueue queue neighbor)
        (neighbors next))
  done
```
After using Clojure and its universal `conj`, `assoc`, `contains?` idioms that work polymorphically on data structures, it's _so_ painful to have to type `Hash_set.mem` around every hash set interaction.  Yes, it some places you can reduce the boilerplate with local opens, but no such luck here; `Queue` and `Hash_set` define conflicting members and the last one wins.

Syntax-wise, I am never quite sure what level of precedence `;` has.  Does `if cond then stmt1; stmt2` mean do `stmt2` only when `cond` is true or not?  I am convinced that the language always chooses the opposite of whatever would be the prettiest code.  At least `ocamlformat` is a new addition to the dev chain.  I add parenthesis _everywhere_ I think there might be some ambiguity and it removes the unnecessary ones for me.

After doing every Advent of Code puzzle in Clojure, I (finally) consider myself a competent functional programmer.  But Clojure and its laziness force you to structure your code in very interesting ways, and I only fell back to mutability when there was no other way; some very specific dynamic programming or linked list requirements, basically.

Lazy data structures also let you do computation in a special way, where you define a function producing a value (forever) and then consume the first N cycles in another function.  In eager OCaml I'm sitting here doing computation in explicit for loops (essentially), just like any other language.  Because OCaml's data structures are all eager, I just don't see much of a benefit to using the functional ones.  I often just use the imperative stuff because they tend to have fewer hoops to jump through.

Positives: the type system is still fun, though any interaction with the module system required for hash tables is still dire.  If my code type checks, it probably works.  [Dune](https://github.com/ocaml/dune) is _finally_ a good toolchain.  [ppx_deriving](https://github.com/ocaml-ppx/ppx_deriving) lets you avoid writing a lot of really silly code for custom data structure equality.

I'm going to stick with OCaml through the end of 2025's Everybody Codes puzzles (I want to give the language a few more tries), but this is probably my last attempt to make the language work.  I can't think of a thing that I think would be more fun to program in this language than some other alternative.  Now that the modern languages have adopted the type systems and cool syntax from ML,  one of the originals no longer has much of an edge.
