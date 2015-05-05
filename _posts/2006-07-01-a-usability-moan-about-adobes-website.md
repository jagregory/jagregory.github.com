---
layout: post
title: A usability moan about Adobe's website
tags:
- JavaScript
- Usability
- Web Design
status: publish
type: post
published: true
meta:
  dsq_thread_id: '644650486'
---
When recently performing a system-wide clean-out, I removed a long-expired Macromedia Flash 8 Studio trial. Unknown to me at the time, it had taken it upon itself to remove the flash player as-well; because, of course, now that I don't want to develop flash, I'll never need it again!

Anyway, a week or so later I discovered that I needed to re-install the player, so off I went to [Adobe's Website](http://www.adobe.com). When I arrived, I was presented with a fairly reasonable page - in terms of design - but there was something on there that epitomises the lack of thought that goes into usability on the web. People, you have to remember it isn't just about how you create your links (bad "click here”, no play-time for you!), it's also about how your content is worded.

<!-- more -->

![Adobe's no-flash warning message](/images/adobe-flash-small.jpg)

What you can see in the screenshot is what you're shown if you don't have the flash player installed (or JavaScript enabled, I'm guessing).

What's wrong with this picture?

It's very misleading, that's what.

The heading is asking me "Can't see this content?", but I can, can't I? I'm reading it! Oh, the word "this” isn't associated to what I'm reading (as it should be), but rather what I'm **not** reading. Interesting.

Misleading text has also found its way into the body content, once again, I am reading the content aren't I? Another thing is that the content also implies that I have JavaScript disabled when I actually don't. I believe you're statistically more likely to have a user without flash installed, than without JavaScript enabled. So with that in mind, it would have been a better idea to ask if they have flash first then ask about JavaScript. Even better would be to do a check to see if JavaScript is enabled, if it is you don't need to display that part of the message at all!

One last thing, those controls at the bottom; what are they doing there? I know (now) that they're there because the content that's supposed to be showing is a movie, but prior to having that knowledge surely they just reinforce the feeling that I am seeing what I'm supposed to. I have content, I have play controls, hey why aren't they working? They serve no purpose apart from to confuse the user.

## A slightly better picture

I've modified the content to be - in my eyes - a bit more respectable. It still isn't perfect, like I said above, some JavaScript detection would be nice. Here it is non-the-less though:

![An improved version of Adobe's message](/images/adobe-flash-fixed.gif)

"Reading this?"

I most certainly am.

"If you are reading this message, then you are unable to view our active content."

Oh dear, so that's what this is all about. How do I fix it?

"Please either download the latest version of the Macromedia Flash Player or enable JavaScript in your browser."

Will do, thanks for the help Mr. Usable Information Box.
