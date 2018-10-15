---
layout: post
title: 'For Which Primes is 2 a Square?'
comments: true
---

We work in the integers mod some odd prime $$p$$, and we start squaring things.  It turns out that some numbers show up when we do this, and some don't: for example, the numbers mod 5 are 0, 1, 2, 3, 4, and their squares are 0, 1, 4, 4, and 1.  Since 4 shows up in this list, 4 is a square mod 5, but 2 doesn't show up, so 2 is not a square.

If you're given a $$p$$, it turns out to be relatively easy to test if a number is a square: just square everything and see if the number you're looking for shows up.  But what about the reverse problem: given a number $$a$$, for which primes $$p$$ is $$a$$ a square?  This is the _quadratic residue_ problem, one of the most famous problems in elementary number theory.

In this article I'll show how to determine the primes for which the number 2 is a square, which follows a proof given in [A Classical Introduction to Modern Number Theory, Ireland and Rosen](https://www.springer.com/us/book/9780387973296).  The proof relies on using complex roots of unity, which feels like a total non-sequitor after digging through a few chapters of congruences and mainly applications of classical algebra.  Like all things math, I feel like this reveals some deep structure that requires a certain state of enlightenment to grasp.

## Preliminaries

Looking over the first few primes see that 2 is not a square for $$p = 3, p = 5, p = 11, p = 13$$ but is a square for $$p = 7, p = 17, p = 23$$.

Let $$(a / p)$$ (the _Legendre symbol_) be 0 if $$a = 0$$, 1 if there is some $$x$$ such that $$x^2\equiv a\ (p)$$, and -1 otherwise.  Determining when 2 is a square means determining the $$p$$ for which $$(a / p) = 1$$.

The key observation is that $$a^{(p - 1)/2} \equiv (a / p)\ (p)$$.  This uses some group theory: every number $$a^{p-1} \equiv 1\ (p)$$ (_Fermat's Little Theorem_), so $$(a^{(p-1)/2})^2 = 1$$, meaning that it can only take on two possible values modulo $$p$$, 1 and -1.

## The Proof

Take $$\zeta = e^{2\pi i / 8}$$, a complex eighth root of unity which satisfies $$\zeta^8 = 1$$.  Note that $$\zeta^4 = -1$$ so $$\zeta^2 = -\zeta^{-2}$$.  Consider the expression $$\zeta + \zeta^{-1}$$ (this is just adding a number to its complex conjugate, so it's a real number).  Squaring this value yields $$(\zeta + \zeta^{-1})^2 = \zeta^2 + 2 + \zeta^{-2} = 2$$.

$$
\begin{eqnarray*}
(2/p) &\equiv& 2^{(p-1)/2}\ (p)\\
      &\equiv& (\zeta + \zeta^{-1})^2)^{(p - 1)/2}\ (p)\\
      &\equiv& (\zeta + \zeta^{-1})^{p - 1}\ (p)\\
\end{eqnarray*}
$$

(Since $$\zeta$$ is an _algebraic integer_ - a root of a polynomial with integer coefficients - the concept of congruences can be shown to make sense.)

Multiplying both sides by $$\zeta + \zeta^{-1}$$ gives:

$$
\begin{eqnarray*}
(2/p)(\zeta + \zeta^{-1}) &\equiv& (\zeta + \zeta^{-1})^p\ (p)\\
                          &\equiv& \zeta^{p} + \zeta^{-p}\ (p)
\end{eqnarray*}
$$

(This uses the simplification $$(x + y)^p \equiv x^p + y^p\ (p)$$ - this is possible because the binomial coefficients all being mod $$p$$ and so zero out.)

Next, we split into cases based on the value $$p$$ has congruent to 8.  Since $$p$$ is an odd prime, it can only take on four possible values: $$p \equiv 1, 3, 5, 7\ (8)$$.

$$
\zeta^{p} + \zeta^{-p} = \left\{
\begin{array}{cc}
\zeta + \zeta^{-1} & p \equiv 1, 7\ (8)\\
\zeta^{3} + \zeta^{-3} = -(\zeta + \zeta^{-1}) & p \equiv 3, 5\ (8)
\end{array}
\right.
$$

This gives the result:

$$
(2/p)  = \left\{
\begin{array}{cc}
1 & p \equiv 1, 7\ (8)\\
-1 & p \equiv 3, 5\ (8)
\end{array}
\right.
$$

Verifying this with [Sage](http://www.sagemath.org/) and choosing a random prime off a [list of small primes](https://primes.utm.edu/lists/small/10000.txt), we see:

```
sage: 102929 % 8
1
sage: 2 in quadratic_residues(102929)
True
```

We can also verify the pattern holds for the first 100 primes:

```
sage: P = Primes()
sage: for i in range(0, 100):
....:     p = P.unrank(i)
....:     print(p, p % 8, 2 in quadratic_residues(p))
....:
(2, 2, False)
(3, 3, False)
(5, 5, False)
(7, 7, True)
(11, 3, False)
(13, 5, False)
(17, 1, True)
(19, 3, False)
(23, 7, True)
(29, 5, False)
(31, 7, True)
(37, 5, False)
(41, 1, True)
(43, 3, False)
(47, 7, True)
(53, 5, False)
(59, 3, False)
(61, 5, False)
(67, 3, False)
(71, 7, True)
(73, 1, True)
(79, 7, True)
...
```

## References


* Kenneth Ireland and Michael Rosen, _A Classical Introduction to Modern Number Theory_ (2nd Edition)
