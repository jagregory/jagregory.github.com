---
layout: post
title: JavaScript Behaviour & getElementsBySelector() mini-fix
tags:
- Code
- JavaScript
status: publish
type: post
published: true
meta: {}
---
<a href="http://bennolan.com/behaviour/">Behaviour</a>, great bit of JavaScript!

While using it lately I came across a small bug in the code it’s based-on, <a href="http://simon.incutio.com/">Simon Willison</a>’s <a href="http://simon.incutio.com/archive/2003/03/25/getElementsBySelector">getElementsBySelector()</a>, when you use a selector that references an invalid ID paired with a tag name (e.g. <code>body#profile</code>, when <code>#profile</code> doesn’t exist), a script error occurs; yet using <code>#profile</code> alone works fine.

After a little bit of digging I found a solution, the source of the error is line 89:

``` js
if (tagName && element.nodeName.toLowerCase() != tagName) {
```

It’s finding the <code>tagName</code> (<code>body</code>), but element is undefined due to the ID being invalid. A slight change to the above if statement fixes the problem.

``` js
if (!element || (tagName && element.nodeName.toLowerCase() != tagName)) {
```

Maybe somebody will find that useful, I’ve posted it on Simons blog, but incase he doesn’t accept the change you can download the modified version here.

> Note: If you’re using Behaviour, as opposed to just <code>getElementsBySelector()</code>, you’ll need to paste the contents of the above file into the bottom of your behaviour.js file, overwriting everything after the <code>Behaviour.start();</code> line.
