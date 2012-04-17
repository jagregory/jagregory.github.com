---
layout: post
title: Using Internet Explorer's conditional comments for targeted JavaScript
tags:
- Code
- JavaScript
status: publish
type: post
published: true
meta:
  dsq_thread_id: '644650537'
---
The <a href="http://blogs.msdn.com/ie/archive/2005/10/12/480242.aspx">demise of CSS hacks</a>, something which has been covered elsewhere to no end, definitely a good thing, but not what I’m covering here - not directly anyway. I’ve been wondering if we can take advantage of this new age of “hack segregation”.

The way I see it is we’re already breaking the rule of separation by using conditional comments in the structure, so why don’t we cease this opportunity to save our friends (users of Firefox, Safari, Opera etc...) some bandwidth by providing IE specific JavaScript in the same way too?

For those wondering what I could mean by “IE specific JavaScript”, an example would be simulating the CSS focus pseudo class on form elements - something highly recommended for an accessible and usable form - which aren’t implemented in the market standard versions of Internet Explorer (6 and below).

I don’t think users of compliant browsers should be punished by downloading extraneous scripts, loading events into the queue and then spending time evaluating code that doesn’t even apply to them.

I’m proposing that we devote a section of the page <code>head</code> tag to Internet Explorer, that’s simply a conditional comment section that contains any style sheets and script blocks that only apply to IE.

## Example 1 (what we are doing)

``` html
<!--[if lt IE 7]>
<link rel="stylesheet" type="text/css" href="/css/ie-specific.css" />
<![endif]-->
<script type="text/javascript" src="/js/ie-specific.js"></script>
<script type="text/javascript">
  addEvent(window, 'load', function() { if (document.all) { doIEStuff(); });
</script>
```

## Example 2 (what we could be doing)

``` html
<!--[if lt IE 7]>
<link rel="stylesheet" type="text/css" href="/css/ie-specific.css" />
<script type="text/javascript" src="/js/ie-specific.js"></script>
<script type="text/javascript">
  addEvent(window, 'load', doIEStuff);
</script>
<![endif]-->
```

In <em>Example 1</em> only Internet Explorer (prior to version 7) will download the stylesheet, but all browsers download the “ie-specific.js” JavaScript file and evaluate the <code>addEvent</code> code block. However if we follow <em>Example 2</em>, Internet Explorer will download the JavaScript and CSS just like normal, but other browsers simply see the whole section as a standard html comment and thus won’t download anything or evaluate the code block.

Wonderful, eh? I feel more comfortable with this approach than using questionable browser detection methods in JavaScript and it also reinforces (by just a tiny little bit) that compliant browsers are faster than their non-compliant brethren.
