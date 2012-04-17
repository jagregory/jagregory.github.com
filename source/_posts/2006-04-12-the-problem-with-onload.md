---
layout: post
title: The problem with onload
tags:
- Code
- JavaScript
status: publish
type: post
published: true
meta: {}
---
Handling events from within your page has always been a hit and miss affair, especially for somebody who doesn’t like mixing their code and markup. The way to go with events for a long time was to embed an attribute on the element in question; like <code>onclick="do_something()"</code>.

That works fine, but we sure know it isn’t semantic. The way forward — greatly popularised by the <a href="http://prototype.conio.net">Prototype</a>, <a href="http://dojotoolkit.org/">Dojo</a> and <a href="http://bennolan.com/behaviour/">Behaviour</a> libraries — is to use DOM compliant event listeners. These fire arbitrary code, in a very similar way to attributes, when an event is raised. Unlike attributes these event listeners can be hidden away in their rightful place, the document header.

Perfect - clean semantic markup and real event handling.

…or is it? Unfortunately nothing is ever smooth when dealing with standards (it’s hard to promote the underdog when the underdog barely works anyway…).

## Our Problem

The biggest setback for using event listeners is that nothing will fire until the whole of the body has finished loading, including any images that need to be downloaded. This can cause something similar to the <a href="http://www.bluerobot.com/web/css/fouc.asp" title="Flash of Unstyled Content">FOUC</a>, where a page appears in one state for a moment until the javascript executes; not a pretty sight and generally hard to sell as a browser fault.

If you had the following code in your header tag, the element <code>aTable</code> would be visible until the page has finished loading, at which point it would suddenly disappear.

``` html
<script type="text/javascript">
  function hideATable() {
    document.getElementById('aTable').style['display'] = 'none';
  }

  Event.observe(window, 'load', hideATable, false);
</script>
```

What we really need is an <code>onBodyRendered</code> event to hook to, which fires as soon as the body has been parsed, irrelevant of whether the content has been loaded.

## The Solution
The only real solution to this problem, as there isn’t an <code>onBodyRendered</code> event, is to force the browser to parse our javascript before it has finished loading. The method of doing this is to embed a script block just before the end of the body tag containing the functions you wish to execute. The reason this works is because the browser parses any javascript it encounters within the body tag and evaluates it while rendering.

The following code would hide the table before the page has finished rendering; exactly what we want.

``` html
<script type="text/javascript">
  hideATable();
</script>
```

## My additions

The above method isn’t completely desirable, because it is still mixing code with markup and any code within the footer will not be cached. There isn’t much you can do about that really, but one thing that i’ve taken to doing in my websites is to make sure there is only ever one function call in that footer script block.

My method of doing such a thing is to create a special object that represents all my pages and their individual footer script blocks. You can see below an example of such an object, there’s an wrapper object that allows for further extensions (such as Unload or Validation sections) and then the Load object that contains each pages onload function. Each page then has a single line script block like `Pages.Load.Home();`

``` js
var Pages = {};

Pages.Load = {
  Home: function() {
    highlightSomething();
    hideSomething();
    saveCookies();
  },

  Portfolio: function() {
    hideSomething();
    makeMeLookGood();
  },

  Contact: function() {
    highlightFields();
  }
};
```

So the above code is stored in an external js file and loaded in the usual way, thus being cached.

### Before:

``` html
<script type="text/javascript">
  highlightSomething();
  hideSomething();
  saveCookies();
</script>
```

### After:

``` html
<script type="text/javascript">
  Pages.Load.Home();
</script>
```