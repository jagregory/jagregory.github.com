---
layout: post
title: Launching woes
tags:
- .Net
- Work
status: publish
type: post
published: true
meta: {}
---
Launch problems, they always occur. Yesterday (1st September) was no exception, we launched this years Swift Leisure website; a bloody huge site. As soon as it got up there it fell over, which was unfortunate. After some investigation we narrowed it down to the Url Rewriter that we have in place (unfortunately, solely my work!).

The big problem with it was that it replaces the Request.ApplicationPath in any requested path with a blank string to remove any unnecessary parts of the path; `SwiftLeisure2006/Caravans/Abbey` became `Caravans/Abbey`. This worked fine on our local setup but we didn’t account for possible changes in the `Request.ApplicationPath` when the site is situated directly in the root instead of a sub-folder. The `Request.ApplicationPath` became just `/` which means `/Caravans/Abbey` became `CaravansAbbey` instead of `Caravans/Abbey`. Simple fix once we figured this out and found any similar sections throughout our controls.

Live and learn, live and learn.