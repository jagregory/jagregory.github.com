---
layout: post
title: On testing implementation
tags:
- .Net
- TDD
status: publish
type: post
published: true
meta: {}
---
I've found my-self in the situation of retro-fitting a library of code with unit tests, not a good situation to be in. However, what's more concerning is I've just caught my-self writing tests that are heavily testing the implementation of a method; rather than simply testing if the method does what it's supposed to.

There are a few problems with falling into this trap. Firstly, it's very brittle. Secondly, you shouldn't be concerned with the internals. Thirdly, it's very time consuming.

To elaborate...

It's brittle because you're essentially writing a script of how the method is going to execute, which of course will change whenever you do any refactoring. So your tests break every time you make a change to your code, which is not only annoying, but will quickly lead to <a href="http://martinfowler.com/bliki/TestCancer.html">test cancer</a>, where tests aren't run or are commented out.

You shouldn't be concerned with the internals, because as long as your method is doing as requested, you shouldn't really care how it's achieving it's goal. Not bolting down the internals allows methods to be refactored without too much resistance from the tests. This will increase the signal-to-noise ratio, allowing failing tests to be representative of a problem greater than your basic refactorings.

Finally, it's time consuming simply because you're duplicating most of your work. All the time you spent writing the method (or the test, if done first) is then duplicated writing the tests (or code...). This is a pain, because as mentioned above, you'll keep doing this work every time you change the method.

The hardest part is learning how to not do this kind thing blindly. There are plenty of times when you'll need this kind of testing, but don't make it your default! Test expectations, not implementations.
