---
layout: post
title: ServerControlIDs Update
tags:
- .Net
- JavaScript
status: publish
type: post
published: true
meta: {}
---
I’ve created a small update for my ServerControlIDs control, which removes the problem caused by controls within Repeaters and DataGrid.

If you had a repeater that for each item contained an Hyperlink control, you’d get a duplicate entry in the ClientIDs object for every record, to avoid this problem I simply don’t output any sub-controls from within repeater style objects.

That may sound like a bit of a hack, maybe it is, but if you want to refer to multiple elements within another, you shouldn’t really be doing it by ID anyway.

You can get the <a href="http://www.jagregory.com/downloads/ServerControlIDs-1.1.zip">updated source here</a> or view the <a href="/writings/how-to-use-clientids-in-javascript-without-the-ugliness/" title="ASP.Net ClientIDs and their JavaScript companion">full article here</a>.
