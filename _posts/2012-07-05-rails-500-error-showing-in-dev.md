---
layout: post
title: Rails production 500 error page showing in dev
tags:
- ruby
- rails
status: publish
type: post
published: true
---

> We're sorry, but something went wrong!

I've been seeing some strange behaviour on the development environment for [On the Game](http://www.getonthegame.com.au) recently. I've just spent an hour combing through every line of code that varies from a standard Rails app, and I've finally found the issue. I'm putting it here for posterity.

<!-- more -->

Regardless of my configuration, Rails was always displaying the production page for 500 errors (e.g. `public/500.html`) even in development mode.

I poked around for a while and eventually found it to be this:

I'd redefined `Enumerable#sum` somewhere (don't ask!), and my implementation didn't handle arrays of strings. That's it, that's why the detailed error page wasn't being shown in development.

Ends up, `Enumerable#sum` is used by the development error page, and when something on that error page itself raises an error Rails will just fall back and show the 500.html and not log anything.

Moral of the story: If you're seeing this behaviour, check you haven't (badly) monkey patched something that the error page is using.
