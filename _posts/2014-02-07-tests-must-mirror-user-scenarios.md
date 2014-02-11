---
layout: post
title: 'Tests Must Mirror User Scenarios'
---

Automated testing is the best way to ensure that the code you write continues to work far into the future.  An issue that I frequently see newer developers get tripped on is the _why_ behind testing: a project has a whole bunch of tests, you're adding some new functionality, more tests need to be written to cover all of the added code ... but which ones?

Without guidance about the whys of testing it's easy to fall into the trap of asserting on things that should be _true_, which is useful but not the whole story.  Mathematical logic has the concept of a _model_, which is a mathematical universe, e.g. the natural numbers (0, 1, 2, 3) with addition (1 + 2 = 3).  Models are formed from sets of assertions (theories): for example, the assertion "there is a smallest element" is true in the model of the natural numbers (0, 1, 2, 3, ...) but not in the model of the integers (..., -3, -2, -1, 0, 1, 2, 3, ...).  With an automated software test, you are adding an assertion that is checked with every build -- the challenge is then to ensure that you've chosen the right assertions that uniquely pin down the product you're building.  Theories can have more assertions than they need (redundant tests) or select the wrong logical universe (you are asserting on the wrong product).

So, by adding tests you are selecting the universe that your product lives in.  Because of this, tests should be primarily guided by user scenarios: tests that match user behavior ensure that any green build selects a product with a particular user-facing utility.  The next natural question is exactly _who_ the user is at each of the testing levels.

### Users at the Unit-Level

Users at the unit level invoke public interfaces an an object and see external side-effects.  I lean towards a heavily mockist style but this idea doesn't require you agree on that -- statist tests can and should make user-based assertions as well.

A natural follow-up to this is that tests should not reference private fields and methods; these are internal behaviors, which have no instrinctic user value by themselves.  As example, my project uses [Knockout](http://knockoutjs.com) to update the DOM based on declarative bindings (functional descriptions of a model behavior) rather than manually updated DOM operations.  The question comes up, if a JavaScript component has a view model, what level of testing is needed for that view model?  I'd argue that the view model for a JavaScript component does not really match a user behavior.   Instead it should be "tested through" -- render the component into the DOM and test that the appropriate behaviors.

```javascript
// markup
component = {

  tmpl: '<div class="warning-message" data-bind="text: warningMessage"></div>'

  init: function () {
    this.viewModel = {
      warningMessage: ko.observable('Oh noes!')
    };
  }

  render: function (ele) {
    ele.innerHTML = _.template(this.tmpl);
    ko.applyBindings(viewModel, ele);
  }

  getViewModel: function () {
    return this.viewModel;
  }
}

beforeEach(function () {
  // render our component (object under test) into a DOM element
  component.render(element);
});

// BAD: Not testing a user behavior, just testing a class's internal state
it('sets a warning message', function () {
  expect(component.getViewModel()['warningMessage']()).toBe('Oh noes!');
});

// GOOD: Tests externally visible behavior to the class
it('sets a warning message', function () {
  expect(element.querySelector('.warning-message')).toHaveTextContent('Oh noes!')
});
```

### Users at the Integration-Level

At the integration level (multiple components talking to each other), user identity is less clear: when dealing with the interactions of several components, what "powers" does the user have?  Can it see into the database?  Can it see upstream web service calls being made?  There aren't clear answers here as every project has a different set of components.

From a user perspective I consider my project's most successful integration tests to be the ones that deal with one of our Twisted services: a test creates a fake HTTP server, sends an HTTP request to the service under test, and ensures the correct calls were made to the fake HTTP server.  Tests have a clear pattern and a clear set of boundaries, and it is clear what would necessitate new tests (new kinds of calls).

### Users at the Functional-Level

Users at the functional level match the end users of your product.  For example, if you're building a web application, your tests should use tools like Selenium to automate a web browser, click on elements, and ensure that the correct user-facing behavior occurs.

There is a higher danger here of "over-asserting" because of the complexity of investigating failures between all the different components involved in a product working.  As an example, yesterday my team was investigating a failure in a Selenium-based test that they were writing: they were implementing a feature where submitting a form would remember some of the last selected values that had been submitted.  When reloading the page, the remembered values would be prepopulated.  After submitting the form, the test would immediately refresh the page to see if the values were populated correctly.  After some digging they determined that there was no guarantee that an immediate read after a write would have persisted (an expected behavior given Cassandra's eventual consistency model).  What makes this discovery less useful is that here it isn't illuminating anything: no users are submitting a form and then refreshing to check that the values are persisted.  The best way to fix this test is to make it a real user scenario: submit a form, see the result of through to completion, then return to the original form and see if the values have been been prepopulated.

Functional tests can expose issues can expose defects that cross team boundaries.  However, it is hard to prioritize a defect that only appears in a functional test that is operating outside of normal user behavior.  While the behavior is in some sense "defective", the behavior is not a valid user scenario, meaning that these "defects" will never be fixed.  My project has over 90 suites of functional tests that run every hour, run on 20 Jenkins Slaves with 4+ exectors each, and finish within 20 minutes.  While this allows us to quickly check whether a revision of our code is good, some of our tests can put an unexpected amount of load on backend web services -- beyond what a usual customer would usually produce.  My company follows a Service-Oriented Architecture structure, these backend web services are maintained by other teams.  While our tests have exposed truly 'defective' behavior, it is sometimes hard to explain the priority of these theoretical 'defects' to other teams as our tests follow an unusual pattern that do not match typical user behavior.  Here our mistake is testing outside of an expected user scenario -- to check that a build of our code is good, our tests really only need to mirror the pattern of normal users, not users that push load limits.  (Of course, load testing is valuable for a whole host of reasons.  These teams have their own load testers and their own prioritization process for these issues!)

## Write for the User

We write software for the user.  Our automated testing process should reflect this.  Though the traditional process of writing and validating manual test plans may seem process heavy to someone who primarily writes software, test plans are clearly designed to explicitly mirror user behavior.  In automated testing the cost of making an assertion is much cheaper -- you can write a test today and it may run on every build for the lifetime of the project -- but to make useful assertions the motivation behind it must be the same as those manual test plans.  Ultimately tests support the user of the software; when they stray away from this, they are irrelevant.
