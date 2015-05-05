---
layout: post
title: Console colours wrapper
tags:
- .Net
- Code
- Nuggets
status: publish
type: post
published: true
meta:
  _edit_last: '2'
  aktt_tweeted: '1'
---
Continuing on from my post about an [alternative syntax for the non-disposable using statements](/writings/alternative-to-abusing-using/), here's a class I've been using lately. It serves as a wrapper around changing the colours in a console window. It's not a difficult thing to do, it's just a bit awkward because you have to maintain the original colour in a variable while you do your business.

<!-- more -->

``` csharp
Console.WriteLine("Start...")

var originalColour = Console.ForegroundColor;
Console.ForegroundColour = ConsoleColor.Red;

Console.WriteLine("WARNING!");

Console.ForegroundColour = originalColour;
```

It's not too bad when you're only doing it once, but when you start swapping colours all over the place, then it can become very noisy. So this is where my class comes into play. Using the same syntax I described in my previous post, I've wrapped up the colour changing in a helper method that takes an Action delegate. This allows you to write much more intention revealing code.

``` csharp
ConsoleColours.Foreground(ConsoleColor.Yellow, () =>
{
  Console.WriteLine("Different text");
});
```

I find this much cleaner and the blocks gives my console code some much needed separation.

Here's the full class code:

``` csharp
public class ConsoleColours
{
  public static void Foreground(ConsoleColor colour, Action action)
  {
    var original = Console.ForegroundColor;
    Console.ForegroundColor = colour;

    action();

    Console.ForegroundColor = original;
  }

  public static void Background(ConsoleColor colour, Action action)
  {
    var original = Console.BackgroundColor;
    Console.BackgroundColor = colour;

    action();

    Console.BackgroundColor = original;
  }
}
```
