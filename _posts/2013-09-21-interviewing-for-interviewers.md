---
layout: post
title: 'Interviewing For Interviewers'
---

Technical interviewing is a major part of my job, and over the last four years I've been in over 50 interview panels for both entry level and senior software development positions.  After training, it's easy to get thrown into interviews without thinking too much about it: just another part of the job.  Over the last three years I've become a lot more strategic in how I approach interviews; I hope what's been useful for me is also useful for you, either as interviewer or candidate.

In a interview I'm looking to have a friendly conversation to go over a candidate's past experience and understand their skills and experience would be a good fit for the position.  To recommend a candidate for hiring I'm looking for past experiences that will lead him or her to be successful in the position.  This position is the next step of their career and it has to be appropriate for the challenges that they've faced before.  Additionally, I try to understand whether or not this is a position that they're going to enjoy: it doesn't do us any good if we're hiring someone for a position that doesn't match where they want to go next!

## For Entry Level Candidates, Look for Passion

My office's location is in a small college town in southwest Virginia.  Because of our location close to a college, we rely a lot on college students and entry level hires.  Most students at a school will come out of their coursework with a similar set of experiences; for example, many take a required course in processor programming that teaches them the MIPS assembly language.  What really distinguishes an entry level candidate is how they have augmented their coursework through independent investigation and extracurricular activities.  Truly passionate candidates do not just say they are passionate -- they will have a record of experiences that demonstrate that passion.  Candidates looking for entry level positions should highlight experiences that reinforce positive self-descriptors ('passionate', 'eager to learn', 'good team worker').

When interviewing with my current company I had a good amount of programming experience from my PhD thesis, but the interview only came alive when I brought up the [chess engine](https://github.com/tildedave/apep-chess-engine) I had coded in my spare time.  This personal project, done purely because I was interested, was something that separated me from just a piece of paper, and showed that I truly did enjoy to produce code.

## For Experienced Candidates, Look for Depth

When talking with candidates who have some prior experience, my main strategy is to explore _depth_ in the subjects we talk about.  You're going to have a better conversation if you spend 20 minutes on one topic as opposed to spending 5 minutes on 4 different topics.  A longer conversation lets you really understand a candidate's depth of experience in an area and how that depth would translate into the job position they're interviewing for.

## Let Them Fill In The Details

It's a really easy trap to fall into a situation where you ask a question and misinterpret the answer as meaning something different from what their experience actually was.  Asking clarifying questions is really important to make sure that you completely understand the situation that they are describing.

One good place to do this is when dealing with common terms can have a variety of different interpretations.  For example, "Test-Driven Development" can mean anything from "project has unit tests" to a more rigorous red-green refactor cycle.

> A: Your resume says that you used agile development practices on your previous project.  Could you describe those to me?
>
> B: Oh yes, we used Scrum.
>
> A: How did that work exactly?  Did you have a product manager who maintained a prioritized backlog, with sprint planning every two-three weeks?

An especially important area to ask these questions is when a candidate is describing a past project.  Were they involved with the technical decisions being made, or were they more junior on the project?  Asking clarifying questions can help you better understand their past experience.

## Watch the Clock

Our interview panels are an hour long, with about 10 minutes reserved at the end for the candidate to ask questions.  With some icebreaker conversations and introductions at the start, you probably only have about 45 minutes for any given sssion.  Throughout this time it's really important to understand where you are in relation to the clock: how much time you have left and how much time certain questions are going to take to ask and answer.  You don't want to start asking an in-depth question with a lot of things to explore with 5 minutes left in the interview.

In interviews, some people have a tendency to keep talking (sometimes due to nerves).  Sometimes you need to be able to nicely cut off a candidate in order to keep the conversation moving forward.

> B: ... another one of my duties was creating MSI packages of the source code so that we could distribute this to end users.  Whenever quality engineering sent me an email saying they were finished testing a development version of the build, I would go to Visual Studio and create a package --
>
> (Candidate is interviewing for a Linux position and specifics in package creation aren't really that relevant.)
>
> A: Can I cut you off?  Thanks for describing that to me, it sounds like that was really important for the project, but we don't have much time left and we are primarily a Linux shop.  Earlier you talked about your time handling static/dynamic library loading in a Windows environment.  Have you ever done this for a Unix operating system?
>
> B: Oh yes, my previous position deployed to both Red Hat Linux and FreeBSD and we had to handle...

It's important to do this in a respectful way!  An interviewing conversation isn't adversarial and you need to be honest about the reasons you're cutting off someone.

Similarly if you ask a question and you can tell there's nothing behind the answer, just move on.

> A: Your resume says you have some experience with JavaScript.  What projects have you worked on in that?
>
> B: Oh my last project was a Rails application with a little jQuery, but that was mostly done by another developer on the project.
>
> (Rather than dig for maybe the 1-2 times B had to fix a JavaScript bug, save time by moving to another topic.)
>
> A: Okay, one of the things you mentioned earlier was that you were involved with optimizing database performance.  Could you describe that project to me?

The time you spend on other more interesting topics is more important than asking questions on an area that the candidate doesn't have much experience in.  Additionally, needlessly focusing on areas of weakness during an interview doesn't do anyone any favors: you're looking to have a friendly conversation, not an inquisition.

## Build a Separating Technical Design Question

One of the most useful questions that I ask during interviews is a technical design question, with the intention that this will take 10-15 minutes of the interview.  The main goal of this question is to understand the breadth of experience that a candidate has in a subject area.  A good technical design question doesn't have a "right" or "wrong" answer: it has a range of possible answers based on experience with the problem domain.

A technical design question is different from an abstract design question ("design a traffic light").  You start out by describing the problem domain and what you specifically are looking for in a solution.  As the candidate walks through the problem, you ask questions and engage if you don't think a part of the design will work.  An example of a separating technical question is [designing a link shortener](http://www.tawheedkader.com/2012/03/how-to-hire-a-hacker-for-your-startup/).

What technical design question should you use?  The best ones are specific to your project.  Adapting a design challenge into a technical question can produce organic questions that allow you to really assess job position fit.

## Sharing Candidate Information At the Roundtable

At the end of an on-site interview (the last round), everyone who's been part of a panel gets together to talk ("the roundtable").  During the roundtable, the group will come to a decision about the next step for the candidate.  The main thing I want to get out of the roundtable is the understanding that, as a team, we have enough information about the candidate in order to make this important decision.

In this situation, groupthink is really dangerous: you want to make sure that everyone's impressions during the interview panels are brought out.  There are a few strategies for ensuring that this happens: one that's worked for me is to physically write observations on a board.  By rewarding people who say new things (through writing on the board) people will be encouraged to find new observations from their notes.

Be sure that any statements you make about the candidate are supported by things that they said.

* **Bad**: "B doesn't have good JavaScript experience."
* **Good**: "When we talked about B's experience with JavaScript he didn't know about how DOM events or how the browser event loop worked."

* **Bad**: "B would work well on our team."
* **Good**: "B has a lot of experience with the working practices that we use every day; she described being on a similar sized team in her previous company."

If you find other people in the roundtable making unsupported observations, call them out on this.  It's the group's responsibility to come to an effective decisions and a little discord with your fellow interviewers is better than coming to a decision based on incomplete information.

## You Represent The Company

In interviewing, you are the face of your company.  A candidate may talk with less than only ten people from the company during the hiring process.  As one of them it's your responsibility to make sure that the candidate feels an interview is tough, but fair.  Be sure to show up on time, listen when a candidate talks, and show your respect their knowledge and experience, even if they may not be match for the specific position they are applying for.

Selling the company isn't only the job of the recruiter or the hiring manager: it's also your job.  What makes you excited about your job?  Make sure the candidate knows.  If you really like this candidate, how can you encourage them to turn down other prospective job offers and accept this one?

## Conclusion

Interviewing is one of the most important things that a company does.  Selecting talent is critical for a team's success.  Even if a team is full of top performers, good people will eventually leave and need to be replaced.

Being effective at something does not just 'happen' (or you are far more gifted than me!).  You need to think about it, assess how you are doing, solicit feedback from others, and adjust based on this information.  Lately I have been trying to improve my own interview effectiveness: in the past I've asked the ineffective questions, talked too much at roundtables, and inefficiently managed interview time.  I hope my experience has been helpful if you've been in a similar situation.