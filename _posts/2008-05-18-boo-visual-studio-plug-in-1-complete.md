---
layout: post
title: ! 'Boo Visual Studio plug-in: 1% complete'
tags:
- .Net
- Boo
- Hobby Projects
- Visual Studio
status: publish
type: post
published: true
meta:
  _edit_last: '2'
  aktt_tweeted: '1'
  dsq_thread_id: '644650826'
---
What do we want? *A Boo plug-in for Visual Studio*. When do we want it? *Sooner, rather than later*.

The initial aim of this plug-in is to provide a "good enough" experience when using Boo files within other projects. I'm not currently focussing on doing full-scale development with Boo; so the target is DSLs and Binsor. There won't be any assemblies created, or anything else that would affect your project. The only difference between how you work now would be that you could write Boo using Visual Studio, with syntax highlighting and intellisense.

That's for the initial version anyway.

<!-- more -->

I've found that creating a plugin for Visual Studio isn't that difficult, in-fact that's an understatement, it's stupidly easy. Most of the plugin architecture is successfully created using the project wizard, so there's very little I needed to do from that point of view. The tricky part is getting Boo and Visual Studio to communicate.

I started by spending some time looking at the IronPython Studio implementation, the Boo implementation, abstract syntax trees, antlr, and after getting my head around what I needed to do, I set out on my adventure.

So what's the result? A very basic (and flakey) implementation of both syntax highlighting and intellisense.

![Boo Plugin syntax highlighting](/images/booplugin-syntax.jpg)

The highlighter isn't perfect yet. It suffers from slowdown when you're writing an unclosed string, and it can't handle multi-line statements yet (think comment blocks).

![Boo Plugin code completion](/images/booplugin-codecomplete.jpg)

The intellisense is pretty basic, it allows namespace navigation, and type methods, but there isn't much in the way of constraints (you can see instance methods against types, for example).

There's a lot of work to be done, but it's fun and interesting.

## Targets

In the near future I'd like to get the following done:

  * Make intellisense work with everything in the local scope
  * Make intellisense parse import statements
  * Make syntax-highlighting correctly handle multi-line blocks
  * Make syntax-highlighting highlight types (like C# does)

Then at some point tackle these:

  * Get Resharper involved
  * Refactoring support

Hopefully I'll progress on these and report back in a future post.

# Code

The code is poor, it's a mess and probably all wrong; however, you can get it in the usual place. However, I haven't provided a direct download because it isn't really in a state to be distributed yet.

The source is accessible from Subversion at: http://jagregory.googlecode.com/svn/trunk/BooPlugin/ (using user jagregory-read-only)
