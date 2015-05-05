---
layout: post
title: DateDiff() minus one VisualBasic assembly
tags:
- .Net
- Code
- Nuggets
status: publish
type: post
published: true
meta: {}
---
I'm not a big fan of using the `Microsoft.VisualBasic` assembly, I avoid it at all costs basically.

As we all know, the visual basic assembly comes with a large collection of built-in functions one of which is the `DateDiff` function. This takes two dates and a comparison value (e.g. `d` for day) and then spits out the difference.

Here's the same thing just minus the visual basic usage:

``` csharp
DateTime firstDate = DateTime.Now;
DateTime secondDate = new DateTime(2005, 8, 20);
TimeSpan difference = secondDate.Subtract(firstDate);

// days: difference.Days
```
