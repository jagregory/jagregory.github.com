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
[Behaviour](http://bennolan.com/behaviour/), great bit of JavaScript!

While using it lately I came across a small bug in the code it's based-on, [Simon Willison](http://simon.incutio.com/)'s [getElementsBySelector()](http://simon.incutio.com/archive/2003/03/25/getElementsBySelector), when you use a selector that references an invalid ID paired with a tag name (e.g. `body#profile`, when `#profile` doesn't exist), a script error occurs; yet using `#profile` alone works fine.

After a little bit of digging I found a solution, the source of the error is line 89:

``` js
if (tagName && element.nodeName.toLowerCase() != tagName) {
```

<!-- more -->

It's finding the `tagName` (`body`), but element is undefined due to the ID being invalid. A slight change to the above if statement fixes the problem.

``` js
if (!element || (tagName && element.nodeName.toLowerCase() != tagName)) {
```

Maybe somebody will find that useful, I've posted it on Simons blog, but incase he doesn't accept the change you can download the modified version here.

> Note: If you're using Behaviour, as opposed to just `getElementsBySelector()`, you'll need to paste the contents of the above file into the bottom of your behaviour.js file, overwriting everything after the `Behaviour.start();` line.
