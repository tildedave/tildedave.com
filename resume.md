---
Title: Resume
layout: default
---

## Personal Statement

I believe in creating spaces where teams are able to continuously improve.  I love working with open technologies, especially Linux.  I am especially interested in growing a team's "DevOps" efficiency, including production delivery and site relability; to do this, teams need good and accurate information to know what's working and what's not.  Through visualizing data, teams are not only able to overcome problems but to solidly know that they are overcome.

## Rackspace the Open Cloud Company

[{{ 'http://static.davehking.com/resume-rax.jpg' | img:'style="width: 200px"' }}](http://www.rackspace.com)

### Team Lead, Cloud Control Panel (August 2012 - present)

I serve as a team lead for the team responsible for the operational improvement of the site, including uptime and error rate.  I work to define the future vision of what operations means for the Rackspace Cloud Control Panel and manage both the roadmap and the day-to-day backlog for this team.

I am responsible for defining team success, including the career development and the engagement of its members.  I have managed up to three individuals since stepping into this role; duties include weekly 1-1s, mentoring and coaching, and writing biannual performance reviews.

* We transformed the site from a single-datacenter deployment (Chicago) into a multi-datacenter deployment (Chicago, Dallas, Sydney).
* We transitioned from using MySQL as the main backing storage of our web application to Cassandra.  This was accomplished over a four month period with no customer downtime.
* We implemented an on-call rotation where failures were not the responsibility of any one person but instead of the whole team.
* I helped define our testing strategy, primarily around our automated acceptance testing with Selenium.  As of May 21 2014 we have over 1800 acceptance tests that run every hour and allow us to continuously deploy the site without the need for manual regression phases.

### Software Developer, Open Cloud Control Panel (September 2011 - present)

I was a senior developer responsible for the conversion of a startup codebase into the Rackspace Cloud Control Panel as part of a larger company initiative around OpenStack Public Cloud.  I worked on a team of 10+ developers to define code patterns that would enable rapid development.  Ultimately we launched on time with stretch goals (Cloud Databases) included in the launch.  The project used JavaScript, Closure Library, Django, and Twisted Python.

* I installed unit and integration tests for Python and did the bulk of the work to rewrite our JavaScript tests from JSUnit into Jasmine.
* I led the creation and implementation of an architecture that handled client-side data loading from JavaScript models into views.
* I expanded our metric collection using tools such as statsd and logstash to feed additional data into Graphite in order to increase application visibility.

### Software Developer, Cloud Control Panel (January 2011 - September 2011)

I was a senior developer leading a team that maintained and extended a legacy web application (Java with Struts 1).

* I led a successful effort to merge two 300k+ LOC codebases that had diverged after a period of 8 months.
* I discovered and fixed several performance issues, including one that introduced a "cascading failure" and was a blocker for a major cross-business release.
* I moved the development environment to use Vagrant.
* I introduced a JavaScript build (linting, dependency management, etc).

### Software Developer, Email (September 2009 - January 2011)

I was a developer maintaining and extending the systems that powered both the Webmail Search and Log Search infrastructure.  Webmail Search is a custom Java application that manages a set of Lucene indices to mirror the contents of a user's inbox (updated on new mail, deleted mail, etc).  Log Search is a combination of a log delivery mechanism using Scribe and Hadoop and log hosting mechanism using sharded Solr.

* I worked on a custom C++ patch to Scribe to enable buffered log delivery to Hadoop.
* I rewrote the searching frontend to the Solr cluster using PHP (Kohana) including an offline CSV exporter using `beanstalkd`.

## inRoll

### Contractor (September 2011 - August 2012)

I was a contractor for inRoll building a ColdFusion application that managed 2012 Success Charter School Lottery.

I was primarily responsible for the design and implementation of the code that powered the lottery, by which candidates for enrollment would be assigned to open slots based on the number of open slots.  This code needed to run specific business logic against 30,000+ students and was completely covered by unit tests.

My other major project was a search utility that enabled support to view information about parents calling in.  This was primarily implemented in JavaScript using Underscore.

## Penn State University (September 2003 - December 2009)

[{{ 'http://static.davehking.com/resume-psu.svg' | img:'style="width: 200px"' }}](http://www.cse.psu.edu/)

I received my PhD in Winter 2009 for my thesis, "Retrofitting Programs for Complete Security Mediation".  During my time at Penn State I was primary instructor for two classes (Digital Logic and Visual Basic .NET) as well as Teaching Assistant for 3 semesters.
