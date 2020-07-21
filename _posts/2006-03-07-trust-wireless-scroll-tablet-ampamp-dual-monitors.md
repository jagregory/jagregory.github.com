---
layout: post
title: Trust Wireless Scroll Tablet with Dual Monitors
tags:
- Nuggets
status: publish
type: post
published: true
---
This was a task and a half! As I mentioned earlier I somehow managed to get my [Trust Wireless Scroll Tablet](http://www.amazon.co.uk/exec/obidos/ASIN/B0002DCL6G/202-4350795-3732661) working on a dual monitor system, mapped to only the primary monitor; so here's my little guide on how I managed it.

<!-- more -->

As far as I am aware there isn't an option in the trust software to allow you to map to a specific monitor, only to restrict the area on the tablet (which isn't at all helpful). So what I've figured out is purely a work around, and it isn't great either<sup>1</sup>. This is mainly for my reference, but someone else might find it useful, so here we go:

  * Open up Display Properties and disable ("un-attach") your secondary monitor.
  * Open the Trust Control Panel from the icon in your system tray.
  * Re-enable your second monitor.
  * Click ok in your Trust Control Panel.

From there on out your tablet should only be mapped to the monitor that stayed enabled the whole time, that is until you re-open the Trust Control Panel. I didn't say it was pretty!

What I can gather is that after disabling your monitor, when you open up the control panel it maps the overall screen size so it can apply that to the tablet, but when you click OK after re-enabling the monitor it doesn't refresh with the screen change and so uses the single monitor values.

<sup>1</sup> Also note that I have only tested this on my system.
