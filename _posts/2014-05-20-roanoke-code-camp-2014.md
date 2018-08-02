---
layout: post
title: 'Roanoke Code Camp 2014'
is_unlisted: 1
---

Last Saturday I spent the day at [Roanoke Code Camp](http://roanokecodecamp.org), an event sponsored by the Roanoke Valley .NET Users Group.  While I don't have much familiarity with the .NET world (outside of some surface-level comparisons with Java), the sessions indicated the amount that web technologies and Microsoft Azure have unified technology choices between the "Microsoft world" and the "Linux world".

I attended sessions led by [Brian Lanham](http://geekswithblogs.net/codesailor), who talked about Redis, and [Brad Gignac](http://www.bradgignac.com/) (my coworker for the last two and a half years), who talked about both current best practices and frontiers in webapp technology.

I gave two talks that centered around traditionally Linux-focused technologies.  I described my talks as "postcards from the edge": technologies that are occupy a different space than the traditional .NET ecosystem, but have some valuable ideas to take back to your day-to-day even if you don't work with Linux.

## High Availability Web Applications With Cassandra

![](/images/2014-05-20-cassandra-consistency-queries.png)

[Slides](/talks/2014-roanoke-code-camp-high-availability-web-applications-with-cassandra.pdf) (662.27 KB)

I walk through Cassandra's data model, how gossip allows the cluster to handle failure, and how queries in Cassandra must be attached to a consistency level.  I describe how using Cassandra as session storage together with DNS managed by F5 Global Traffic Managers allows the Rackspace Cloud Control Panel to achieve redundancy in the face of datacenter failure.  Finally, I [demonstrate](https://github.com/tildedave/cassandra-flask-sessions) how you can use Cassandra to back your webapp sessions in a Flask application.

## Engineering for Visibility With Open Source Tools

![](/images/2014-05-20-continuous-improvement-cycle.png)

[Slides](/talks/2014-roanoke-code-camp-engineering-for-visibility-with-open-source-tools.pdf) (1.3 MB)

Expanding on my [Engineering for Visibility]({% post_url 2014-01-10-engineering-for-visibility %}) blog post, I talk a bit about team improvement, especially focused on "DevOps" teams, and how you need timeseries data to really enable team improvement.  I then discuss a number of open source tools that you can use to collect, store, and analyze timeseries data; primarily [Graphite](http://graphite.wikidot.com) and [statsd](https://github.com/etsy/statsd/), with discussions of [logster](https://github.com/etsy/logster), [logstash](http://logstash.net), and [collectd](http://collectd.org/).
