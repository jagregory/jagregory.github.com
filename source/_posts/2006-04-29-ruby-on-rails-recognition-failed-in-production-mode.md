---
layout: post
title: Ruby on Rails Recognition Failed in Production mode
tags:
- Nuggets
- Ruby
status: publish
type: post
published: true
meta: {}
---
The title pretty much covers it, but i’ll elaborate.

A few days ago I decided it was about time I had a tinker with <a href="http://www.google.com/webmasters/sitemaps">Google Sitemaps</a>, part of which involves uploading a temporary file so google can be sure the website you’re trying to claim is actually yours. Anyway, fun things aside, google gave me an error message (“We’ve detected that your 404 (file not found) error page returns a status of 200 (OK) in the header.”) when it tried to read the file.

The error message was caused by a feature of Ruby on Rails, which when in Development mode, invalid pages are still served by Rails and sent with a 200 header, but logged as having a Routing error of “Recognition failed”.

All information pointed to a simple fix of setting the rails environment (<code>ENV['RAILS_ENV']</code>) to production mode, which would disable the aforementioned feature. Unfortunately for me, my environment was <em>already</em> set to production! I double checked this, logged into the ruby console on my web-server and checked the variables, then even checked which log file was being written to; everything was pointing to it being in production mode.

After a lot of browsing of forums and chatting in IRC channels, I succumbed to randomly trying anything, which is when i noticed in my environment.rb file there was a line of code that I couldn’t for the life of me remember why it was in there, or what it was doing; removing this line of code worked a treat, everything snapped back to how it should be functioning.

For future reference, the line in question was:

``` ruby
require 'error_handler_basic' # defines AC::Base#rescue_action_in_public
```

So there you go, now I have a 404 page and google accepted my site map, so we can all live happily ever after.