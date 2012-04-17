---
layout: post
title: JavaScript Console in Safari
tags:
- JavaScript
- Nuggets
status: publish
type: post
published: true
meta: {}
---
Just a quick tip to enable the Debug menu in Safari, the main reason being to get the JavaScript Console (ala Firefox).

Simply close down your open instances of Safari and enter this into the Terminal:

``` sh
defaults write com.apple.Safari IncludeDebugMenu 1
```

That’ll enable a new Debug menu next time you start Safari, simple as that. I was on the verge of loading up Firefox on the Mac
before I came across this, bad James!

Also, just in-case, running the above again with 0 will turn off the menu.
