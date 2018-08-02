---
layout: post
title: 'Getting Stuck'
is_unlisted: 1
---

I run into a lot of problems.  Some problems are easy to handle, some require concentration, and some remain insoluble no matter how much energy I spend.  The problems I remember are where for whatever reason, I end up _stuck_ and can't get much traction.  The stories that come out of solving these problems are always great, but also I've been in situations where I've wasted weeks and ended up with very little to show at the end.

Getting stuck is interesting because you're outside of your comfort zone.  When you're familiar with a problem domain, it's a lot easier to be productive because you already know what strategies are likely to be successful.  In a situation where you don't have this experience to fall back on, it's easy to keep spending time on a problem.  To maximize your effectiveness you have to keep moving towards a solution.

I have a few different strategies I use when I get stuck.  All of them force me to step outside myself and get away from the details of the specific problem I'm currently facing.

### Visualize a Solution

Suppose I found a solution to this problem that I'm looking at.  What does it get me and what will I have learned?  I find this really helpful because it lets me assess if the direction I'm pursuing is even valuable.  If the end results aren't encouraging I'll start thinking about other strategies that get me what I want.

Sometimes visualizing the end result isn't very encouraging.  While updating our Chef recipes to add/update monitoring, we ran into a bug in the way that we were using an [external cookbook](https://github.com/racker/cookbook-cloudmonitoring).  After an hour or so investigating the problem without much success, I realized that at the end of my investigation, whatever the outcome, I would probably just discover that there was a bug in how we were using the code (which there [was](https://github.com/racker/cookbook-cloudmonitoring/pull/23)).  Just because I can sometimes visualize an outcome accurately doesn't mean that it changes anything about the work that needs to be done.

### Talk To Someone

Talking to someone else is so effective that it has its own terminology in the software industry: [rubber duck debugging](http://www.rubberduckdebugging.com/).  When I have to explain a problem to someone else, it requires that I explain the whole world of the problem to them: new technologies, configuration files, unsuccessful strategies, and why we're doing it in the first place.  Usually somewhere in this description there's something that I've forgotten: a missing assumption that allows a simpler solution or an approach that I thought about once but haven't explored.

### Walk Away

It's easy to spend a lot of time trying the same strategy without success, and the more time invested, the more that time becomes a sunk cost.  If I realize I'm too deep into a problem, I'll go home for the day, take a long walk, exercise: if a strategy has proved unsuccessful so far, another hour or two probably won't make a difference.

### Am I Stuck?

Of course all of these strategies rely on you even being _aware_ that you are stuck.  In graduate school I wasted weeks trying to solve problems unsuccessfully with the wrong strategies.  A lot of this is baked into the graduate student experience, but I could have spent a lot more time talking to people about these problems and bouncing possible solutions off them.  I just didn't know I was in a place where I was stuck: I thought the next step was going to validate all the work I had put in and everything would 'click'.

The more experience that I've gotten in software development, the more obvious it is when I'm entering an area I don't understand.  When I'm doing this kind of work, my guard is usually up and I'm constantly validating the work I'm doing to make sure I'm making progress towards a solution.

The other side of getting stuck is that exploring new areas is a great place to learn.  I wouldn't know as much as I do about Chef today if I didn't spend weeks getting stuck setting up Hadoop with Chef recipes.  We need to constantly tackle new problems to grow into better versions of ourselves.
