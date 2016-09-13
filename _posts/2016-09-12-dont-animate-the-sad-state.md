---
layout: post
title: "\"Don't Animate the Sad State\""

---

My team spends most of its time building user-facing features into [Tilt](https://www.tilt.com). Day-to-day development involves hooking up our API into our mobile apps, making sure that the clients have the right screens and everything's layed out according to the mocks, and that the feature as a whole _works_ top to bottom.  Once we've gotten a feature working from top to bottom, we usually have a bit of time before we ship - it's time to polish!

But where should we spend our time doing polish?  While we spent a little time handling errors and recovering from unknown states gracefully, we try to spend most of our time working towards making the happy path as polished and delightful as possible.  My product partner summarizes this philosophy through a negative: _"Don't animate the sad state"_.

Planning an engineering team means always fighting the clock.  Engineers need time to deliver great outcomes - they need to add tests to make sure nothing breaks, change code in ways that are invisible to the product but allow the team to continue to move fast into the future, and chase down strange bugs that _should_ be impossible, but yet still happen.  On top of all that you still need to build a product!  The time you spend towards the product needs to always be impacting the highest number of users.

Because of this I would rather ...

* Animate the result of a "pay" button than an "ignore" button
* Add press states to button around the "top of funnel" parts of the app than on something eight screens down
* Polish the signup experience (new users) than the deactivate account experience (people who aren't likely to be with you much longer)
* Make the "got a push notification, take an action" flow as fast and seamless as possible, rather than the flow around a 'cold' app boot-up.

This doesn't mean you shouldn't spend time handling errors (not everything will always go right always!), you ideally you have some basic error framework (for example, a red "toast" message that pops up) that lets you signal failure ... and then you can spend the rest of your mental product/engineering/design/testing energy back towards those top-of-funnel happy paths that will affect most of your users who are trying to use the product.

I like this as an interview question too.  Everyone who's worked as an engineer knows that you always have a little extra time on a project before shipping - but where should you spend it?  The answer here can be really revealing of their values - candidates who view testing as optional will tell you "oh, I'd write tests" (but shouldn't we have written tests while we wrote the code?), while the architecture astronauts might talk about refactoring the code to make it easier to use in the future (but how do we know what use cases we'll have to support in the future?).  For me, the best candidates will view the quality of what they've produced as a given, and spend the extra time investing into the user experience to make it as great as possible.

## Summary

* Building a product, you always have a choice where to invest time
* Our goal is to get to "good enough" and ship
* Make sure the error path is presentable
* Spend the rest of your time making the happy path as awesome as possible