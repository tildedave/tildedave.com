---
layout: post
title: 'The Joy of Field Extensions'
comments: true
---

One of my projects this year was learning Galois Theory, a subject in abstract algebra that goes into the structure of the roots of polynomial equations.  In high school I learned that $$x^2 + 1 = 0$$ had no solutions in the real numbers, but - good news! (massive leap of faith here) there's some number $$i$$ so that $$i^2 + 1 = 0$$ is satisfied.  Oh and by the way, $$(-i)^2 + 1 = 0$$ also.

It turns out that by adding $$i$$ to the real numbers you end up with this number system $$\mathbb{C}$$, the complex numbers.  These behave similar to the familiar real numbers except that for any polynomial that describes a complex relationship there's this transformation _complex conjugation_ that turns one number satisfying the polynomial into another different number.

For example $$x^3 - 2 = 0$$ has three solutions in the complex numbers, one is $$\sqrt[3]{2}$$, but it turns if you take $$\omega$$ to be a complex number such that $$\omega^3 = 1$$, the other solutions to $$x^3 - 2 = 0$$ are $$\omega\sqrt[3]{2}$$ and $$\omega^2\sqrt[3]{2}$$, and it just so happens that $$\omega\sqrt[3]{2}$$ is complex conjugate to $$\omega^2\sqrt[3]{2}$$.  So the solutions to polynomial equations end up having this hidden structure to them that you might not have expected originally.

## Jury Rigging Fields

The basic idea of a field extension is that you take a field (numbers can be multiplied, added, and divided with one another), adjoin extra elements to it, and see what the new object looks like.  Generally you work in $$\mathbb{Q}$$ which are the the rational numbers (1, -2, 3/4, 1/2, but no square roots, no crazy imaginary elements, etc).

The idea then is to take some polynomial that has no solutions in the "base field", for example there are no rational numbers that satisfy $$x^3 - 2 = 0$$.  So you say, "okay, since there's no $$x$$ such that cubing it is 2, let's add an element that does and see what comes of it".  We'll call that number $$\sqrt[3]{2}$$ and add it to $$\mathbb{Q}$$.  This ends up getting us a new field $$\mathbb{Q}[\sqrt[3]{2}]$$.

What does this new field look like?  Well, it's a field, it has all the same familiar rational numbers, but it also has this crazy new number $$\sqrt[3]{2}$$.  Since it's a field it has $$ 1 / \sqrt[3]{2}$$, and it also has all algebraic combinations of $$\sqrt[3]{2}$$ with every other element in the field including itself.  So this number system has all these new numbers $$(\sqrt[3]{2})^2$$, $$(13 / \sqrt[3]{2})^8$$, $$(1 + \sqrt[3]{2})/17$$, and so on.  It's still a number system like you're used to, there's just this new number along for the ride, and it turns out if you cube it you get $$2$$.  Normal enough.

It turns out that for any field $$K$$ and any irreducible polynomial $$p(x)$$ (with coefficients in $$K$$), you can create a new field $$L = K[x]$$ where $$x$$ is a root of the irreducible polynomial.  (The choice of what this $$x$$ 'actually is' - for example if you consider what it is in projection into the complex numbers - ends up not mattering, there's a theorem that all "stem fields" are the same.)

## That's No Field...

Of course, mathematicians love it when they can recognize existing systems in new structures.  It turns out you can view a field extension as a vector space over the original field - so our field $$K$$ with all its new numbers is really a vector space with basis vectors $$1, \sqrt[3]{2}, (\sqrt[3]{2})^2$$.  If you go back to all our "new numbers" we got, it turns out that each of these can be expressed as a combination of these basis vectors with constants from the base field $$\mathbb{Q}$$.

Since our field extension is now a vector space it makes sense to talk about its _dimension_, which in linear algebra is the size of its basis.  Our extension $$x^3 - 2$$ has dimension 3 because it has 3 basis vectors.  It turns out that when you take an irreducible polynomial of degree $$n$$ and adjoin it to a base field $$K$$ the resulting vector space has degree $$n$$ as well.

## Extensions of Extensions

Looking back at the original polynomial $$x^3 - 2$$ we notice it only has 1 solution in $$\mathbb{Q}[\sqrt[3]{2}]$$.  In the complex numbers it has 3 solutions - $$\sqrt[3]{2}, \omega\sqrt[3]{2}, \omega^2\sqrt[3]{2}$$.  So how we create a structure which has all three solutions?

It turns out that in the structure $$\mathbb{Q}[\sqrt[3]{2}]$$ the polynomial $$P = x^2 + (\sqrt[3]{2})x + (\sqrt[3]{2})^2$$ has no solutions, so we take a new element $$x$$ that satisfies this equation (\if you call it $$\omega\sqrt[3]{2}]$$ all the equations work out) and adjoin it to $$\mathbb{Q}[\sqrt[3]{2}]$$, getting us this new structure $$\mathbb{Q}[\sqrt[3]{2}, \omega\sqrt[3]{2}]$$.  This new structure ends up having all 3 roots for $$x^3 - 2$$.

Since both $$\sqrt[3]{2}$$ and $$\omega\sqrt[3]{2}$$ are elements of this new field so is the $$\omega$$ element ($$\omega = \omega\sqrt[3]{2} \cdot 1/\sqrt[3]{2}$$). Since $$\omega^3 = 1$$ it also satisfies some strange-looking relationships: $$\omega^{-1} = \omega^2$$ and $$\omega^2 = -(\omega + 1)$$.  This shows us that the second root of the polynomial $$P$$ is expressable as $$-(\omega + 1) \cdot \sqrt[3]{2}$$.  So the members of this new field end up as being expressable as linear combinations of $$1, \omega, \sqrt[3]{2}, (\sqrt[3]{2})^2, \omega\sqrt[3]{2}, \omega\sqrt[3]{2}$$ with coefficients from $$\mathbb{Q}$$.  Thus the dimension of the new structure over the rationals is 6.

Since $$\omega$$ is a member of $$\mathbb{Q}[\sqrt[3]{2}, \omega\sqrt[3]{2}]$$ we know there's also a subfield of $M$ that contains the rationals and $$\omega$$ (dimension 2).  Are there any other subfields?  (Maybe some combination of $$\omega$$ and $$\sqrt[3]{2}$$?)

It turns out there's this great theorem that helps explain the structure of fields and their subextensions. Let $$K$$ be a field, let $$L$$ an extension of $$K$$ and $$M$$ an extension of $$L$$.  Then:

<div class="theorem" text="Tower Law">
$$[M : K] = [M : L][L : K]$$
</div>

Since $$M$$ over $$K$$ has dimension 6 we know by the Tower Law that there can't be any subfields of dimension 4 - 4 doesn't divide 6.  We can go through the divisors of the dimension of $$M$$ to find all of its subfields.  The final structure ends up looking like:

<p><img class="img-responsive" style="display: block; margin: auto; max-width: 500px" src="/images/field-extension-subfields.svg" /></p>

So, even though we constructed $$M$$ by bolting on $$\sqrt[3]{2}$$ and then $$\omega\sqrt[3]{2}$$, there's another way to construct it by bolting on $$\omega$$ and then $$\sqrt[3]{2}$$.  It doesn't matter what order you go, you get the same structure at the end.

## Conclusion

Field extensions are a way that you take one well-behaved structure and get another well-behaved structure.  Irreducible polynomials are key to this as they express relationships that aren't satisfied in the original structure but do end up satisfied in the new structure.

Field extensions actually end up being a really powerful tool - their theory can be used to show the impossibility of angle trisection with a compass and straightedge.  The basic idea: start with numbers 0 and 1, allow constructing numbers in the complex plane through compass and straightedge.  The only numbers that are constructible this way exist in field extensions that have dimension $$2^n$$ over the rationals.  However, to trisect the angle $$2\pi/3$$, we would need to be able to construct a number ($$\cos {2\pi / 9}$$) that exists in a field extension of dimension 3 over the rationals.  Therefore general trisection is impossible.

## References

* Ian Stewart, _Galois Theory_ (4th Edition)
