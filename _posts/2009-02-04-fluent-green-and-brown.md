---
layout: post
title: Fluent green and brown
tags:
- Design
- FluentNHibernate
- Opinion
status: publish
type: post
published: true
meta:
  aktt_notify_twitter: 'no'
  _edit_last: '2'
---
To paint a very black-and-white picture, there are two camps of applications: greenfield and brownfield. Greenfield are generally nice, they have good separation of concerns, probably an IoC container, they may even be covered by unit tests. Brownfield apps are not. They generally don't have great separation of concerns (they're usually pretty concerned about everything), they definitely don't have great unit test coverage (but you're working on it!), and they don't have IoC containers.

<!-- more -->

If you're designing a framework you need to cater for both these markets. Unfortunately, they're both at odds with each other. A design that caters for inversion of control can sometimes be too verbose or "bitty" to use easily without a container. Similarly, if designed without a container in mind it will fall short for use with one; it'll be too tightly nit, too hard to break apart.

Although when Fluent NHibernate was started it was heading towards a design for greenfield, when I took over I steered it in the direction I thought was most important - brownfield. Fluent NHibernate has been aimed at being a drop-in replacement for your traditional NHibernate setup, simply replace your `CreateSessionFactory` method with ours and you're away. The problem is, by focussing so hard on brownfield, I've neglected the green.

I'm not apologising, because nobody has complained, but considerations need to be made for the other half. I still very much believe that Fluent NHibernate is heading in the right direction, we want to make life easier for those people who's lives are pretty damn hard (those greenfield guys have it easy anyway); however, I do believe considerations need to be made to allow Fluent NHibernate to be more accessible for those of us who have the pleasure of working in a well designed system.

**What does the future hold for Fluent NHibernate?** Supporting all of NHibernate's mapping options, making the automapper a lot more powerful, improving testability even more, and finally... giving some love to the PersistenceModel and SessionSource that the greenfield guys need.
