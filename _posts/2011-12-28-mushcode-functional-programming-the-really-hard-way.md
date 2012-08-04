---
layout: post
title: 'MUSHCode: Functional Programming the Really Hard Way'

---

One of the main languages that I learned to program with is something that's not really a programming language in any accepted sense -- MUSHCode!  Back in high school and college I spent a lot of time logged in to [PennMUSH](http://www.pennmush.org/) installations.  MUSHes are like MUDs, except that while MUDs are mostly written in C, most MUSHes are powered by MUSHCode, an interpreted language that is build into the PennMUSH server.  (Non-technically, MUDs are usually more aimed at leveling up while MUSHes are more aimed at roleplaying.)

## What's a MUSH, and Why MUSHCode?

On a MUSH, the game world is populated by *objects*, and each object has a unique reference number (the *dbref*).  Objects have *attributes*, which can contain either data or code.  Certain attributes can listen for *commands* entered by the player, which triggers code execution.  For example, many MUSHes have a `+who` command, showing logged in players along with handy information (time logged in, location, what they are doing).

*Wizards* have the permissions to create objects and change any attributes on any object, anywhere.  In practice, Wizards build the systems that power the MUSH's roleplaying through writing MUSHCode.  MUSHCode is a layer on top of the PennMUSH server that provides things like background approval, roleplaying nominations, adjucated combat -- all the things necessary to take a tabletop game online.

## Why is MUSHCode Interesting

Code is the same as data -- data is stored on objects side-by-side with code.  We are already very close to Lisp!

There are two main code types of MUSHCode: *commands* and *functions*.  Commands are the only way to start code execution, and these are very powerful -- some fundamental things are only available as commands (namely, destruction of an object).  Functions are much more versitile and in general mode of your MUSHCode is made
up of functions.

Here's an example of a function:

```
th iter(1|2|3|4,add(##,1),|)
2 3 4 5
```

Here's an example of a command:

```
@pemit me=Hi there!
Hi there!
```

Some commands and functions have overlapping functionality but during my time writing MUSHCode I found functions much more useful.  When it was time to reach for behavior that was not exposed in a function, it was time to use a command -- otherwise commands were code entry points and functions would end up doing most of the work.

Javelin, uberdev of PennMUSH, wrote a [guide](http://community.pennmush.org/book/export/html/21) that talks about a lot of these things, and adds a lot more technical detail.

Functions have a stack limit -- you can't do too much work in a function or you'd run into errors.  We ran into this a lot building our Star Wars MUSH.

## The Greatest Game Never Released

I spent something like a year working, on and off, on a Star Wars MUSH that was never released.  I think this happens a lot in MUSH-land -- people have high ambitions about the kind of games that should be built.  Some games only work once you have a critical mass of code and I fear our concept was a little high on that front.  What we did build
seems amazing years later.

* Virtualized object system that allowed users to buy/trade/create fake objects for roleplaying purposes (mostly weapons -- lightsabers, blasters)
* Mostly complete space combat system implementing most of the Star Wars d20 space system -- turn-based space combat including movement, damage, collisions, missiles
* Viewscreens that linked ships and emitted events back and forth between the two
* Character generation and d20 roleplaying implementation
* Puppet system for Game Masters to create and command objects as puppets
* All the usual MUSH CRUD applications for opening/closing/commenting on issues

We apparently even wrote a bug database for keeping track of all the problems with the code I wrote!

## Example Code

Here's the code that powered interstellar transport.  This is a pretty simple object relatively -- a character goes to a location, sees that there is a transport node, and uses this object to teleport from one planet to another (while showing them the amount of time that this would take in-game to discourage planet-hopping for the sake of it).

```
PARENT: Intergalactic Transportation Node(#690TWn)
Type: THING Flags: WIZARD NO_COMMAND
An intergalactic transport node.  See [ansi(hy,+help transports)] for information as to their use.
Owner: Pozzo(#270POWwerACMcJ)  Zone: *NOTHING*  Building Chips: 10
Parent: *NOTHING*
Powers:
Channels: SpaceMonitor
Warnings checked:
Created: Thu May 20 20:53:07 2004
Last Modification: Sun Mar 18 17:53:42 2007
CMD_+TRANSPORT [#270R]: $^\+transport (.+)$:@switch [u(fn_cmd.+transport,%1)]=0,{th [syspemit(%#,%qz)]},1,{th [u(fn_cmd.do_+transport)]}
CMD_+TRANSPORT_LIST [#270R]: $^\+transport\/list$:@pemit %#=[u(fn_cmd.+transport_list)]
FN_CMD.DO_+TRANSPORT [#270]: [syspemit(%#,You take [setr(g,a transport from [ansi(hy,[name(loc(%!))])] to [ansi(hy,[name(%qd)])].  The trip takes [setq(h,u(fn_get_travel_time_between_systems,u(zone(loc(%!))/fn_get_system),u(zone(squish(%qd))/fn_get_system)))][iter(timestring(mul(%qh,60,60)),if(and(f(strmatch(##,0*)),f(strmatch(##,*m)),f(strmatch(##,*s))),##),,)] of IC time)]; please RP accordingly.)][tel(%#,%qd)][remit(loc(%!),[name(%#)] leaves on a transport.)][remit(%qd,[name(%#)] arrives on a transport.)][cemit(spacemonitor,%n takes %qg.,1)]
FN_CMD.+TRANSPORT [#270]: [setq(z,[setq(d,iter(u(fn_get_other_nodes),if(strmatch([squish(u(fn_get_name,##))],%0*),##),,))][if(f(%qd),%0 does not match any transport node.,if(gt(words(%qd),2),%0 matches more than one possible transport node; please be more specific.))])][f(%qz)]
FN_CMD.+TRANSPORT_LIST [#270]: [header(Transport Node: [u(get_name)],,hw,,b)]%r[ljust(ansi(g,Destination:),30)][ljust(ansi(g,Destination),15)][ansi(g,Travel Time (IC hours))]%r[iter(setr(l,iter(lattr(v(trans_db)/*_nodes),remove(xget(v(trans_db),##),loc(%!)),%b)),[ljust(u(fn_get_name,##),30)][ljust(if(isdbref(setr(g,u(zone(##)/fn_get_system))),u(%qg/get_name),%qg),15)][u(fn_get_travel_time_between_systems,u(zone(loc(%!))/fn_get_system),u(zone(##)/fn_get_system))],,%r)]%r[header(,[setr(w,words(%ql))] Destination[if(gt(words(%ql),1),s)],,hw,b)]
FN_GET_NAME [#270]: [setq(a,squish(rest(name(%0),:)))][if(hasattr(%0,display_name),xget(%0,display_name),if(strmatch(name(%0),*:*),%qa,if(strmatch(name(%0),*--*),after(name(%0),--%b),name(%0))))]
FN_GET_OTHER_NODES [#270]: setr(l,iter(lattr(v(trans_db)/*_nodes),remove(xget(v(trans_db),##),loc(%!))))
FN_GET_REGION_FOR_SYSTEM [#270]: [extract(grab(xget(v(hyper_obj),system_region_mapping),[edit(%0,%b,_)]|*),2,1,|)]
FN_GET_REGION_NUMBER_FOR_SYSTEM [#270]: [member(xget(v(hyper_obj),space_regions),extract(grab(xget(v(hyper_obj),system_region_mapping),[edit(%0,%b,_)]|*),2,1,|))]
FN_GET_SYSTEM [#270]: [if(hasattr(loc(loc(%0)),wing),loc(loc(loc(%0))),if(xget(loc(%0),ship),loc(loc(%0)),ulocal(zone(loc(%0))/fn_get_system)))]
FN_GET_TRAVEL_TIME_BETWEEN_SYSTEMS [#270]: [setq(0,if(isdbref(%0),squish(rest(name(%0),:)),%0))][setq(1,if(isdbref(%1),squish(rest(name(%1),:)),%1))][mul(extract(extract(xget(v(hyper_obj),space_travel_times),ulocal(fn_get_region_number_for_system,%q0),1,|),ulocal(fn_get_region_number_for_system,%q1),1),2)]
GET_NAME [#270]: [name(loc(%!))]
HYPER_OBJ [#270]: #405
TRANS_DB [#270]: #691
```

* `CMD_+TRANSPORT` is the entry point.  You type in `+transport LOCATION` to be transported to a location (specified by name).
* `FN_CMD.+TRANSPORT` does validation: take the list of other transport nodes.  Get their names.  Make sure that the string that the user typed matches one and only one of them.
* `FN_CMD.DO_+TRANSPORT` performs the action.  It's worth examining this one more closely.

```
[syspemit(%#,
 You take [setr(g,a transport from [ansi(hy,[name(loc(%!))])]
 to [ansi(hy,[name(%qd)])]. The trip takes
 [setq(h,u(fn_get_travel_time_between_systems,
         u(zone(loc(%!))/fn_get_system),
         u(zone(squish(%qd))/fn_get_system)))]

 [iter(timestring(mul(%qh,60,60)),
    if(and(f(strmatch(##,0*)),
           f(strmatch(##,*m)),
           f(strmatch(##,*s))),##),,)] of IC time)]; please RP accordingly.)]

[tel(%#,%qd)]
[remit(loc(%!),[name(%#)] leaves on a transport.)]
[remit(%qd,[name(%#)] arrives on a transport.)]
[cemit(spacemonitor,%n takes %qg.,1)]
```

* `setr` sets a local variable and returns that value for later use.  There doesn't appear to be a reason to save the name of the leaving location here -- looks like dead code!
* `setq` sets a local variable and returns nothing.  Here we set register 'h' to the travel time (in hours) between the two systems.  This is mostly used to make the code more 'readable' by breaking out separate concepts into their own computation.
* The travel time between systems is computed by calling the `fn_get_travel_time_between_systems` on the 'systems' where the different transport nodes are located.  This is an involved computation that I won't get into.
* We multiply `%qh` by 60 minutes and 60 seconds to get the number of seconds of travel time.  (Needed to pass to `timestring`, which returns a nicely formatted list of days, hours, minutes, and seconds from a num of seconds.)
* The iter over a timestring is just plucking the 'hours' out of a string of the format `0d  8h 47m 21s` in a particularly awful way.
* `tel` actually teleports the player to the other location.
* `remit` sends a message to the former and current location of the players.
* `cemit` sends a message to a channel.

Here setq forms the `let`-mechanism of the language. `iter` forms the standard mapping function, with the argument passed in being code that takes an argument of `##` -- a lambda!

## Good Things

MUSHCode made me a much better programmer, and I didn't even notice it was happening while it was being done.  While I was working during the day on my coursework in graduate school and undergraduate, in the evenings and weekends I would hack away on building the systems to power this MUSH.

The everything-is-just-a-string mentality of MUSHCode made adapting to functional languages a breeze -- in the `iter()` example above, the second argument is code that will be executed as the list of iterated through, substituting `##` for the current argument.

I came up with a code style that was my own that still looks pretty clean today.  The work that I did was also a huge help in breaking down product requirements and developing a technical plan -- the kind of thing that we do every day as software developers.

The thing that I find so amazing looking back is how clearly learning this 'language' influenced my development as a programmer ... even while I didn't think I was doing anything of the kind!
