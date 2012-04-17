---
layout: post
title: Latest on BooLangStudio
tags:
- .Net
- Boo
- BooLangStudio
- Hobby Projects
- Visual Studio
status: publish
type: post
published: true
meta:
  _edit_last: '2'
  aktt_tweeted: '1'
---
It's been a long time since I've written anything about <a href="http://www.codeplex.com/BooLangStudio">BooLangStudio</a>. Let me assure you that the development is still very much underway, and we're steadily working towards our first release.

To fill you in a bit on what's been going on. Jeffery Olson has completely rewritten the syntax highlighting to use the more flexible Boo.Pegs lexer, which allows us to overcome some of the obstacles we were facing with the traditional Boo lexer. There were limitations to what we could do with the traditional lexer, without modifying the Boo source. This was leading us down a road we weren't keen on, one of maintaining a fork of the Boo source that contained our specific changes. With the move to the Boo.Pegs lexer, we're free of this scenario!

![Syntax highlighting](/images/bls-1.png)

<a href="http://www.justnbusiness.com/">Justin Chase</a> has been tackling various issues all over the place. Several related to the build process, specifically how the Boo binaries are located on your machine, which has been a bit of a problem when there's multiple developers working on a project whom both have Boo installed in a different location. He's also been spiffing up the interface by adding some much needed icons to the projects.

![Project view](/images/bls-2.png)

<a href="http://www.codinginstinct.com/">Torkel Ödegaard</a> has been working various issues throughout the project. He's created a properties dialog for the project which allows you to alter the usual settings for your project, assembly name, default namespace etc... He also managed to get debugging working, which is awesome.

Then there's me, I've been working on the intellisense capabilities. We've had intellisense support from day one, but it's never been very extensive. For a long time it only worked on the current file you had open. 

The entire solution is now processed behind-the-scenes to provide intellisense. Import statements are now recognised and imported types appear in the local scope intellisense. Any assemblies or projects that are referenced have their top-level types and namespaces included in the intellisense too.

Additionally I've been working on improving the method suggestion logic, which was initially very flakey. It boils down to being able to transform the current line into the desired type, which can be difficult in certain cases (<code>StringBuilder().Append("Hello world").ToString().</code> for example).

![Code completion](/images/bls-3.png)

I believe that about covers what we've been upto lately. Our biggest problem currently is that most of these features are implemented in separate branches, and haven't yet been merged into our central repository. We're working on this, and I reckon once we've done that we'll be looking at doing a release.