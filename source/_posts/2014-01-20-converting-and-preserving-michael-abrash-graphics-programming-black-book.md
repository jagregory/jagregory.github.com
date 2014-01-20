---
layout: post
title: "Converting and preserving Michael Abrash's Graphics Programming Black Book"
date: 2014-01-20 06:45
comments: true
tags:
- gamedev
type: post
published: true
---

> **tl;dr** The Markdown source of Michael Abrash's Graphics Programming Black Book is available [on Github](https://github.com/jagregory/abrash-black-book) and you can read an online copy of the book [on my website](http://www.jagregory.com/abrash-black-book/).

It started out as an attempt to read [Michael Abrash's](http://en.wikipedia.org/wiki/Michael_Abrash) Graphics Programming Black Book over the Christmas period. It turned into a epic mission of `grep`, `sed`, and `awk`, and a few blisters.

<!-- more -->

But first...

## A brief history of 3D gaming

The 1990s was the era of the gaming and graphical revolution for the PC. Prior to which the PC still paled in comparison to the Apple II and the dedicated arcade machines. Things changed fast in this era. Competition was fierce, and the indie game movement (Shareware!) sparked a massive boom in the PC gaming industry. In the space of less than ten years, we went from VGA colour displays and software rendered 2.5D games like [Wolfenstein 3D](http://en.wikipedia.org/wiki/Wolfenstein_3D), to hardware accelerated full 3D multi-player online games like [Quake III Arena](http://en.wikipedia.org/wiki/Quake_III_Arena). That's progress for you.

In 1992 [id Software](http://en.wikipedia.org/wiki/Id_Software) released Wolfenstein 3D.

![](/images/abrash-black-book-1.png)

Then a year later in 1993 came [Doom](http://en.wikipedia.org/wiki/Doom_\(video_game\)).

![](/images/abrash-black-book-2.jpg)

The team at id Software were now furiously working on a sequel to Doom reusing the same engine. Everyone apart from John Carmack. As was the tradition John had now locked himself away and begun work on the next game engine, Quake. This one was going to be big. Full 3D, no more tricks. Real time lighting. 3D particle effects. Portals. Water. It was going to amaze.

This is when Michael Abrash joined id Software. Together, Michael and John built the Quake engine. After many sleepless nights and way too much Diet Coke, Quake was finished. 

In 1996 id Software released Quake. PC gaming had truely entered the forefront of 3D gaming.

![](/images/abrash-black-book-3.png)

If you're interested in learning more this period in gaming, you must read [Masters of Doom](http://en.wikipedia.org/wiki/Masters_of_Doom) by David Kushner.

## What's this all about then?

In 1997, just after finishing Quake, Michael compiled and published a book of his collective writing on graphics programming. Parts were already published around the Internet on Blues News and Dr. Dobbs mostly--blogging before blogging was a thing--and other parts were wrote about his work on Quake. It was a crazy dive into the world of graphics programming and assembly code optimisation, interspersed with some wonderful anecdotes and snippets of historical context. [Jeff Atwood wrote a lovely little tribute](http://www.codinghorror.com/blog/2008/02/there-aint-no-such-thing-as-the-fastest-code.html) to this book a few years ago.

> I know what you're thinking. "This book is about graphics. And assembly language. Plus it's from, like, 1996, which is approximately 1928 in computer years. It's of no interest to me as a programmer." Admit it. You are. But you know what you're going to do? You're going to click through anyway and read some of it. Just like in college, **the class topic doesn't matter when the instructor is a brilliant teacher**. And that's exactly what Abrash is.

![](/images/abrash-black-book-4.png)

Come Christmas 2013 and I'd entered my annual contemplation on course correcting towards building video games, a desire I've had ever since I got the shareware version of Wolfenstein 3D back in the early 90s. As usual, this lead me to reading a bunch on game development and rendering engines in particular. Mostly indulgent. It was Christmas, after all.

One of the articles I was reading, I can't remember which now, referenced Michael Abrash's Graphics Programming Black Book. And a flood of memories came back. I'd tried to read this book once before, I'd even owned it at one point. "I should read it again", my brain said.

My physical copy of the book was long gone. I turned to the Internet to try to buy it, out of print and over $200 on ebay. Even if I were willing to pay that, by the time it arrived my Christmas would be over (and probably my annual game developing desire too). "Ebooks, they're a thing now!" Sadly, the publisher had shut down a few years ago, so they've been struggling to keep up with the times. Thankfully, in 2001, Michael and Dr. Dobbs [released a PDF version of the book online](http://www.drdobbs.com/parallel/graphics-programming-black-book/184404919) for free. Gotta love these nerdy types, always giving their stuff away.

Unfortunately--and we're heading firmly into first-world problems here--the PDFs weren't the best format for reading casually on a ebook reader such as the Kindle. PDFs aren't the best format for text which needs to be reflowed, and a book split across multiple files even less so. For my own selfish purposes, I set out to convert the PDFs into something which I could read on my Kindle. I grep'd, and I awk'd, and I sed'd, and eventually I ended up with a set of rough Markdown files I could then convert to a Mobi ebook.

As with any yak shaving exercise, I missed the exit for *Good Enough* by a long margin. I invested more time than I'd originally planned. I think I was up to two days, casually, now. At this point I'd made it my mission to restore this work, as if it were some piece of classical literature, and preserve it for future generations.

> It does make me a little sad that books and online works like this--which influenced so many--can so easily fall away and be forgotten. Not just forgotten, but lost.

What I've ended up with is the book converted into Markdown, in a style which lends itself to ebook publishing. It wasn't my intention to preserve the layout or style of the book, just the content. In theory, you could read the pure Markdown files and get a quite enjoyable experience. If you choose to read the prepared versions, you benefit from a web-browser and e-reader compatible layout and some modern tweaks like syntax highlighting.

I contacted Michael about the work I've been doing on his book, and asked him if he'd have any issue with me releasing it on Github. His reaction was obvious, in hind sight, "The more people can read it, the better!".

## Getting your hands on it

  * Markdown source is available [on Github](https://github.com/jagregory/abrash-black-book).
  * [Each Github release](https://github.com/jagregory/abrash-black-book/releases) has a download in ePub and Mobi format.
  * There's a mirror of the current HTML version over [on my website](http://www.jagregory.com/abrash-black-book/).
  * The source has a `Makefile` for compiling your own ePub and Mobi's, if you've got [pandoc](http://johnmacfarlane.net/pandoc/) installed.

If you spot any issues whilst reading the book, please raise an issue on Github or send a Pull Request.

All rights, of course, still belong to Michael Abrash. Any errors are probably down to me.
