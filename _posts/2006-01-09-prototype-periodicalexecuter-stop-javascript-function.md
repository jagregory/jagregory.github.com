---
layout: post
title: Prototype PeriodicalExecuter.stop() JavaScript function
tags:
- Code
- JavaScript
status: publish
type: post
published: true
meta:
  _wp_old_slug: prototype-periodicalexecuterstop-javascript-function
  _edit_last: '2'
  aktt_tweeted: '1'
  dsq_thread_id: '644650371'
---
Download: <a href="#" title="Prototype extensions javascript file">prototype-extensions.js</a>. *(this download is no longer available, sorry)*

I’ve been playing with the <a href="http://prototype.conio.net/">prototype framework</a> for a while now and am very impressed, the file size is a bit of a down point but that aside it’s excellent.

The one thing that has slightly irritated me (and <a href="http://roberthanson.blogspot.com/2005/11/prototypejs-periodicalexecuter.html" title=" Robert Hanson's Blog">others it seems</a>) is that there isn’t a stop function built into the PeriodicalExecuter object. Seems something strangly simple to miss out, especially as the Ajax.PeriodicalUpdater has one built in. With that in mind I’ve made an extension my self to perform this function.

I’ve simply placed the following code in a <a href="http://www.jagregory.com/downloads/prototype-extensions.js" title="Prototype extensions javascript file">prototype-extensions.js</a> file and referenced it wherever needed.

``` js
PeriodicalExecuter.prototype.registerCallback = function() {
  this.intervalID = setInterval(this.onTimerEvent.bind(this), this.frequency * 1000);
}

PeriodicalExecuter.prototype.stop = function() {
  clearInterval(this.intervalID);
}
```

There’s really nothing much going on in this code, all it does is take the current registerCallback function (which creates the actual timer) and stores its returned interval ID which we then use in the new stop function with the native clearInterval method.

Here’s an example implementation where I fire the PeriodicalExecuter when a key is released in a text box and then stop it once the call completes, this was the main reason I created this extension, my aim was to have a waiting period of a few seconds before a ajax lookup is performed; mainly to cut down on server calls. Each time the textbox changes the PeriodicalExecuter gets reset and started again which means the function will only ever fire once the countdown is complete.

``` html
<input type="text" id="changer" />
<script type="text/javascript">
  var pe;

  $('changer').onkeyup = function() {
    if (pe) pe.stop();
    pe = new PeriodicalExecuter(textChange, 5);
  }

  function textChange() {
    alert('check textbox content against database here');
    pe.stop();
  }
</script>
```

I’m sure this method of extension is probably frowned upon from within the community and changes are expected to be submitted for the actual library, but I needed a fix asap and I’m sure a few other people might too.
