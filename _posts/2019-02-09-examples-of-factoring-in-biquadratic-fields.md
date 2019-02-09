---
layout: post
title: "Examples of Factoring in Biquadratic Fields"
comments: true
---

This is a solution to Exercises 4.6 and a partial solution to exercise 4.7 in Daniel A. Marcus, _Number Fields_.

Let $$K = \mathbb{Q}[\sqrt{m}, \sqrt{n}]$$ be a field extension of the rational numbers $$\mathbb{Q}$$.  $$K$$ has degree 4 and contains three quadratic subfields: $$\mathbb{Q}[\sqrt{m}]$$, $$\mathbb{Q}[\sqrt{m}]$$, and $$\mathbb{Q}[\sqrt{k}]$$, where $$k = \frac{mn}{\text{gcd}(m, n)^2}$$.  The Galois group of this field extension is the Klein 4-group, which has three normal subgroups.  Let $$p$$ be a prime of $$\mathbb{Z}$$.  Take $$R$$ to be the ring of integers of $$K$$.

Let $$P$$ be a prime ideal with $$Q$$ a prime lying over $$Q$$.  If $$K$$ is a normal extension of the rationals with Galois Group $$G$$, then the decomposition group $$D$$ of $$P$$ is the subgroup of $$G$$ containing all $$\sigma$$ such that $$\sigma(Q) = Q$$.  The inertia group $$E$$ for a prime ideal $$P$$ is the subgroup of $$G$$ containing all $$\sigma$$ such that $$\sigma(\alpha) \equiv \alpha\ \text{mod}\ Q$$ for $$\alpha$$ an algebraic integer of $$K$$.

## Background: Factoring in Quadratic Fields

Let $$m$$ be a squarefree integer.

Let $$p = 2$$.  $$p$$ ramifies if $$m \equiv 0, 2, 3\ (4)$$ since the discriminant of the quadratic subfield is even in these cases.  $$2R$$ splits if $$m \equiv 1\ (4)$$.

Let $$p$$ be an odd prime.  If $$p \mid m$$, then $$p$$ ramifies.  If $$m$$ is a quadratic residue mod $$p$$, then $$p$$ splits in $$\mathbb{Q}[\sqrt{m}]$$.  Otherwise $$p$$ remains prime (_inert_).

## $$p$$ ramified in every subfield

If $$p$$ is ramified in each of the subfields then $$p$$ is totally ramified in $$K$$.  $$p$$ being totally ramified implies that the both the decomposition and inertia groups of $$p$$ over $$R$$ are the entire Galois group.

An example over $$\mathbb{Q}$$ is $$m = 2$$ and $$n = 3$$, so $$K = \mathbb{\sqrt{2}, \sqrt{3}}$$.  $$K$$ then contains the subfields $$K_1 = \mathbb{Q}[\sqrt{2}]$$, $$K_2 = \mathbb{Q}[\sqrt{3}]$$, and $$K_3 = \mathbb{Q}[\sqrt{6}]$$ with corresponding ring of integers $$R_1, R_2, $R_3$$ and discriminants $$8, 12, 24$$.  The regular prime $$p = 2$$ ramifies in each of these subfields.

We can confirm this in Sage:

```
sage: for i in [2, 3, 6]:
....:     print(QuadraticField(i).ideal(2).factor())
....:
(Fractional ideal (a))^2
(Fractional ideal (a + 1))^2
(Fractional ideal (-a + 2))^2
sage: L = QQ.extension(x^2 - 2, 'a').extension(x^2 - 3, 'b')
sage: L.absolute_polynomial()
x^4 - 10*x^2 + 1
sage: L = QQ.extension(x^4 - 10*x^2 + 1, 'a')
sage: L.ideal(2).factor()
(Fractional ideal (-1/2*a*b + 1/2*a - 1))^4
sage: G = L.galois_group()
sage: L.primes_above(2)
[Fractional ideal (-1/4*a^3 + 1/4*a^2 + 9/4*a - 9/4)]
sage: G.decomposition_group(L.primes_above(2)[0]).order()
4
sage: G.inertia_group(L.primes_above(2)[0]).order()
4
```

## $$p$$ splits completely in every subfield

If $$p$$ splits completely in each subfield, then it will split completely in the composite field (Marcus, Theorem 31).  The decomposition group of $$p$$ is the empty subgroup - every element of the Galois group permutes a prime lying over $$p$$ it to a different prime lying over $$p$$, so no permutations fix the primes over $$p$$.

To find an example, we note that for $$p$$ to split completely in every subfield, it must not divide the discriminant of each subfield, and each subfield must be a quadratic residue mod $$p$$.

Let's take $$p = 131$$ (I just wanted to try a larger number than the usuals ;)), and observe using Sage that $$15, 21,$$ and $$35 = \frac{15 \cdot 21}{\text{gcd}(15, 21)^2}$$ are each quadratic residues mod $$131$$, so $$131$$ will split completely in each subfield.

We then confirm through Sage that 131 splits completely each subfield and then over the biquadratic field $$\mathbb{Q}[\sqrt{15}, \sqrt{21}]$$:

```
sage: for m in [15, 21, 35]:
....:     print(QuadraticField(m).ideal(131).factor())
....:
(Fractional ideal (-3*a + 2)) * (Fractional ideal (3*a + 2))
(Fractional ideal (5/2*a + 1/2)) * (Fractional ideal (5/2*a - 1/2))
(Fractional ideal (-2*a + 3)) * (Fractional ideal (2*a + 3))
sage: L = QQ.extension(x^2 - 15, 'a').extension(x^2 - 21, 'b')
sage: L.ideal(131).factor()
(Fractional ideal ((1/3*a - 1)*b + 2*a - 7)) * (Fractional ideal ((-1/6*a - 1)*b + 3/2*a + 7)) * (Fractional ideal ((1/3*a - 3/2)*b + a - 11/2)) * (Fractional ideal ((1/3*a + 1)*b - a - 2))
```

## $$p$$ inert in every subfield

This scenario can never occur.  If $$p$$ were inert in every subfield, then the decomposition group of $$p$$ would be the entire Galois group, while the inertia group would be the empty subgroup.  There would then be a surjective mapping from $$D / E = G$$ onto a cyclic group of order 4 (the inertial degree of $$p$$), but this contradicts what we know about the structure of the Galois group (the Klein 4-group is not cyclic).

## $$p$$ splits into two primes $$p_1 p_2$$

We need $$p$$ to split in one subfield and be inert in another.  Take $$p = 13, m = 3, n = 5$$.  Here $$m = 3$$ is a quadratic residue mod 13, but $$n = 5$$ is not.  Therefore 13 stays inert in $$\mathbb{Q}[\sqrt{5}]$$ but splits in $$\mathbb{Q}[\sqrt{3}]$$.  Sage confirms that 13 has the desired form in the biquadratic field:

```
sage: for m in [3, 5]:
....:     print(QuadraticField(m).ideal(13).factor())
....:
(Fractional ideal (a + 4)) * (Fractional ideal (a - 4))
Fractional ideal (13)
sage: QQ.extension(x^2 - 5, 'a').extension(x^2 - 3, 'b').ideal(13).factor()
(Fractional ideal (b + 4)) * (Fractional ideal (b - 4))
```

Note that since $$15 \equiv 2\ (13)$$ is not a quadratic residue mod 13, 13 stays inert in $$\mathbb{Q}[\sqrt{15}]$$, so this provides a scenario where a prime can be inert in two fields (here the quadratic subfields $$m = 5, n = 15$$) but not be inert in their composite (Marcus, Exercise 4.7 (c)).

## $$p$$ splits into two primes $$p_1^2 p_2^2$$

We need $$p$$ to split in one subfield and ramify in another.  Take $$p = 7, m = 2, n = 14$$.  Here $$m = 2$$ is a quadratic residue mod $$7$$, and the quadratic field $$\mathbb{Q}[\sqrt{14}]$$ will have a discriminant divisible by 7, since 7 divides 14.

```
sage: for m in [2, 14]:
....:     print(QuadraticField(m).ideal(7).factor())
....:
(Fractional ideal (-2*a + 1)) * (Fractional ideal (2*a + 1))
(Fractional ideal (-2*a + 7))^2
sage: QQ.extension(x^2 - 14, 'a').extension(x^2 - 2, 'b').ideal(7).factor()
(Fractional ideal ((1/2*a - 3/2)*b + 1/2*a - 1))^2 * (Fractional ideal (1/2*b - 1/2*a + 2))^2
```

The third quadratic subfield of $$K$$ is $$\mathbb{Q}[\sqrt{7}]$$, where $$7$$ is totally ramified.  This provides an example where a prime can be totally ramified in two fields (here the quadratic subfields $$m = 7, n = 14$$) but not totally ramified in their composite (Marcus, Exercise 4.7 (a)).

## $$p$$ ramifies as $$p_1^2$$

We need $$p$$ to ramify in one subfield and be inert in another.  Take $$p = 13, m = 5, n = 13$$.  5 is not a quadratic residue mod 13, so 13 will stay inert in that quadratic subfield.  Sage confirms:

```
sage: for m in [5, 13]:
....:     print(QuadraticField(m).ideal(13).factor())
....:
Fractional ideal (13)
(Fractional ideal (-a))^2
sage: QQ.extension(x^2 - 5, 'a').extension(x^2 - 13, 'b').ideal(13).factor()
(Fractional ideal (-b))^2
```
