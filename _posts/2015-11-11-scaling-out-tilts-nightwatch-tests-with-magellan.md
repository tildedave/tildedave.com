---
layout: post
title: "Scaling Out Tilt's Nightwatch Tests with Magellan"
is_unlisted: 1
---

I've talked [in the past](http://www.slideshare.net/tildedave/nightwatch-at-tilt) about how Tilt rebuilt our Selenium suite using [Nightwatch](https://www.nightwatchjs.org), a JavaScript interface to Selenium WebDriver.  Our suite is now up to about 100 end-to-end user scenarios - this provides a good test of our overall functionality that we can use to certify that Tilt.com works before promoting builds from staging to production.

We recently converted to using TestArmada's [Magellan](https://github.com/TestArmada/magellan) Test runner, which automatically splits a test suite up and runs it in parallel.  Want to run the entire suite from your developer box against a staging environment?  Want to split up the suite to run eight concurrent tests and run each individually?  Want to set a global retry policy for all your end-to-end tests?  Magellan makes these tasks easy.

<img class="img-responsive" style="max-width:320px" src="/images/testarmada-logo.png" />

## Growing Pains

Before Magellan, the main way that we scaled out our test suite was to run different Jenkins jobs.  Each Jenkins job would run a "slice" of our overall test suite against staging using a nightwatch tag and a Nightwatch environment.  As an example, we'd run our contribution tests (tagged `contribution`) in both desktop and mobile mode, using different Nightwatch environments.  Here's a sampling of our old Jenkins setup:

<img src="/images/tilt-legacy-selenium-configuration.png" class="img-responsive" style="max-width:640px" />

The desktop and mobile web versions of the site expose similar functionality but with a different user experience - for example, the Tilt page has both mobile web and desktop versions with different implementations due to the different UX.  However, each of them makes it possible for people to contribute to a Tilt using a set of shared lightboxes, and those lightboxes have some desktop and mobile-specific behavior.  As an example, logging in to the site through Facebook on mobile uses a redirect login.  To make sure that both flows constantly work, it's important to run end-to-end tests that exercise both code paths.

We ran into a few issues with our multiple-Jenkins-jobs multiple-nightwatch-tags multiple-nightwatch-environments setup as we added more end-to-end tests:

* Suites would inconsistently be run in 'mobile' or 'desktop' versions.  Our login and contribution tests would run in both but most tests were run in desktop mode and not tested at a smaller viewport.

* Different tags of the test suite took different time to run - this lead to load not being evenly distributed.  Some jobs would finish quickly (3 minutes) and some would take a longer time (11 minutes).  The entire suite would only finish after all of these jobs were done, so this uneven distribution of load meant there was an opportunity to go faster.  However, this would require manually moving tests between different Jenkins jobs.

* Because of past negative experience running Selenium grid, we had each Jenkins job start a new version of selenium server and a virtual X frame buffer as part of the test run.  Our implementation had us hardcoding the Selenium port that the server would run on.  This lead to a reluctance to create new jobs as this involved interacting with the Jenkins interface, finding an unused Selenium port, then modifying the shell script to run a different Nightwatch tag.

* Difficult to test changes to the entire suite without merging and seeing what the result was - Jenkins jobs were hardcoded to find their tests in the git `master` branch, and running all the of the tests locally would just run everything serially, taking forever.

## Installing TestArmada

We learned about [TestArmada](https://github.com/TestArmada/), a suite of tools open-sourced by Walmart labs, on the Nightwatch.js mailing list.  [Magellan](https://github.com/TestArmada/magellan), described as a "test runner runner", immediately looked appealing - it would automatically parallelize our suite, automatically start a Selenium server before each test run (which we were already doing, but it would manage the choice of port), and natively run on top of Nightwatch.

One of the major selling points of the TestArmada platform was its support for managing test retries.  Past experience showed us the importance of adding retries to a large test suite - if every test case is 99.9% reliable, running a suite of 100 tests will only pass 90% of the time.  End-to-end testing is less stable than controlled environments like unit tests or integration tests - you're dealing with a much bigger stack of code and your test is only as reliable as the user experience that you're testing.  Because of this, we've found it best to add at least one retry to your end-to-end test suite, and then monitor tests that have a lower fidelity to improve either the test or the underlying user experience (the code that powers it).

After contributing a few minor patches - including adding support for [Nightwatch tests written with ES6](https://github.com/TestArmada/magellan/pull/41) - and a few days of refactoring, we're down to four jobs using Chrome and PhantomJS 2.0.0, both running in desktop and mobile mode.

<img src="/images/tilt-magellan-selenium-configuration.png" class="img-responsive" style="max-width:640px" />

The tests now run in less than 10 minutes - or even less, depending on the number of parallel workers that we throw at it using Magellan's `max_workers` arguments!  (I brought down the Jenkins master once by upping the number too high!)

### Running the entire suite

Before, it was not practical to run the entire suite as it involved running many different nightwatch commands, or running all the tests serially.  Each test sets up all of the data required for the test, which involves signing up new users or creating new crowdfunding campaigns, which leads to each test taking around a minute to run.  With Magellan, developers can now run the entire suite from their developer box using phantomjs.  Here's the start of a test run where I've run all our desktop tests with phantomjs against our staging environment:

```
$ TEST_ENVIRONMENT=staging magellan --config=./magellan.jenkins.json --tag desktop
Loaded magellan configuration from:  /Users/dave/workspace/tilt-nightwatch/magellan.jenkins.json
Magellan-nightwatch test iterator found nightwatch configuration at: ./nightwatch.conf.js
Using tag filter:  [ 'desktop' ]

Running 78 tests with 8 workers with phantomjs

--> Worker 1, mock port: 21000, running test: test/comment_view_spec.js @phantomjs
--> Worker 2, mock port: 21003, running test: test/connect_via_notification_center_spec.js @phantomjs
--> Worker 3, mock port: 21006, running test: test/connect_via_search_center_spec.js @phantomjs
--> Worker 4, mock port: 21009, running test: test/connect_with_facebook_preserves_email_spec.js @phantomjs
--> Worker 5, mock port: 21012, running test: test/contribution_answer_questions_during_contribution_spec.js @phantomjs
--> Worker 6, mock port: 21015, running test: test/contribution_can_contribute_after_correct_invalid_saved_card_spec.js @phantomjs
--> Worker 7, mock port: 21018, running test: test/contribution_can_contribute_with_valid_card_after_invalid_card_spec.js @phantomjs
--> Worker 8, mock port: 21021, running test: test/contribution_contribute_after_canceling_edit_to_saved_card_spec.js @phantomjs
(1 / 69) <-- Worker 1 PASS  test/comment_view_spec.js @phantomjs
--> Worker 1, mock port: 21024, running test: test/contribution_contribute_to_collect_as_organizer_spec.js @phantomjs
(2 / 69) <-- Worker 3 PASS  test/connect_via_search_center_spec.js @phantomjs
(3 / 69) <-- Worker 2 PASS  test/connect_via_notification_center_spec.js @phantomjs

....

(73 / 78) <-- Worker 1 PASS  test/user_menu_spec.js @phantomjs
(74 / 78) <-- Worker 4 PASS  test/recontributions_spec.js @phantomjs
(75 / 78) <-- Worker 7 PASS  test/profile_settings_spec.js @phantomjs
(76 / 78) <-- Worker 5 PASS  test/search_spec.js @phantomjs
(77 / 78) <-- Worker 3 PASS  test/reminders_remind_email_invite_spec.js @phantomjs
(78 / 78) <-- Worker 6 PASS  test/reminders_remind_all_spec.js @phantomjs

============= Suite Complete =============

     Status: PASSED
    Runtime: 6m 16.1s
Total tests: 78
 Successful: 78 / 78

```

## Test Refactoring

We only needed a few tweaks to our test suite to move to Magellan.  Most of this got rolled into a general test refactor to get tests running under PhantomJS (we're using version 2.0), get our desktop tests working under 1024x768 (previously they expected 1600x1200), and convert certain tests that were desktop-only to run in mobile mode as well.

For example, our user menu test, which makes sure the user menu in the masthead works properly and has the expected links, used to be desktop-only.  Now it runs in both desktop and mobile modes with the specific desktop and mobile logic inside the page object.

```javascript
client
  .page.homepage().load()
  .signUpEmailUser('UserMenu Tester')
  .whenDesktop(function() {
    client.page.navbar().verifyUserName('UserMenu Tester');
  })
  .pause(500)
  .page.navbar().openUserMenu()
  .whenDesktop(function() {
    return client.page.navbar().verifyProfileLink();
  })
  .page.navbar().verifySettingsLink()
  .page.navbar().verifyInviteFriendsLink()
  .page.navbar().verifyLogoutLink()
  .end();
}
```

### Split Your Tests Into Separate Files

Magellan parallelizes your test suite at the test file level.  Our test suite used to have many different logically-grouped test cases inside of individual test files (for example, a test case verifying that the "install app" banner displayed, as well as a test case verifying that it could be closed).  On refactoring to use Magellan, we split these out into separate files so that they could be run in parallel to one another.  This makes sure that individual test files will run quickly - a test file that takes 5 minutes to run through all the different test cases will just take up a worker that could be used to run other tests.

## Conclusion

With our new setup it's been really easy to add new tests to our test suite - just merge new tests with the right tags and they'll get picked up by the next test run - there's no manual overhead to make sure that the test is run by the correct job, and no shuffling of tests to make sure that everything's still running fast.

The new setup has been so easy to parallelize that we've brought down both our Jenkins server (overloaded the master with too many Chrome workers) and our staging environment (overloaded the web workers with too many requests).  Luckily turning down the parallelism was easy too...

We're not yet using Magellan's Saucelabs integration, but we'll be adding that soon.  Our "mobile" testing really is currently just Chrome and PhantomJS faking an iPhone user agent.  This works well enough to make sure our mobile-only JavaScript files, but doesn't actually the iPhone user experience, where many of our users are.  That makes it possible for mobile Safari-only bugs to pop up and not be caught by our automatic test suite.  Proper cross-browser automated test is important to make sure that we can catch browser-specific bugs before our customers.

## End-to-End Testing Technologies

There are a lot of tools in use in our testing setup!  I've pulled the core technologies out into a handy table for those of you just getting started with end-to-end testing.

| Tool              | Purpose
| ----------------- | ---------------------
| [Selenium](http://seleniumhq.org/)          | Browser Automation interface
| [Nightwatch](http://nightwatchjs.org)        | Build Test Suites on top of Selenium in JavaScript
| [Magellan](https://github.com/TestArmada/magellan)          | Manage test suite (retries, parallelization, Saucelabs integration)
| [PhantomJS](http://phantomjs.org)         | Headless web browser (does not require running an X Server or Virtual X Frame Buffer)
| [Chromedriver](https://code.google.com/p/selenium/wiki/ChromeDriver) | Selenium bindings for Chrome
| [Ghostdriver](https://github.com/detro/ghostdriver) | Selenium bindings for PhantomJS
| [Saucelabs](https://saucelabs.com/) | Hosted Selenium Servers (includes video playback for test runs)
| [Xvfb](http://www.x.org/archive/X11R7.6/doc/man/man1/Xvfb.1.xhtml)              | Run a visual server without any graphics hardware

End-to-end testing is critical to make sure that you can continuously ship bug-free code, and so it's really important that your test suite is as good as the code you're writing.  Nightwatch makes it really easy to build out end-to-end test suites, and Magellan makes it really easy to scale out your suite as it gets bigger so that you can keep it green.

If you're just starting out, I'd recommend Nightwatch and Chromedriver as the first tools to investigate.  As you build out a bigger suite, it's important to add diversity by running different browsers (we're currently using PhantomJS and Chrome).  Eventually running an end-to-end test suite becomes a maintenance challenge.  The TestArmada team has a post on their experience [Zombies and Soup](https://medium.com/@geek_dave/zombies-and-soup-e346f0c8064f), and I've written in the past on how we scaled out our selenium tests on a past team - [once]({% post_url 2013-04-27-acceptance-testing-strategies %}) after our first year, and [again]({% post_url 2014-05-05-more-acceptance-testing-strategies %}) after our second.
