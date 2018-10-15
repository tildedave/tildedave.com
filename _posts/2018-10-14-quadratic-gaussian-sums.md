---
layout: post
title: "Quadratic Gaussian Sums"
comments: true
---

Let $$p$$ be an odd prime.  I'll now show how sums over complex roots of unity can be used to show the law of _quadratic reciprocity_, which states that $$p$$ being a square mod $$q$$ is related to whether $$q$$ is a square mod $$p$$.

Let $$(p / q)$$ be the Legendre symbol: it takes on the value 0 if $$p$$ is 0, $$1$$ if $$p$$ is a square mod $$q$$, and $$-1$$ otherwise.  We'll be seeing what happens when you sum up some complex roots of unity and square the resulting value.  I am following the proof given in [A Classical Introduction to Modern Number Theory, Ireland and Rosen](https://www.springer.com/us/book/9780387973296).

## Summing Complex Roots of Unity

Let $$\zeta$$ be a complex $$p$$-th root of unity $$\zeta = e^{2\pi i/p}$$.  The quadratic Gaussian sum is the value $$g_{a} = \sum_{t} (t/p) \zeta^{at}$$.

Why might this be useful?  It's not hard to show that for all $$a$$, $$g_a = (a/p)g_1$$, meaning that we can recover the value $$(a/p)$$ by knowing the value of $$g_a$$.

For example, when $$p = 5$$:

$$
\begin{eqnarray*}
g_1 &=& \zeta - \zeta^{2} - \zeta^{3} + \zeta^{4}\\
g_2 &=& \zeta^{2} - \zeta^{4} - \zeta^{6} + \zeta^{8} = \zeta^{2} + \zeta^{3} - \zeta^{4} - \zeta &=& -g_1\\
g_3 &=& \zeta^{3} - \zeta^{6} - \zeta^{9} + \zeta^{12} = \zeta^{2} + \zeta^{3} - \zeta^{4} - \zeta &=& -g_1\\
g_4 &=& \zeta^{4} - \zeta^{8} - \zeta^{12} + \zeta^{16} = \zeta + \zeta^{4} - \zeta^{2} - \zeta^{3} &=& g_1\\
\end{eqnarray*}
$$

2 and 3 are non-residues mod 5, so the sign of the quadratic Gaussian sum $$g_2$$ and $$g_3$$ is negative.

**Lemma:** $$g_a = (a/p)g_1$$

**Proof:**  We only consider the case where $$a$$ is coprime to $$p$$.

$$\left(\frac{a}{p}\right) g_a = \sum_{t} \left(\frac{at}{p}\right) \zeta^{at} = \sum_{x} \left(\frac{x}{p}\right) \zeta^{x} = g_1$$

(Because $$p$$ is a prime and $$a$$ is coprime to $$p$$, $$at$$ must take on all values $$1, 2, \ldots, p - 1$$ mod $$p$$).  Multiplying both sides by $$\left(\frac{a}{p}\right)$$ gives the desired result.  $$\tag*{$\Box$}$$


**Lemma:** $$g_1^2 = (-1)^{(p - 1)/2} p$$

**Proof:** To show this, we evaluate $$\sum_{a} g_{a}g_{-a}$$ in two different ways.  Again we only focus on $$a$$ coprime to $$p$$.

First, by the previous lemma, we have $$g_{a}g_{-a} = (a/p)(-a/p) g_1^2 = (-1/p) g_1^2$$.  Summing over all $$a$$ gives us $$\sum_{a} g_{a}g_{-a} = \left(\frac{-1}{p}\right)(p-1)g^2$$.

Direct expansion gives:

$$g_{a}g_{-a} = \sum_{x} \sum_{y} \left(\frac{x}{p}\right) \left(\frac{y}{p}\right) \zeta^{a(x - y)}$$

When summing this term over $$a$$, terms where $$x \not\equiv y\ (p)$$ vanish, since these end up summing over all roots of unity.  For each $$x$$, when $$x \equiv y\ (p)$$, there are $$p$$ terms.  Therefore:

$$\sum_{a} g_{a}g_{-a} = \sum_{x} \left(\frac{x}{p}\right) \left(\frac{x}{p}\right) p = (p - 1)p$$

Therefore $$(p - 1)p = \left(\frac{-1}{p}\right)(p-1)g^2$$.  Cancelling terms of $$p - 1$$ and multiplying both sides by $$(-1/p)$$ gives the desired result.  (By Fermat's little theorem we have $$(-1/p) = (-1)^{(p-1)/2}$$.)
$$\tag*{$\Box$}$$

## Quadratic Reciprocity

We are in a place to prove the law of quadratic reciprocity, which links the values $$\left(\frac{p}{q}\right)$$ and $$\left(\frac{q}{p}\right)$$.

<div class="theorem" text="Quadratic Reciprocity">
$$\left(\frac{p}{q}\right)\left(\frac{q}{p}\right) = (-1)^{((p-1)/2)((q-1)/2)}$$
</div>

If either $$p$$ or $$q$$ are $$\equiv 1\ (4)$$, the right hand side is $$1$$, and $$p$$ is a residue in $$q$$ if and only if $$q$$ is a residue in $$p$$.  Let $$p = 13$$ and $$q = 17$$ - it happens that $$17 \equiv 4\ (13)$$.  $$4$$ is a square mod $$13$$ ($$2^2 \equiv 4\ (13)$$) and $$13$$ is a square mod $$17$$ ($$8^2 \equiv 13\ (17)$$).

However, if both $$p$$ and $$q$$ are $$\equiv 3\ (4)$$, then the relationship is flipped: $$p$$ is a residue in $$q$$ if and only if $$q$$ is not a residue in $$p$$.  For example, $$p = 7$$ and $$q = 23$$: $$23 \equiv 2\ (7)$$ and 2 is a square mod $$7$$ ($$3^2\equiv 2\ (7)$$, but $$7$$ is not a square mod $$23$$.

**Proof:**
Let $$p' = (-1)^{(p - 1)/2} p$$.  By the above lemma we have $$g_1^2 = p'$$.  Take $$q$$, another odd prime.  Then we have:

$$g_1^{q-1} = (g_1^2)^{(q-1)/2} = p'^{(q-1)/2} \equiv \left(\frac{p'}{q}\right)\ (q)$$.

Multiplying both sides by $$g_1$$ gives:

$$g_1^{q} \equiv \left(\frac{p'}{q}\right)g_1\ (q)$$

Since we are examining congruences modulo $$q$$, we can "push" the exponent down into the sum, giving, $$g_1^{q} = g_{q} = (q/p)g_1\ (q)$$ as per our first lemma.  Therefore we have:

$$
\begin{eqnarray*}
\left(\frac{q}{p}\right)g_1 &\equiv& \left(\frac{p'}{q}\right)g_1 \ (q)\\
\left(\frac{q}{p}\right)g_1^2 &\equiv& \left(\frac{p'}{q}\right)g_1^2 \ (q)\\
\left(\frac{q}{p}\right)p' &\equiv& \left(\frac{p'}{q}\right)p' \ (q)\\
\left(\frac{q}{p}\right) &\equiv& \left(\frac{p'}{q}\right) \ (q)\\
\left(\frac{q}{p}\right) &=& \left(\frac{p'}{q}\right)\\
\end{eqnarray*}
$$

The value $$\left(\frac{p'}{q}\right)$$ can be seen to equal $$(-1)^{((q-1)/2)((p - 1) / 2)} \left(\frac{p}{q}\right)$$ as $$p' = (-1)^{(p-1)/2} p$$: therefore $$p'$$ is a residue mod $$q$$ if both $$(-1)^{(p-1)/2}$$ and $$p$$ are residues mod $$q$$ or they are both non-residues.  Arranging terms gives the desired result.

$$\tag*{$\Box$}$$

## Notes

Quadratic reciprocity is what really hooked me on my study of the Ireland and Rosen textbook.  The previous few chapters had been about congruences and the structure of subrings of integers - interesting stuff but sort of dry, and not too different from the standard abstract algebra I had covered in undergrad.

However, _this_ theorem sort of came out of left field:  it seemed strange that $$p$$ being a square mod $$q$$ would be related at all to $$q$$ being a square mod $$p$$ - especially given that one of these numbers is larger than the other!  (When you talk about $$p$$ being a square mod $$q$$, it's actually a statement about $$p$$'s coset in the integers mod $$q$$.)

There are a few different proofs presented in the textbook, but the presentation of quadratic Gaussian sums struck me as exceptionally simple.  The Legendre symbol initially seemed to me as a strange thing to include in the sum terms, but it can be shown that the Legendre symbol is just an example of a _multiplicative character_, which maps a finite field into the unit circle in a way that preserves multiplication.  The unit circle hooked me on trigonometry back in high school and I love seeing it appear again and again.
