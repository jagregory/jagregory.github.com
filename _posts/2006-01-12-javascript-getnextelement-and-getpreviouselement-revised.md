---
layout: post
title: JavaScript getNextElement and getPreviousElement - revised
tags:
- Code
- JavaScript
status: publish
type: post
published: true
---
> This is a very old post. Please, stop reading and just <a href="http://jquery.com/">download jQuery</a>.

As I said I would be in my previous post, I’ve been working on improving getNextElement. I’ve improved the overall performance of the function and also created a few others with similar purpose; including the sister function getPrevious element. I outline all the functions and their uses below; you can find the download link at the top and bottom of this post.

Any bugs anyone finds don’t fret to email me or post a comment here, i’ll work on fixing them asap.

<!-- more -->

## The Functions

### getNextElement & getPreviousElement

Basically this function is a more advanced, flexible version of the "element.nextSibling" and "element.previousSibling" properties. Features include the ability to specify the next element you’e looking for explicitly, so you can return the next list-item in a list (even if it happens to be a child of the current element) or the next matching node type. Also recursion is toggleable.

### getFirstChild & getLastChild

A core part of getNextElement/getPreviousElement, this function recursively searches an elements child nodes for a matching element. Can be used stand alone to only return from within an elements child structure; recursively parses the childNode structures of all child elements.

### getNextParent & getPreviousParent

Gets the next node in the DOM tree after the current nodes parent; this walks the DOM tree backwards until it finds a parent of the current node with a nextSibling/previousSibling present.

### isType

Detects whether a specified element is of correct type; compares against a numerical value (nodeType) or a string value (tagName).

## The Examples

Note: All functions that require an element as a parameter can either take a direct reference or a string ID value.

### getNextElement & getPreviousElement

Both functions take exactly the same parameters and are used in the same way, so I’ll only provide examples for one.

> Note: These functions also walk up the DOM tree, so if you have two lists and call getNextElement on the last list-item in the first list it will return the first item of the second list.

``` js
getNextElement(id);
```

Returns the next element, regardless of type, after id.

``` js
getNextElement(id, 'li');
```

Returns the next list item, after id; could potentially be a child of id.

``` js
getNextElement(id, 1);
```

Returns the next element with a nodeType of 1.

``` js
getNextElement(id, 'li', false);
```

Returns the next list-item that resides on the same level, or higher, as id; no child nodes are searched.

### Practical example:

``` html
<div id="popup">
  <h1>This is a popup</h1>
  <p id="paragraph">Below are some options:</p>
  <ul id="list">
    <li>Your first choice</li>
    <li id="secondItem">Your second choice</li>
  </ul>
</div>
```

``` js
getNextElement('popup');
```

Would most likely return whitespace.

``` js
getNextElement('popup', 1);
```

Would return the H1 tag.

``` js
getNextElement('paragraph', 'li');
```

Would return the first list-item, "Your first choice".

``` js
getPreviousElement('secondItem', 'ul');
```

Would return the UL element.

``` js
getPreviousElement('paragraph', 1);
```

Would return the paragraph element.

### getFirstChild & getLastChild

Once again, both these functions take the same parameters and behave the same way so I’ll only provide examples for one.

``` js
getFirstChild(id);
```

Returns the first child of id, regardless of type.

``` js
getFirstChild(id, 'li');
```

Returns the first child of id that is a list-item.

``` js
getFirstChild(id, 1);
```

Returns the first child of id that has a nodeType of 1.

### Practical example:

``` html
<div id="popup">
  <h1>This is a popup</h1>
  <p>Below are some options:</p>
  <ul>
    <li>Your first choice</li>
    <li>Your second choice</li>
  </ul>
</div>
```

``` js
getFirstChild('popup');
```

Would most likely return a Text node with some whitespace.

``` js
getFirstChild('popup', 1);
```

Would return the H1 element.

``` js
getFirstChild('popup', 'li');
```

Would return the first list-item, "Your first choice".

``` js
getLastChild('popup');
```

Once again, probably whitespace.

``` js
getLastChild('popup', 1);
```

Would return the UL element.

``` js
getLastChild('popup', 'li');
```

Would return the last list-item, "Your second choice".

### getNextParent & getPreviousParent

Again, both these functions take the same parameters, so I’ll only show one.

``` js
getNextParent(id);
```

Returns the node next to the parent of id.

### Practical example:

``` html
<ul>
  <li id="first">Item One</li>
</ul>
<ul>
  <li id="second">Item Two</li>
</ul>
```

``` js
getNextParent('first');
```

Would return the second UL element.

``` js
getPreviousParent('second');
```

Would return the first UL element.

### isType

``` js
isType(id, 'li');
```

Returns true if id has a tagName of ‘li’.

``` js
isType(id, 3);
```

Returns true if id has a nodeType of 3.

Download: <a href="#" title="DOM Navigation javascript file">domnavigation-1.1.js</a> *(this download is no longer available, sorry)*
