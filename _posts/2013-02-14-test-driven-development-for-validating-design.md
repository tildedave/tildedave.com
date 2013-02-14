---
layout: post
title: 'Test-Driven Development for Validating Design'
---

Test-Driven Development (TDD) is a great habit to start to increase the correctness and simplicity of your code.

When practicing test-driven development, every time you add new behavior to a class you first write a failing test (red).  Next, you write the simplest code required to make the test pass (green).  Finally, you clean up the code (refactor), ensuring that the total code for the class is as simple as possible.  In the future, this once-failing test now enforces that every future refactoring conforms to its desired behavior.

By practicing TDD I have grown classes with complicated business logic from nothing through adding one behavior at a time and at the end, I have full confidence that everything still behaves as expected.  I have also discovered much simpler designs than I initially set out to implement.  On the whole, I think that TDD contributes very strongly to the quality of the code I produce and I recommend the practice to every software developer.

Most of the time the code we write does not require a lot of design thinking: established patterns carry us through, maybe from some underlying framework that we rely on for application structure.  In cases where it is not clear what to do, I have come to see test-driven development as extremely useful in _validating a design_.

If you don't have a design in mind, or you don't know the problems and behaviors, you won't produce great code, no matter what coding practices you follow.  However, once you understand the problems well enough write code for it, TDD will help make your design simple and effective, while ensuring that the code doesn't inadvertantly break in the future.

## Collection Faceting Kata

The problem I'll use to show the benefits of this practice is _faceting_ a Backbone.js Collection.  [Facets](http://alistapart.com/article/design-patterns-faceted-navigation) are an aggregated view of a collection.  For example, if you have a collection of employees, you might want to view them by gender, experience with the company, salary.

The example I'll keep coming back to is a collection of colored shapes.  Facets have both a title and a count, which is the number of models in the collection.

```
Collection:
 Green Square
 Blue Square
 Green Triangle
 Yellow Square
 Yellow Circle

Shape Facets:
 3 Squares
 1 Triangle
 1 Circle

Color Facets:
 2 Yellow
 2 Green
 1 Blue
```

One behavior that I consider really important is that the faceted collection needs to always reflect the current state of the original collection.  For example, if we add a `Purple Square` to the collection, I'd expect the `Square` shape facet to have a count of 4 instead of 3.  Similarly if I remove the `Blue Square` I want the `Blue` color facet to disappear entirely.  These updates should be _in place_ -- if a model is added that doesn't affect a facet, I don't want any events firing on that facet.  Otherwise I might perform unnecessary DOM operations and there will be a user impact as the collection gets larger.

I've done a little legwork ahead of time to understand the problem.  I know there needs to be something that transforms a model in the original collection into its facet data -- I'm calling this a _criteria_.  I know I want the returned facets to also be a collection, since I've got some code that wires collections into a view.

Based on these constraints, I come up with the following proposed interface:

```javascript
var collectionToFacet = new Backbone.Collection();
var criteriaFn = function (model) {
  return {
    'title': title, // some title that maps the facet bucket the model falls into
    'id': id        // some unique identifier for the facet
  }
};
var facetedCollection = facets.facetCollection(criteriaFn, collectionToFacet);

// facetedCollection is now a collection of Facet objects that have a title and a count
```

This is the design I want to validate.  The code required to implement this design is not necessarily obvious.  From looking at the problem it's not immediately obvious to me what code to write.  What is a little more obvious is where to start.

## Before Everything: Data Setup

First, I set up a node project skeleton using `mocha`, and `assert` for headless JavaScript testing.

I already know I want to use a fixture of colored shapes for my tests.

```javascript
function shapeModel(id, color, shape) {
  return new Backbone.Model({
    id: id,
    color: color,
    shape: shape
  });
}

beforeEach(function () {
  redTriangle = shapeModel(1, 'Red', 'Triangle');
  blueTriangle = shapeModel(2, 'Blue', 'Triangle');
  redSquare = shapeModel(3, 'Red', 'Square');
  collection = new Backbone.Collection([redTriangle, blueTriangle, redSquare]);
});
```

For simpler designs, I usually wouldn't do this and I'd extract common data for different behaviors as I wrote code.

## The First Failing Test: a Trivial Criteria

The simplest behavior I can think of: given a criteria that assigns every model to the same facet, does the returned facet have the correct title and count?

```javascript
it('maps every model to one facet', function () {
  var trivialCriteria, facetedCollection;

  trivialCriteria = function (model) {
    return {
      id: 1,
      title: 'Trivial'
    };
  };
  facetedCollection = facets.facetCollection(trivialCriteria, collection);

  assert.equal(1, facetedCollection.length);

  var singleFacet = facetedCollection.at(0);
  assert.equal(3, singleFacet.get('count'));
  assert.equal('Trivial', singleFacet.get('title'));
});
```

I could have started more complicated here, but there's really no benefit to doing that -- this is a simple test that must always pass.

## Fixing The First Failing Test: a Trivial Function

When I know the 'real code' that I will write later is going to be complicated, I usually write the stupidest function possible.  There's a balancing act about when to be stupid and when to write correct code and I think it varies by the situation.

Here I prefer to be as stupid as possible by ignoring the passed-in `criteriaFn` and simply returning the facet that matches the test data.

```javascript
var facetCollection = function (criteriaFn, collection) {
  var facetedCollection = new Backbone.Collection();

  facetedCollection.add({
    title: 'Trivial',
    count: collection.length
  });

  return facetedCollection;
};
```

This code isn't "right" but it doesn't really matter -- it will change as I add more tests and more behavior.

## The Second Failing Test: Two Facets for One Collection

The next behavior that I choose to implement is one that will force me to properly facet the original collection (and thus remove my bad logic above).

I probably could have written this test first.  However, the less behavior you add with each test, the smaller the amount of code you need to add, which means it's more likely you'll be able to move on to the next test.  Even this simple test requires a chunk of code to make pass.

```javascript
it('maps models to different facets', function () {
  var shapeCriteria, facetedCollection;

  shapeCriteria = function (model) {
    var shape = model.get('shape');
    return {
      id: shape.toLowerCase(),
      title: shape
    };
  };
  facetedCollection = facets.facetCollection(shapeCriteria, collection);

  assert.equal(2, facetedCollection.length);

  var triangleFacet = facetedCollection.where({ title: 'Triangle' })[0];
  assert.equal(2, triangleFacet.get('count'));

  var squareFacet = facetedCollection.where({ title: 'Square' })[0];
  assert.equal(1, squareFacet.get('count'));
});
```

## Making the Second Test Pass

To make this test pass, we write the following three 'behaviors' as code.

* For each model in the original collection, apply the criteria to it.
* If the facet data returned by the criteria is not already in our faceted collection, create a facet for it.
* Update the count for the appropriate facet by 1.

```javascript
var Facet = Backbone.Model.extend({
  defaults: {
    count: 0
  }
});

var facetCollection = function (criteriaFn, collection) {
  var facetedCollection = new Backbone.Collection();

  collection.forEach(function (model) {
    // Apply the criteria function to the model
    var facetData = criteriaFn(model);
    var id = facetData.id;

    // If the facet for this model does not exist, add it
    if (!facetedCollection.get(id)) {
      facetedCollection.add(new Facet(facetData));
    }

    // Update the count -- if it's a new facet it starts with
    // count 0
    var facet = facetedCollection.get(id);
    facet.set('count', facet.get('count') + 1);
  });

  return facetedCollection;
};
```

## The Third Failing Test

Now we start writing the behavior when the original collection is updated.  Here we'll start with the simplest one: a new member is added to the original collection.  The facet associated with this model should increase by 1, being created if it does not yet exist.

```javascript
it('updates the facets when a model is added', function () {
  var facetedCollection;

  facetedCollection = facets.facetCollection(shapeCriteria, collection);
  collection.add(shapeModel(4, 'Green', 'Square'));

  // Should now have two squares
  var squareFacet = facetedCollection.where({ title: 'Square' })[0];
  assert.equal(2, squareFacet.get('count'));
});
```

## Making the Third Test Pass (in a dumb way)

My first solution to make the third test pass is a copy/paste solution.  This is not ideal but I'm not completely solid that extracting a function will work the first time here.  I'd rather get the test green and then fix the duplication.

```javascript
var facetCollection = function (criteriaFn, collection) {
  var facetedCollection = new Backbone.Collection();

  collection.forEach(function (model) {
    var facetData = criteriaFn(model);
    var id = facetData.id;

    if (!facetedCollection.get(id)) {
      facetedCollection.add(new Facet(facetData));
    }

    var facet = facetedCollection.get(id);
    facet.set('count', facet.get('count') + 1);
  });

  // Copy paste code ack ack ack
  collection.on('add', function (model) {
    var facetData = criteriaFn(model);
    var id = facetData.id;

    if (!facetedCollection.get(id)) {
      facetedCollection.add(new Facet(facetData));
    }

    var facet = facetedCollection.get(id);
    facet.set('count', facet.get('count') + 1);
  });

  return facetedCollection;
};
```

## Cleaning Up Our Mess

It turns out extracting a function really isn't too bad.  The new code, with an extracted closure `addFacetForModel`, shows that the initial collection faceting and the behavior for 'add' are actually identical.

```javascript
var facetCollection = function (criteriaFn, collection) {
  var facetedCollection = new Backbone.Collection();

  var addFacetForModel = function (model) {
    var facetData = criteriaFn(model);
    var id = facetData.id;

    if (!facetedCollection.get(id)) {
      facetedCollection.add(new Facet(facetData));
    }

    var facet = facetedCollection.get(id);
    facet.set('count', facet.get('count') + 1);
  };

  collection.forEach(function (model) {
    addFacetForModel(model);
  });

  collection.on('add', function (model) {
    addFacetForModel(model);
  });

  return facetedCollection;
};
```

## The Fourth Failing Test

Since we've handled add, we next write the first test case for removes.  This just checks that a facet count properly decrements from 2 to 1.

```javascript
it('updates the facets when a model is removed', function () {
  var facetedCollection;

  facetedCollection = facets.facetCollection(shapeCriteria, collection);
  collection.remove(collection.where({ shape: 'Triangle' })[0]);

  // Should now have one triangle and one square
  var squareFacet = facetedCollection.where({ title: 'Square' })[0];
  assert.equal(1, squareFacet.get('count'));

  var triangleFacet = facetedCollection.where({ title: 'Triangle' })[0];
  assert.equal(1, triangleFacet.get('count'));
});
```

## Fixing the Fourth Failing Test

I wrote the code necessary to make this test pass very quickly.  It needs to determine the facet that the model previously applied to and then decrement that facet count.  The way we do this is to run the criteria function against the model.

```javascript
var facetCollection = function (criteriaFn, collection) {
  // create faceted collection

  // populate faceted collection with collection argument

  // handle adds

  collection.on('remove', function (model) {
    var facetData = criteriaFn(model);
    var id = facetData.id;

    var facet = facetedCollection.get(id);
    facet.set('count', facet.get('count') - 1);
  });
};
```

While there is duplication between add and remove in terms of applying the criteria to the model, I'm not sure how best to handle this cleanly.  As one example, I could write a `getFacetForModel` function that creates the facet if it doesn't exist -- but it doesn't seem correct to be possibly calling this function from a `remove`.  Unable to think of a better solution, I hold off on further refactoring.

## The Fifth Failing Test

Now we'll check that a count that goes from 1 to 0 is removed from the collection.

```javascript
it('removes facets without representation in collection', function () {
  var facetedCollection;

  facetedCollection = facets.facetCollection(shapeCriteria, collection);
  collection.remove(collection.where({ shape: 'Square' })[0]);

  // Should now have only one triangle facet
  assert.equal(1, facetedCollection.length);

  var triangleFacet = facetedCollection.where({ title: 'Triangle' })[0];
  assert.equal(2, triangleFacet.get('count'));
});
```

As above I could have written this test case first and only needed to have one TDD cycle to handle removes, but I'd prefer to write less code in each individual step.

If I feel comfortable with the coverage that this test gives me I can circle back later to delete this test, but I usually only do this when a test is so much an artifact of the order of implementation that it not longer makes sense as an assertion of public behavior.

## Fixing the Fifth Failing Test

Easiest change so far: add a conditional and remove it if the count is 0.

```javascript
var facetCollection = function (criteriaFn, collection) {
  // create faceted collection

  // populate faceted collection with collection argument

  // handle adds

  collection.on('remove', function (model) {
    var facetData = criteriaFn(model);
    var id = facetData.id;

    var facet = facetedCollection.get(id);
    facet.set('count', facet.get('count') - 1);

    if (!facet.get('count')) {
      facetedCollection.remove(facet);
    }
  });
};
```

Though this looks trivial I actually had some problems writing these lines as I initially tried to remove it before decrementing.  Never underestimate your ability to write awful code even in the simplest situations!

## The Sixth Failing Test

Now that adds and removes are finished we'll write a test that forces us to handle update behavior.

```javascript
it('handles model updates in the original collection', function () {
  var facetedCollection = facets.facetCollection(shapeCriteria, collection);

  var triangleFacet = facetedCollection.where({ title: 'Triangle' })[0];
  var squareFacet = facetedCollection.where({ title: 'Square' })[0];
  redSquare.set('shape', 'Triangle');

  // Should now have only one triangle facet
  assert.equal(1, facetedCollection.length);

  assert.equal(3, triangleFacet.get('count'));
});
```

## Fixing The Sixth Failing Test

The first thing we need to do is start listening to updates on models in the original collection -- that's simple.  We want to decrement the count for the old facet and increment the count for the new facet.

The main issue is that it is not obvious how to determine the old facet.  We've been handling looking up the old facet for removes by applying the criteria function.  For updating, the model has already changed -- we can no longer determine which facet the model used to apply to.

My solution to this problem is to maintain a map between models and which facet they applied to.  We use the model's `id` to do this lookup.

```javascript
var facetCollection = function (criteriaFn, collection) {
  var facetedCollection = new Backbone.Collection();

  // Map to look up which facet belongs to which model, since when a 'change' event is
  // fired we can't determine this with the criteria function
  var facetForModel = {};

  var addFacetForModel = function (model) {
    // same logic as before
    facetForModel[model.id] = facet;
  };

  var removeFacetForModel = function (model) {
    // no longer uses criteria to determine which facet applies
    var facet = facetForModel[model.id];
    // decrement facet count and possibly remove it
  };

  var listenForUpdates = function (model) {
    model.on('change', function () {
      removeFacetForModel(model);
      addFacetForModel(model);
    });
  };

  collection.forEach(function (model) {
    addFacetForModel(model);
    listenForUpdates(model);
  });

  // listen for model add

  // listen for model remove
};
```

This implementation works (test is green) but has an flaw.  I'd prefer not to adjust facet counts on updates that don't cause a model's facet to change: for example, if a model's color changes, it won't change what shape facet it falls into.  Firing events like this can result in poor performance with larger collections.

I think it's a judgement call as to whether or not you write a unit test to force this invariant.  It definitely is a behavior that we don't want to have.  However the test is very aimed at avoiding a specific version on the class's implementation which makes it a little harder to understand from a public interface perspective.

In this case I just updated the implementation and ensured that all the tests still passed.  First we look up the facet for the newly updated model, apply the criteria, and only remove the old facet is the facet identifiers have changed.

```javascript
var facetCollection = function (criteriaFn, collection) {
  // create faceted collection

  // handle adds

  var updateFacetForModel = function (model) {
    var oldFacet = facetForModel[model.id];
    var newFacet = criteriaFn(model);

    if (oldFacet.id === newFacet.id) {
      return;
    }

    removeFacetForModel(model);
    addFacetForModel(model);
  };

  var listenForUpdates = function (model) {
    model.on('change', function () {
      updateFacetForModel(model);
    });
  };

  // populate faceted collection with collection argument

  // listen for model add

  // listen for model remove
};
```

## The Seventh Failing Test

The implementation above has a problem -- when models are newly added to the collection they also need to listen for updates.

I write a quick test to enforce this behavior.  Again it's a judgement call as to whether or not to eventually let this test supercede the previous one as it is now testing both.

```javascript
it('handles model updates after addition', function () {
  var facetedCollection = facets.facetCollection(shapeCriteria, collection);

  var greenSquare = shapeModel(4, 'Green', 'Square');
  collection.add(greenSquare);
  greenSquare.set('shape', 'Triangle');

  var triangleFacet = facetedCollection.where({ title: 'Triangle' })[0];
  var squareFacet = facetedCollection.where({ title: 'Square' })[0];

  // Should have updated triangle facet and square facet
  assert.equal(3, triangleFacet.get('count'));
  assert.equal(1, squareFacet.get('count'));
});
```

## Fixing the Seventh Failing Test

This is an easy fix: start listening to models as they are added to the collection.

```javascript
  // create faceted collection

  // handle adds

  // populate faceted collection with collection argument

  collection.on('add', function (model) {
    addFacetForModel(model);
    // add line to ensure updates happen after adds :)
    listenForUpdates(model);
  });

  // listen for model remove

  // listen for model updates
```

This completes all of the original functionality that I wanted as part of this class: faceted collections, in-place updates on add, remove, and update, and so this is a good place to stop.

## Next Steps

There's more behavior that can be added to this class: for example, what if a model no longer only has one facet but maybe have none, or many?  This requires changing how updates work and changing the `facetForModel` map to keep not just one facet but none, or many.

I find that this Kata is a good microcosm of the things that make me successful while practicing TDD:

* Come up with an initial design; this may an initial stab at a class interface
* Validate the design by writing test cases for the behavior I want
* Write the test that lets me write the smallest amount of code
* Write dumb code when it's not immediately obvious how to proceed, but might become easier in the future

For the nitty-gitty of how I went from 0 to a finished class, the commit log is on [Github](https://github.com/tildedave/backbone-facets/commits/master).

If you're looking to learn more about Test-Driven Development, Kent Beck's book [Test-Driven Development By Example](http://www.amazon.com/Test-Driven-Development-Kent-Beck/dp/0321146530) is a great resource.