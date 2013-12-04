---
layout: post
title: 'Deontological Software Development'
---

A habit I've recently started is walking the dog for three miles every morning.  It's a great for clearing my head before work and making sure I have some "me time" outside of the daily work grind.  During these walks I listen to lectures from the [Open Yale Courses](oyc.yale.edu/).  Back in August I started my mornings listening to lectures on the [Hist 210: Early Middle Ages](http://oyc.yale.edu/history/hist-210); I welcomed fall with [Hist 202: European Civilization](http://oyc.yale.edu/history/hist-202).  Recently I finished up [Phil 181: Philosophy and Science of Human Nature](http://oyc.yale.edu/philosophy/phil-181) and I found a lot of the ideas it presented professionally relevant.

The course introduced two schools of thought about moral decisions: utilitarian (based on the work of John Stuart Mill) and deontological (based on the work of Immanuel Kant).  Suppose we are attempting to determine "should you give to charity?".  A utility-based argument to support charity is that the money that *you* donate will be used to increase the happiness of those in need.  In contrast, a deontological argument is that *those with means* have a duty to give to charity.  Deontological thinking attemps to remove "you" from the decision making process.  One of the key deontological ideas is Kant's _categorical imperative_:

> Act only according to that maxim whereby you can, at the same time, will that it should become a universal law.

Neither utilitarian or deontological thinking offers a complete picture of how we should behave: both are useful for different kinds of questions.  However, I think deontological thinking is especially useful on a software development team.  (I avoided philosophy courses in undergraduate so I'm new to a lot of these ideas -- please excuse if something is very wrong!  Let me know and I'll try to fix it.)

By _Deontological Software Development_, I mean that when you make a decision, you should make that decision as if you were any other member of a software development team.  People with experience and knowledge on a project have almost carte blanche to act -- if you're one of the people who "knows best", how should you act?  Should you not write a unit test?  Should you edit code on the production server?  Should you hack around an unpleasant but commonly known issue?  While it's possible to introduce complicated rule after rule to justify yourself, I think it's better to stick to simple and easily repeated/replicated rules to guide your actions.

This may seem like an uncontroversial statement.  However I assert that for a high-functioning team the rules behind a decision are *much* more important than an outcome!  You can make a bad decision that doesn't end up hurting the customer -- does that mean you should make it again?

I believe deontological thinking leads to *replicable success*.  If you're only looking for good outcomes you might not examine the process by which the outcomes came about.  Success comes from good processes with the correct inputs -- you don't want to learn from accidental success!  With deontological thinking you're not just chasing only good results.  You're trying to find a good set of decision making criteria to guide every team member.

## All Team Members Need To Make Similar Decisions

Software development teams are a mostly flat hierarchy: everyone is producing roughly the same product with roughtly the same skills.  While the senior developers often will guide framework-level code, ultimately everyone is responsible for the delivery of customer features.  This means that everyone on the team is dealing with the same problems and trying to make the same kind of decisions.

Contrast this with disparate teams composed of people with different skillsets -- if I'm responsible for accounting and you're responsible for marketing, the domain is so different that your deontological duty differs from mine.

## You Don't See The Inputs To A Decision From The Outside

Currently my team is over 30 people (split into subteams of 4-5 people each).  One of the biggest problems with a larger team is that you can't communicate everything to everyone.  Because communicating everything would be overwhelming, bugs that would become part of the narrative of a smaller team don't make it to the entire team.  People can't see "why" a subtle choice was made through IRC or email.  I don't expect to have individual conversations with everyone about the reasons behind *why* I made one decision over another -- I trust them in the decisions they make and I hope they trust mine.

When a junior developer is trying to make a decision, the easiest thing that they can do is watch the actions of a senior developer on the team.  By making the decision-making process clear and simple the junior developers can replicate these decisions and act "correctly" without necessarily understanding all of the reasons behind an action.

Similarly, avoid using knowledge special to you about how your codebase works in making decisions.  People may not share this knowledge and only see the outcome -- when possible this individual knowledge should be exposed, turned into team knowledge, or made irrelevant so that it does not need to guide people's future decisions.

## "Software Goodness" Is A Fuzzy Concept

A truism for anyone who's ever read Hacker News: different software developers have different evaluation criteria for what makes good software.  Simple utilitarian moral arguments deal with nearly unquestionable definitions of goodness -- nobody is going to argue that someone living when they might die is a net utility gain.  However it's very hard to have utilitarian arguments about software problems.

One of my most disliked words that gets used in describing code is "simple" -- it's about as useless in a discussion as saying something is "good".  Everyone thinks that they write simple code.  Because of this evaluation disparity I'd rather have discussions about the process by which we make changes rather than the outcomes of those changes.

Additionally, it may not be clear to a junior developer how their work product differs when compared to a senior developer.  As you gain more experience more tradeoffs go into every line of code -- a careful eye during code review can spot these tradeoffs, but without much experience in a codebase it's really hard to understand why one method was chosen over another.

In general, I've found it really hard to impart concepts of "goodness" to newer team members because they've always got their own (perfectly reasonable) ideas of what's good and what's not.  Concepts like SOLID for object-oriented programming don't tell you how to act in a certain situation -- instead they give a vocabulary for post-hoc justification as to why a tradeoff was made.  I've been much more successful in replicating processes ("every new line of code should have a unit test").  A shared sense of processes is compatible with different decisions made across a codebase.

## What Does Duty Get You?

I hope I've convinced you that deontological thinking (process that produced an outcome) is more useful than utilitarian thinking (goodness of results) in a a software development team environment.  I believe thinking about the process will lead to more replicable success than simply chasing good results.

I've always believed in process as a key to success and I found these philosophical ideas to be a framework that fit with a lot of my existing professional thinking.  Of course, a software development team is only useful insofar as it produces business outcomes (ultimately, some form of utility).  One of the ideas the Phil 181 lectures introduced was that human society could be seen to operate as a dual moral system: utilitarian in its goals (the design of a progressive tax system), deontological in how it handled individual actions (the operations of the legal system).

In adhering to the duty "every new line of code should have a unit test" there is an implicit endorsement that more tests lead to better utility for the project.  I believe replicable duties (team processes) aiming at better utility (business values) are the best path for team success.

(In conclusion, I'm really sorry for the time I modified our project's `settings.py` on live servers one Sunday morning.  I was not acting in a way that should have become a universal law.)
