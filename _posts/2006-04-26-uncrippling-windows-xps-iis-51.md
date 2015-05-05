---
layout: post
title: Uncrippling Windows XP's IIS 5.1
tags:
- Nuggets
status: publish
type: post
published: true
meta: {}
---
I apparently got around to reading [Coding Horror](http://www.codinghorror.com) a bit too late, as I missed [this gem](http://www.codinghorror.com/blog/archives/000329.html" title="Uncrippling Windows XP's IIS 5.1). It's an article about a small application used to bend XP's IIS to your every whim, perfect for those of us suffering at the hands of Microsoft.

The basic gist of the application is that it removes the limits of XP's IIS, namely the problem of only being allowed one website and 10 concurrent users. It takes a bit of getting used to, especially if you're using Visual Studio; if you are, remember to reset IIS to it's default website before opening a website created prior to using IISAdmin.
