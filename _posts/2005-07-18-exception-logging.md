---
layout: post
title: Exception Logging
tags:
- .Net
- Work
status: publish
type: post
published: true
meta: {}
---
Something I've always been tinkering with for my ASP.Net applications has been exception logging. I often get irritated when users (or applications) supply me with misleading or incorrect error messages, or at least incorrect directions of how to recreate the error.

I worked for quite some time trying to create a Logging system that would cater for my needs, and I got quite close to doing that. I created a small go-between object for the Trace and Debug logging and wrote that to my own XML file. The idea behind it, of course, was to make it easier for my self in debugging problems, if I could supply my self with all the data that I know I would require to trace an issue then, in theory, I could correct it much more quickly. This took me quite some time to create and of course was not perfect.

<!-- more -->

There were a few major (a.k.a. Huge) issues with my system, firstly the logger would only interact with your code wherever you explicitly told it to. Basically you had to write extra code wherever you wanted to log an exception. This was neither friendly nor desirable. The next issue was access rights for the XML files; this reared its head in a few shapes and forms. One of the instances didn't occur very often but was a pain when it did; the writer was rejected write access due to another instance of itself actually writing to the file. I remedied this by making the writer wait until the other was done; this of course had performance implications though, having to stop everything within a page while the log writer sits idle. The other time it was an issue was whenever I wanted to archive the logs I had to wait until no other instances were accessing it, this also involved waiting but it takes longer to rename a file and create a new one than it does to simply amend a file.

The problem of having to explicitly declare any usage of the writer was the deciding factor in me binning my writer. Sad as it is to see something that I spent a fair amount of time creating deleted, it's always slightly reassuring when you're moving onto a product that is fully tested and working and also includes all source code! More on that soon though...
