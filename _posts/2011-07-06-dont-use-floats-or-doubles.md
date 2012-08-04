---
layout: post
title: 'Don''t Use Floats or Doubles*'

---

* Obviously programs involved with computer graphics, simulations, statistics, and scientific computing need to use floats and doubles for a lot of reasons.  If you're not doing one of those things, read on!

A major code smell is using IEEE 754 floating point numbers when an accurate representation is required.  Most tasks I deal with in programming customer-facing webapp require accurate representation of units and I believe most programmers are not clear on what the built-in floating point types for a language actually provide.

## Doubles Do Not Store Precise Values

Let's check [Wikipedia](http://en.wikipedia.org/wiki/Double_precision_floating-point_format).  A 64 bit floating point number is represented in the computer by:

* 1 sign bit
* 11 exponent bits
* 53 'signficands'

You get 53 bits of precision, stored in a binary format.  Specifically, if \(e\) is the exponent, \(s\) is the sign, and \(b_0, ..., b_{53}\) are the bits of the significand, the number \(d\) is stored as

    d = (-1)^{s} * 1.b_0 b_1 b_2 ... b_{53} * 2^{e-1023}

This is great if the number you are storing is expressable as a whole number or a finite sum of binary fractions.  Unfortunately, most numbers do not satisfy this.  In fact, pretty much any number doesn't satisfy this.

Let's check out the Clojure REPL to see what's going on underneath the surface of `java.lang.Double`.

```clojure
user=> (Double/toHexString 2.0)
"0x1.0p1"
user=> (Double/toHexString 0.5)
"0x1.0p-1"
user=> (Double/toHexString 0.2)
"0x1.999999999999ap-3"
user=> (Double/toHexString 0.3)
"0x1.3333333333333p-2"
```

The numbers \(0.2\) and \(0.3\) have inexact representations on the machine level because they are not expressable as a finite sum of powers of 2.  Notice that the powers of 2 (\(2.0\) and \(0.5\)) do just fine.

## Don't Cast Doubles to Floats

This just makes a bad decision worse -- you are truncating away significant digits by converting from a 64 bit representation into a 32 bit representation.

## Never, ever, ever use Floats or Doubles for Money

Money needs to be precise.  IEEE 754 digits were never intended to serve as precise values.  Every language has an arbitrary precision arithmetic library.  Use that library instead.

Still bad is using floats and doubles in measuring things that result in a payment, or measure a payment.  Prefer integer/long values for this when possible, measured in atoms -- the smallest unit of measurement in your system (bytes of bandwidth in, teraflops, compute cycles, whatever).

**If you are writing code that involves money, never *ever* use floats or doubles.**

## Do the Right Thing

<a href="http://docs.racket-lang.org/reference/numbers.html">Racket</a> has the concept of an exact (arbitary precision) and inexact (IEEE 754) number.  Unfortunately exact numbers can become inexact numbers when involved with certain arithmetic operations.

For Java, use [BigDecimal](http://download.oracle.com/javase/1,5.0/docs/api/java/math/BigDecimal.html).  For Ruby, use [BigDecimal](http://www.ruby-doc.org/stdlib/libdoc/bigdecimal/rdoc/index.html).  For Haskell, use [Data.Decimal](http://hackage.haskell.org/packages/archive/Decimal/latest/doc/html/Data-Decimal.html#t:DecimalRaw).  For C++, consider [GMP](http://gmplib.org/).
