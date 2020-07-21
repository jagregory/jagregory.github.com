---
layout: post
title: Debugging Internet Explorer and Stored Procedures
tags:
- .Net
- SQL
status: publish
type: post
published: true
meta: {}
---

> Note from future James: There's nothing practically useful here for you now, this has been long-since
> made irrelevant; however, it is an interesting insight into what things used to be like! Kids these
> days etc...
>
> Having a debugger for JavaScript wasn't part of the browser itself yet, Firebug was the first good
> example of this and but only came out the year of this post, and Chrome wasn't a thing for another
> 4 years. Instead you had to connect Visual Studio to Internet Explorer, and debug JavaScript that way.
>
> Similarly, Visual Studio could debug Stored Procedures. I remember this being particularly painful
> and involving copy-and-pasting DLLs into various directories in your system. I'm glad we don't
> work with Stored Procedures much anymore.

Debugging is a great thing... Often though I've dreamt of some greater, more useful debugger. It would have helped if I'd actually gone out and looked for such a thing.

Anyway, I haven't found a better debugger. I've found how to use the current one better! I've enabled client-side script debugging, which is fantastic. No more using IE or Firefoxes vague error messages, I can now step through code just as you would VB/C#.Net. The big one for me though has to be the ability to debug Stored Procedures, yes SQL Server Stored Procedures. Breakpoints, step-through, the lot.

<!-- more -->

Client-side debugging is so obvious I was kicking my self when I got it working. All you need to do is go into Tools > Internet Options > Advanced and check the Enable Client-Side Debugging" in Internet explorer. You may need to do some jiggery-pokery in VS but I can't remember what.

SqlServer is a bit more complicated, you need to copy the mssdi98.dll from your [visual studio installation]\\sqlserver folder into your sqlserver instances binn folder. Then open up Enterprise Manager and grant Exec permissions to the user you use to log-in (or the Builtin\\Administrators group) for the extended procedure sp_sdidebug. Lastly in your project options in VS mark the Enable Sql Debugging. That should be it, from the server explorer in VS you should now be able to choose step-into" from any stored procedure, function or trigger!

Productivity++
