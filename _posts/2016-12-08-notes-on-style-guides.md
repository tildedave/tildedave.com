---
layout: post
title: 'Notes on Style Guides'
is_unlisted: 1
---

A style guide is a tool that designers use to standardize on visual design elements and interaction patterns.  Style guides are used by companies to convey a unified "sense of product" - the Apple visual style for their boxes and advertisements is very distinctive.  The fonts, colors, and logos are all unified - so much so that you "know" it's Apple blurring your eyes and looking at the new [MacBook Pro](http://www.apple.com/macbook-pro/) page.

At medium-to-larger sized companies, style guides exist so that designers can have a common language that allows innovation while ensuring that one designer's work still maintains that visual "feel".  You might have a company with ten designers - that means you have ten very unique individuals that somehow still have to produce work that looks roughly the same, often while working in verticals where they are interfacing with engineers, marketing, or product team members.  Acheiving consistency here requires some kind of style guide to make it obvious which colors, fonts, and interaction patterns should be common across the designers.

That consistency can be seductive.  As a developer I've definitely used the phrase "everything should be consistent" in pull request reviews or in complaining to my manager or product partners.  Consistent code would let me change things easily and do my work a lot more faster.  If every popup is the same across the app, then it's easy to change them all at the same time!  If every table is the same across the website then it's easy to add a settings menu to every table.  I've wanted a style guide as legos, where to build a screen, you just glue together the components - everything's consistent, nothing messy, and everything was really easy.

After enough of this, I realized gluing together components was ultimately _really boring_.  It wasn't that hard, you could just keep on gluing components forever.  If you have everything consistent and componentized, where do you add something your own unique take on the product?  Why isn't the app just an XML document?  Then I realized - how must the designers feel if the engineers were constantly pushing back on anything that deviated from the existing set of patterns?  When do _they_ get to express their creativity, and put something of themselves into the product?

Eventually a switch flipped inside my head - as a client developer my job wasn't to optimize for my own ease of maintenance, it was to be a tool to help make the designers' vision into a reality.  Nobody wants to design interaction patterns that nobody ends up using - as an engineer, when a designer comes to you with a mock, they've put a lot of work into it, and it represents the best experience they can possibly create.  Nobody likes having their work hacked to pieces just because it's different from what's already there.

On my current team we're sort of figuring it out as we go.  The style guide remains intentionally incomplete - it's got most of the colors we use (though new mocks show up using different grays), and it's got many of the widgets we use, but there's no belief that everything's there: we're not afraid to use a little extra engineering effort to make an existing experience a little more like the ideally designed experience. New widgets can show up in the mocks as an opportunity to tackle, rather than a deviation from the existing patterns.  This means we get to build new experiences which is ultimately a lot more challenging ... and so, interesting.  Embracing the mess has its rewards.

## Summary

* Style guides are best used as a tool for designers to achieve a common visual language
* As an engineer, you need to be a good partner for turning the vision of your designers into reality
* A "proscriptive" style guide doesn't leave room for creativity for either the designers or the engineers
* Embracing the challege of building new widgets is something I find more rewarding than gluing together existing widgets
* You still need to be smart about where you spend your time ;)
