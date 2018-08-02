---
layout: post
title: 'Mutually Recursive Modules in OCaml (and why you might care)'
is_unlisted: 1

---

I keep looking for a new OCaml project.  It hits a lot of sweet spots that are not matched by other languages: idiomatic functional programming, static types, powerful compiler, [syntax extensions](http://caml.inria.fr/pub/old_caml_site/camlp4/index.html), and the language's mindset allows for stateful solutions to problems when these are the most natural.

Throughout this post I will use the running example of evaluating an abstract syntax tree for an imperative language.  Once a file has been lexed and parsed, the structure that you are left with is an *abstract syntax tree*, an internal data structure that encompasses what your program semantically means.

Evaluating an imperative language like JavaScript, Java, C, C++, etc involves separating out:

* *expressions* that evaluate to a value: `1 + 1`, `ptr->field`.
* *statements* that change state or transfer control: `a = 1`, `if (!ptr) { log_error(); }`.

Statements contain expressions: right-hand-side of the assignment `a = 1` is a integer literal.

JavaScript contains first class functions:

```javascript
var a = function (i) {
    // anonymous function
    return i * 2;
}
```

The enclosing `function` is an expression (a value that can be assigned and passed as an argument to another function).  The body of a function is a set of statements.  Therefore to evaluate expressions, we must evaluate statements -- and to evaluate statements, we must evaluate expressions.

This creates a mututal dependency between the two concepts.  Languages handle mutual recursion differently -- generally the more static checking/code generation that is done, the more annoying a concept this is to solve.

* C and C++ require forward definitions of functions
* It just works in Java as long as the two mutually recursive functions are part of the same compilation unit
* Ruby, Python, and JavaScript don't care because they don't check your code for undefined symbols before executing

Functional languages treat functions as values, and so in most languages, if two functions depend on each other they must be defined together.  This is not always the case, but it is the case for the two main statically typed functional languages, OCaml and Haskell.

I believe that most of the time static checking is the right thing and so when we hit these kind of obstacles we should try our best to write code in the correct fashion.

## Take 1: Mutually Recursive Functions

A standard approach to dealing with mutually recursive concepts is to write a mutually recursive functions.  Evaluation is then a series of functions:

* `val evaluate_expr : state -> expression -> value * state`
* `val evaluate_stmt : state -> statement -> state`

```ocaml
let rec evaluate_expr st expr =
  match expr with
   | ExpFn (args,body) -> as_value expr
   | ExpFnCall (rator,rands) ->
         let (ExpFn (args,body), st') = evaluate_expr st rator and
             evalled_rands = List.map evaluate_expr st' rands in
             evaluate_stmt (subst body evalled_rands args) st'
   | (* other stuff here *)
and evaluate_stmt st stmt  =
  match stmt with
   | StmtSeq (s1,s2) -> evaluate_stmt (evaluate_stmt s1) s2
   | StmtVarDecl (var,exp) ->
           let (val,st') = evaluate_expr exp st in
               update st' var val
    (* more statement types etc *)
```

Most of the time when I have written an interpreter in OCaml this has been the pattern that I've used.  It is straightforward and good for small language specifications.

However, as the language you are interpreting gets bigger, you have more problems.  Because of the recursive nature of the above setup, all of the parsing functions must be declared in the same compilation unit.  With 10-15 different types of expressions and 20 types of statements -- not a ridiculous setup in most modern languages -- your logic is very tied together and you will end up with some very large files.

Large files are bad and need to be avoided.  We need to constantly be asking ourselves: why are these different pieces of logic in the same file/class/module?

## Take 2: Mutually Recursive Modules

In a functional programming language the main unit of abstraction is a mathematical function from inputs to outputs.  (Contrast this with other languages like Java/C# where the main unit of abstraction is an object -- or C, where the language enforces hardly any units of abstraction at all.)

Modules group functions together and allow for information hiding.  Here's an example signature for our expression and statement evaluators:

```ocaml
module type Expr =
sig
   val evaluate_expr : state -> expression -> value * state
end

module type Stmt =
sig
   val evaluate_stmt : state -> statement -> state
end
```

When modules connect with each other, the Statement evaluation module can deal with the Expression evaluate module only through a signature, rather than requiring it to know precisely which function is being invoked.

Our above code thus looks like:

```ocaml
module ExprEvaluator : Expr (S:Stmt) =
struct
  let evaluate_expr st expr =
    match expr with
     | ExpFn (args,body) -> as_value expr
     | ExpFnCall (rator,rands) ->
         let (ExpFn (args,body), st') = evaluate_expr st rator and
             evalled_rands = List.map evaluate_expr st' rands in
             S.evaluate_stmt (subst body evalled_rands args) st'
     | (* other stuff here *)
end

module StmtEvaluator : Stmt (E:Expr) =
struct
  let evaluate_stmt st stmt  =
    match stmt with
     | StmtSeq (s1,s2) -> evaluate_stmt (evaluate_stmt s1) s2
     | StmtVarDecl (var,exp) ->
           let (val,st') = E.evaluate_expr exp st in
               update st' var val
      (* more statement types etc *)
end

(* instantiate modules *)
module rec StmtEvaluatorImpl = StmtEvaluator(ExprEvaluatorImpl)
and ExprEvaluatorImpl = ExprEvaluator(StmtEvaluatorImpl)
```

Here `ExprEvaluator` and `StmtEvaluator` are *functors*: a term's more esoteric than it actually is.  A functor is simply a module (group of functions) that talks to a signature (a module interface).  It's like if you had to parameterize your Java class with the interfaces it used to make an interface Impl.

First set up your modules with the signatures that they talk to, and then parameterize your modules via applying the functors -- similar to dependency injection through [Spring](http://www.springsource.org/) in Java or Python.

The recursive module syntax above binds the instantiations to each other, allowing us to completely separate the expression evaluation logic from the statement evaluation logic.  This is a feature since [OCaml 3.07](http://caml.inria.fr/pub/docs/manual-ocaml/manual021.html#toc75).  There is an equivalent setup in [Haskell](http://www.haskell.org/haskellwiki/Mutually_recursive_modules).

## Conclusion

I think that functional languages are very good at selling the basic problems that they solve: many operations that we end up doing are more easily expressed as list operations, monads, lazy computation.  However, as they get bigger some of these more advanced language features (modules, mutual recursion) pop up and it is important to embrace and understand these concepts just as much as 'simple' language concepts like first class functions.

Recursive modules may not be for every problem, but there are a lot of places where they are the right way to separate out dependencies between different abstract concepts.  We should use abstraction and information hiding in functional languages as much as we stick to abstraction and information hiding in object oriented languages.


