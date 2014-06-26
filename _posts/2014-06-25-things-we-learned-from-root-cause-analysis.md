---
layout: post
title: 'Things We Learned From Root Cause Analysis'
---

My project has gone from being a green-field (e.g. not released to customers) project to being used for thousands of users a day.  During that time we've kept track of almost every production failure through _root cause analysis_.  Root cause analysis, e.g. learning through failure, has been our main learning tool in changing our process to avoid customers outages.

I've gone through the last two and a half years of root cause analysis as stored on our wiki and pulled out the most salient learnings.  Embarassingly several of these themes have multiple incidents assigned to them, meaning that we clearly didn't learn the right lessons the first time!

## Production and Preproduction Should Be The Same

We've had two main outages that have changed how we've treated our preproduction environment.  At first our preproduction environment was substantively different from our production environment: it had in-development features and automatically ran any database migrations that happened to be deployed there (in production our process would be to take a backup and then execute a migration; we wouldn't do backups in preproduction).

Preproduction having in-development features meant that sometimes the first time new code would be executed and manually visualized would be in production.  Database migrations being run automatically meant that migrations that broke the site were not detected in preproduction and instead broke production (and our customers).

In order to see in-development features we created a _preview_ web server, where features would be enabled.  Preproduction runs the exact code as production and a change that works in preproduction will also work in production.

## Change Out-of-Rotation Nodes First

We still had to learn this obvious lesson the hard way.  The first time a change is applied to a server is the most dangerous: a badly written chef search may remove all nodes from a loadbalancer, a syntax error in a configuration file may cause a server to not start, etc.  (Yes, these are actual things that have burned us.)

Because of this danger, the first time you deploy to a class of "server type" should be to a server that is not in customer rotation.  My team chooses a "howitzer" approach to this and runs an _entirely separate production datacenter_ that is not typically in customer rotation.  When we're deploying new code or infrastructure, that change is applied to the out of rotation datacenter first.

There are other benefits to running a separate production datacenter; when we need to perform impacting maintenance, we utilize DNS failover to drain customers from the primary to the hot spare.  Even after building this separate production datacenter to mitigate downtime we didn't know how we had to treat it -- we needed to have a failure to learn one of the best ways to use it.

## There's More To Failure Than Missing Tests

By volume, the bulk of our features are where where we have broken a specific product feature rather than affecting the availability of the entire site.  For example, there was an brief outage where the "resize server" button didn't have the proper behavior in certain circumstances.  This was detected and reverted about four hours after being introduced, impacting only 8 customers.  In this situation we just didn't have the automation at a quality that we needed: the automation for this feature was written, but it not running in a way that its failure would be detected (even when the feature was working, the test failed).  Needing an improved testing framework was a familiar learning on our team and every root cause analysis meeting would have "better testing" as a take-away.

Because of this I have come to feel that missing tests are one of the least interesting parts of a failure.  Yes, in certain situations a test was missing and needed to be written.  Yes, in certain situations a test failed and we deployed to production anyways.  Of course testing is important; we don't need a failure to convince us of that.  If you think testing is important and you assign lack of testing as the root cause to every production failure, you limit its value by letting it confirm your pre-existing biases.

To make sure we think about all aspects of a failure, we use a thinking framework adapted from a [wonderful breakdown of a storage disruption on Windows Azure](http://azure.microsoft.com/blog/2013/03/01/details-of-the-february-22nd-2013-windows-azure-storage-disruption/).  In the article, the Azure storage team highlights four parts of a customer-facing incident:

> To learn as much as we can, we do a root cause analysis and analyze all aspects of the incident to improve the reliability of our platform for our customers.  This analysis is organized into four major areas, looking at each part of the incident lifecycle as well as the engineering process that preceded it:
>
> * Detection - how to rapidly surface failures and prioritize recovery
> * Recovery - how to reduce the recovery time and impact on our customers
> * Prevention - how the system can avoid, isolate, and/or recover from failures
> * Response - how to support our customers during an incident

Testing is aimed at *prevention*, but doesn't talk too much about the other parts of the lifecycle of an incident.  By operating within this framework, we expand our view of a failure into places that we might not normally go if we allowed lack of testing to be the monocausal reason for a failure.

Public failure is a jolt that you are doing something wrong: the world that actually exists does not match your model of the world.  Rather than try to remove this disparity, you can use becoming unmoored as an opportunity.  How else is the world different?

## What Should You *Not* Learn?

Looking through these, the common thread is, "test changes before your customers test them for you".  This principle is *not* a special learning, it is actually fairly obvious.  With product development you attempt to introduce processes that satisfy this principle (among others).  You must walk a balance between introduing many processes up-front that ward off failure (but slow development and so, improvement) and letting yourself be guided by failure to learn which processes are the most important for your specific use-case.

If you let yourself be guided through failure to processes that hinder your ability to move fast, you have capped the rate at which your team can improve.  While this may not seem like a horrible thing next to the customer outage, the cap to your growth rate is compounded over the lifetime of the product.

I totally understand that nobody likes it when there's a production outage in the middle of a working day (like [Heroku had this earlier this week](https://status.heroku.com/incidents/642)).  However, there would be a number of extremely painful logistics associated with only doing maintenances during off hours.  Could you staff a team that had nightly deploys as a daily responsibility?  (Maybe this isn't a big deal for people fresh out of college but it is definitely a concern as you get older, put down roots, and have a family.)  Would this encourage you to change your code less, meaning that the team improves slower?  (Yes.)  If the team improves slower, does this impact the customers and the bottom line?  (Hopefully you are working in an environment where the answer is yes!)

Like every practice, you can't apply root cause analysis as a dumb technique.  It must be guided towards an end goal: safe changes, no customer impact, and continuous improvement of the product.
