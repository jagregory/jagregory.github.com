---
layout: page
title: "Go Slice visualiser"
date: 2013-07-07 15:46
comments: false
sharing: false
footer: true
styles:
  - slices
---
[This introduction to Slices](http://blog.golang.org/go-slices-usage-and-internals) explains the concept
well enough for me to not need to repeat it. This page is a tool to help you get your head
around how the slice operations work *visually*. The ten boxes below represent an array that you're creating
slices of, the input below them is your slice operation, and the black box you'll see is the resulting slice.

<div id="slice">
  <div id="sliceOverlay"></div>
  <div id="array"></div>
  <p id="error"></p>
  <p>slice[<input id="sliceInput" type="text" />]</p>
  <p>// e.g. slice[0], slice[:3], slice[1:3]</p>
</div>

<script type="text/javascript">
  var array = document.getElementById('array')
  var overlay = document.getElementById('sliceOverlay')
  var error = document.getElementById('error')

  var slice = {
    length: 10
  }

  for (var i = 0; i < slice.length; i++) {
    var div = document.createElement('div')
    div.innerText = '"' + String.fromCharCode(97 + i) + '"'
    array.appendChild(div)
  }

  var repositionSlice = function(low, high) {
    if (typeof low === 'undefined' || low === null) low = 0
    if (typeof high === 'undefined' || high === null) high = slice.length
    if (low < 0) throw 'invalid slice index ' + low + ' (index must be non-negative)'
    if (high < 0) throw 'invalid slice index ' + high + ' (index must be non-negative)'
    if (high < low) throw 'inverted slice index ' + low + ' > ' + high
    if (slice.length < high) throw 'slice bounds out of range'

    overlay.style.left = (low * 56) + 'px'
    overlay.style.width = ((high - low) * 56) + 2 + 'px'
    overlay.style.display = 'block'
  }

  var input = document.getElementById('sliceInput')
  input.addEventListener('keyup', function() {
    error.innerText = ''
    overlay.style.display = 'none'

    try {
      if (input.value.indexOf(':') >= 0) {
        var split = input.value.split(':')
        var start = split[0] === '' ? null : parseInt(split[0])
        var end = split[1] === '' ? null : parseInt(split[1])
        repositionSlice(start, end)
      } else {
        repositionSlice(parseInt(input.value), parseInt(input.value) + 1)
      }
    } catch (ex) {
      error.innerText = ex
    }
  })
</script>