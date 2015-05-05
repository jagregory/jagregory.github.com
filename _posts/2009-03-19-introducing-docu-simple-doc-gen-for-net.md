---
layout: post
title: Introducing Docu - Simple doc gen for .Net
tags:
- docu
- Documentation
- Sandcastle
status: publish
type: post
published: true
meta:
  aktt_notify_twitter: 'no'
  _edit_last: '2'
---
Dilemma. People want API documentation (for [Fluent NHibernate](http://fluentnhibernate.org) specifically), but I don't want to associate myself with the awful MSDN-style documentation that's produced by Sandcastle.

<!-- more -->

Lets look at a recent Twitter conversation of mine:

<blockquote class="twitter-tweet" lang="en" markdown="0"><p lang="en" dir="ltr" markdown="0">Anyone have any tips on generating html docs from XML comments? Used to do it years ago with NDoc</p>&mdash; James Gregory (@jagregory) <a href="https://twitter.com/jagregory/status/1312895270">March 11, 2009</a></blockquote>

<blockquote class="twitter-tweet" lang="en" markdown="0"><p lang="en" dir="ltr" markdown="0">Man, sandcastle is so overly complex</p>&mdash; James Gregory (@jagregory) <a href="https://twitter.com/jagregory/status/1313079815">March 11, 2009</a></blockquote>

<blockquote class="twitter-tweet" lang="en" markdown="0"><p lang="en" dir="ltr" markdown="0">Sandcastle examples don&#39;t even work. This is shit.</p>&mdash; James Gregory (@jagregory) <a href="https://twitter.com/jagregory/status/1313167377">March 11, 2009</a></blockquote>

<blockquote class="twitter-tweet" lang="en" markdown="0"><p lang="en" dir="ltr" markdown="0">Why isn&#39;t sandcastle just a console app that takes a list of dlls and spits out html/chm? What&#39;s with all the batch files and XslTransforms?</p>&mdash; James Gregory (@jagregory) <a href="https://twitter.com/jagregory/status/1313112789">March 11, 2009</a></blockquote>

<blockquote class="twitter-tweet" lang="en" markdown="0"><p lang="en" dir="ltr" markdown="0"><a href="https://twitter.com/AndrewNStewart">@AndrewNStewart</a> Well Sandcastle requires chaining together several calls to 3+ applications before you get anything. I think I can beat that</p>&mdash; James Gregory (@jagregory) <a href="https://twitter.com/jagregory/status/1315443964">March 12, 2009</a></blockquote>

<blockquote class="twitter-tweet" lang="en" markdown="0"><p lang="en" dir="ltr" markdown="0">Are these Sandcastle generated MSDN-style API docs actually useful to anyone?</p>&mdash; James Gregory (@jagregory) <a href="https://twitter.com/jagregory/status/1315364767">March 12, 2009</a></blockquote>

<blockquote class="twitter-tweet" lang="en" markdown="0"><p lang="en" dir="ltr" markdown="0"><a href="https://twitter.com/pollingj">@pollingj</a> It&#39;s a dilemma. I don&#39;t care about API docs, but people seem to want it, but I&#39;m reluctant to generate msdn-like shit. Dilemma.</p>&mdash; James Gregory (@jagregory) <a href="https://twitter.com/jagregory/status/1315455082">March 12, 2009</a></blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

So as you can see, dilemma. People want API documentation (for [Fluent NHibernate](http://fluentnhibernate.org) specifically), but I don't want to associate myself with the awful MSDN-style documentation that's produced by Sandcastle.

> Before you get all hot under the collar, if you like Sandcastle, or you like MSDN-style documentation, leave now. Use what works for you, it doesn't work for me so I'm not using it, but I don't want to stop you using it.
>
> I realise the market for this tool is probably pretty small, but it's useful to me so it might be useful to you.

Introducing [docu](http://docu.jagregory.com), the simple documentation generator for .Net!

Docu is a tool that produces an html site (or rather, a collection of html pages) from the doc-comments you include in your code. Given an assembly and the Visual Studio produced XML of the comments, docu will produce a completely static collection of pages that you can publish anywhere you like. You run it through one command-line tool, with one parameter. That's it, nothing complicated.

    docu your-assembly.dll

You can see an example of the default style that's provided in the Fluent NHibernate [API docs](http://fluentnhibernate.org/api/index.htm) (the colour scheme has been modified, but everything else is default).

Docu is completely stand alone, no GAC deployed assemblies, no hard-coded paths, no nothing. This makes it trivial to use docu in your CI process for building up-to-the-second API docs for publishing or downloading.

The templates that docu uses are created with the [Spark view engine](http://sparkviewengine.com) which means you have all the power of C# and it's templating language at your finger-tips. If you're particularly picky about appearance (like I am) then you can completely rewrite the templates to your heart's content. There's no imposed structure or style, it's all customisable through the templates. You can read more about customising templates on the site: [customising templates](http://docu.jagregory.com/customising-templates).

An interesting little feature of the templating system is <em>special names</em> for directories and files, for example if you name a template <code>!namespace.spark</code>, a html page will be produced for a each namespace in your assembly using that template. This allows you to do things like create a directory for each namespace, with a page for each type in that namespace inside. Pretty powerful!

The codebase is reasonably well structured, but the code itself is a bit untidy. Luckily it's covered by nearly 200 unit tests (so far) and i'll be leveraging them to improve the code quality over time. You can checkout the code from the [docu github repo](http://github.com/jagregory/docu).

It's early days yet, there's very little customisation of the documentation process (the part that actually finds the types and members to document), and not all comment types are supported yet; however, it's used for Fluent NHibernate and works pretty well. It's only Alpha right now, so you shouldn't expect the world.

So if this kind-of thing interests you, go have a read of the [docu website](http://docu.jagregory.com) and let me know how it works out for you.
