---
layout: post
title: Accessibility and browser standards
tags:
- Accessibility
- Web Design
status: publish
type: post
published: true
meta: {}
---
The web has come a long way in the past few years, but it is still hindered greatly by the methodology of the "previous generation" of web-designers. People are still designing with the mentality of serving everyone with a page that is specifically tailored to suit their particular browser and operating system. While this did get the job done originally, it was most certainly a lot more work than it needed to be. That's why I find the idea of generating one (and only one) document to serve all users very interesting. Most browsers are conforming to standards in some way shape or form, the majority support CSS2 and XHTML 1.1 and the ones that don't (mostly) degrade gracefully. It's no longer about serving a page that is pixel perfect on every system; it's about making sure all users get a good experience from your site.

Another branch of this takes the form of Accessibility. Accessibility has recently been highlighted by governments as a priority for websites; the US and UK both have their own take on the situation with relating laws and amendments. It basically boils down to any website that is providing a service should have a bare minimum of accessibility; otherwise they are discriminating against their less able customers. This means businesses are required, by law, to provide for all their customers (whether or not they have disabilities). Just as you would expect a shop to provide wheelchair ramps for disabled shoppers, you should expect pages to be designed to aid disabled web-users.

Recently I equipped my self with a screen-reader ([JAWS](http://www.freedomscientific.com/fs_products/software_jaws.asp)) and was appalled — but not particularly shocked — at the amount of sites that are simply unusable with anything other than a standard browser. Most pages are so full of invalid markup that the screen-readers simply mumble on continuously and any actual content is undecipherable. If websites complied to the standards then their experience would be tolerable at the very least. Unfortunately the majority of website designers simply do not know (or often care) about creating accessible pages.

> Note: Screen-readers, for those that don't know, take a web page and read it out using a synthesised voice. A perfectly accessible site would read the same as a printed document.

One of the largest problems with the way pages have been designed in the past has been using the supplied tags for their appearance rather than their actual purpose. The `<b>` tags have been used to create bold headings, the `<font>` tags used to change styles of fonts and worst of all the `<table>` tags for layout. This means when a screen reader parses these pages it emphasises the wrong words and spouts nonsense when encountering these convoluted tags. What a properly designed page would have is a distinct separation of content and layout, of HTML and CSS. The HTML document should use be structured like a standard plain text print document; with appropriate headings, sub-headings, lists and paragraphs. These tags can then be styled using CSS to any manner to which they like. So when a screen reader encounters this page it reads the unstyled version; a perfectly formed document.

That's the end of my little rant, maybe together we learned something.
