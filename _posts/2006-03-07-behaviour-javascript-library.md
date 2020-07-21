---
layout: post
title: Behaviour JavaSctipt library
tags:
- CSS
- JavaScript
status: publish
type: post
published: true
meta: {}
---
Recently, while working on my website I've become exposed to the [Behaviour JavaScript library](http://bennolan.com/behaviour/), which I may say is absolutely wonderful. Very simple and straight forward, completely removes the need for those cursed script tags appended to the bottom of a page; something which I’ve never liked doing but became a bit of a necessary burden! In short it allows you to execute arbitrary code on elements in the DOM using CSS selectors; so, for example, you can apply an `onclick` event only to elements which match `form fieldset div#items a.add`<sup>1</sup>, very handy indeed!

<sup>1</sup> Any anchors with a class of "add", within a div with an ID of "items" that itself is within a fieldset in a form tag.
