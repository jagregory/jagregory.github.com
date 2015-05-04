---
layout: post
title: Plugin baby steps
tags:
- .Net
- Hobby Projects
- Opinion
status: publish
type: post
published: true
meta:
  aktt_tweeted: '1'
---
Making a Visual Studio 2008 plugin isn't as hard as it sounds.

Making one that works is a bit more difficult.

Syntax highlighting is fairly straight forward, just run a tokenizer over the text and colour code each token appropriately. It's the code sense that is causing me to go slightly mad. To determine what methods need to be listed when the intellisesne pops up, you need to parse the code that's in the document, then resolve any classes and references in there to build up a collection of methods to display. It gets more tricky when the document isn't valid, because you can't compile it. That's where I am now, I need to figure out some way of partially compiling the document, or maybe using an AST walker.
