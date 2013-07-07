---
layout: post
title: Go Slice Visualiser
date: 2013-07-07 16:22
comments: true
tags:
- golang
type: post
published: true
---
I've been learning [Go](http://golang.org) recently; it's been fun.

An interesting aspect of Go is [Slices](http://blog.golang.org/go-slices-usage-and-internals), which are lightweight views of an array. Why these are useful and necessary makes more sense when you understand Go's [pass-by-value](http://golang.org/doc/faq#pass_by_value) semantics.

Whilst playing with slices, I put together a little visualiser to help understand their behaviour (the act of building it was probably more useful than the end result).

Enjoy: [Go Slice Visualiser](/slices)