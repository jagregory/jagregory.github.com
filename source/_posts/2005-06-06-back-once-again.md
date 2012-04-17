---
layout: post
title: ! 'Personal Note: The new job'
tags:
- Personal
- Work
status: publish
type: post
published: true
meta: {}
---
Since getting my new job I’ve been rather quiet on the blogging side of things, mostly do to the fact that I’m actually doing something with my time rather than just sitting around tinkering. Strange I know, but you get used to it.

As you’d probably expect, I’m not really supposed to talk about what I do for security reasons of course. It’s mostly working for the Swift group (caravans, motorhomes) doing their internal systems and web sites. Other things as well, but it’s mainly that. It’s all very interesting, a big change from serving customers in a supermarket thats for sure. It’s a really strange feeling actually going to work and learning something, I generally come home every night having picked something new up.

Since I started the job I’ve learnt that my coding abilities are much better than I thought they were, having being subjected to the woes that are legacy code. Definitely a nice feeling, it’s always rather hard to rate your abilities when you have nothing to compare them against. For better or for worse I’ve been developing in VB.Net, something I tried to stay away from when coding for my self but haven’t been able to avoid recently. Not my cup of tea really but it’s another addition to the CV. Speaking of legacy code, there’s been some serious Daily WTF material lying around. A prime example was this beauty:

``` vbnet
Sub Function GetTime(ByVal hours, ByVal minutes)
  Dim hours
  Dim minutes
  Dim yHours

  yHours = hours * minutes

  GetTime = (yHours / minutes) + (hours * minutes)
End Sub
```

Really interesting! Note the lack of any variable type declarations as well! It hasn’t all been like this, but there certainly a lot of amusing things.

One resource I’ve found invaluable since starting to code professionally is <a href="http://www.hanselman.com/">Scott Hanselman</a>’s <a href="http://www.hanselman.com/blog/content/radiostories/2003/09/09/scottHanselmansUltimateDeveloperAndPowerUsersToolsList.html">utilities list</a>, there are so many handy little tools there that I can’t believe I’ve managed to live without! Some perfect examples are <a href="http://www.aisto.com/roeder/dotnet/">Lutz’s Reflector</a> and <a href="http://www.sliver.com/dotnet/ruler/">Jeff Key’s Screen Ruler</a>. A tool for “reverse engineering” compiled .Net assemblies and a floatable screen ruler respectively.
