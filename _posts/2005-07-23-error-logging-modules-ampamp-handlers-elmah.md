---
layout: post
title: ! 'ELMAH: Error Logging Modules & Handlers'
tags:
- .Net
status: publish
type: post
published: true
meta:
  dsq_thread_id: '644460838'
---
In my previous post I talked about my exception logging system that I laid to rest. Fortunately for me that doesn’t mean my applications are logless, quite the contrary. I’ll explain…

When I came to terms with my logging system being inadequate and hard to maintain, I began looking for a replacement. To my delight I came across [ELMAH](http://www.raboof.com/Projects/Elmah/Elmah.aspx)  written by [Atif Aziz](http://www.raboof.com). ELMAH is basically a couple of HttpModules and a HttpHandler that intercept any unhandled exceptions from within your application and log them. This is where the fun begins…

<!-- more -->

You can download/create extensions that enable you to save your logs to wherever takes your fancy. There is a SQL Server writer, an XML file writer and I believe an MySql writer too. I’m currently using the XML writer simply because connecting to the SqlServer may be one of the possible exceptions raised. I’ve been running ELMAH now for 2 weeks and have had no issues at all; especially no write-permission related ones!

This [MSDN Article](http://msdn.microsoft.com/library/default.asp?url=/library/en-us/dnaspp/html/elmah.asp" title="Using HTTP Modules and Handlers to Create Pluggable ASP.NET Components) by [Scott Mitchell](http://www.4guysfromrolla.com/ScottMitchell.shtml) was my manual for setting up ELMAH, not that it was hard. That article can explain it much better than I every could.

Once you’ve got it all set up and assigned a location to the HttpHandler, you can navigate there and be presented with a log viewer. Details of the exception and even the actual yellow screen that occurred too (through a dump of the html) can be accessed though that screen. The thing that got me really interested was the ability to subscribe to an RSS feed of your log! Now I no longer have to spend 40 minutes on the phone trying to decipher what really happened when the client claims they "didn’t touch a thing, it just crashed on its own". All you have to do is (in your favourite feed reader) enter your log viewer path with "/rss" added to the end (e.g. http://www.mysite.com/Logs/View.aspx/rss). Then you can get all the same details as navigating to the page, without actually having to do anything! Oh yes, life is good.

There was one thing I had to come to terms with while setting up ELMAH. That is the fact that only unhandled exceptions will be logged, so that meant most of my try-catch blocks were causing my exceptions not to be logged. The solution to this was to remove the blocks that weren’t performing any specific function except that of gobbling up the exception and firing out a generic error message. I felt uncomfortable with this at first, as I was letting exceptions run riot but then I realised there’s not much point in handling exceptions if I can’t actually do anything to correct the error that occurred. So letting them go unhandled is probably the best cause of action (what exactly can be done if your SqlConnection won’t connect? It’s not like you can just connect to your mirrored SQL Server). So those exceptions are bubbled up to the page and then ELMAH captures and logs them. Using the customErrors section of the web.config you can present your users with a generic error page to stop them from seeing the nasty yellow screen.

That my friends is the general gist of ELMAH...
