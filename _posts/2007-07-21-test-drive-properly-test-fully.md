---
layout: post
title: Test-drive properly, test fully
tags:
- Code
- TDD
status: publish
type: post
published: true
meta:
  dsq_thread_id: '644650418'
---
I started writing this as a comment, but I felt it's own post was deserved.

[Ricky Clarkson](http://rickyclarkson.blogspot.com/) left me a link in a comment to one of [his posts](http://rickyclarkson.blogspot.com/2007/05/you-dont-need-tdd-you-need-repl.html) that ties in quite nicely to my recent [Getting with it: Test Driven Development](http://blog.jagregory.com/2007/07/17/getting-with-it-test-driven-development/) post.

Ricky makes the point that TDD can be dangerous, and can lull you into a false sense of security. *I agree.*

As with any technology, when used incorrectly it can cause more damage than not using it at all.

Ricky's example should serve as a double-barreled warning. You can't be test-driven only when it's convenient, and you need to have good test coverage.

<!-- more -->

## Being Test-Driven isn't being Convenience-Driven

Just by being in a car with seat-belts doesn't mean they'll save you when you crash, you need to actually wear them.

You can't pick and choose which parts of TDD you want to use, then be surprised when it lets you down.

If your boss comes storming in demanding a copy of the system, tell him to wait. Remember, it's your hide on the line, if you give him a broken system you'll be the one to pay. If he doesn't understand testing, lie, tell him it's building or something similar, it doesn't exist until it's finished.

## Test coverage

There's very little more important than good test coverage, without it you're leaving yourself wide open for problems.

In Ricky's example, he's fallen into a common problem with test design. *He's only testing the expected outcome of his method.* We've all fallen into this trap at some point, but it's a dangerous place to be. Without full coverage, just as Ricky said, you end up with a false sense of security.

For full test coverage of a method, you really need to test it's expected outcome, how it handles edge-cases, and how it handles bad data.

```scheme
(assert (equal (point+ (point 999 987) (point 789 998)) (point 1788 1985)))
```

Had Ricky's test suite included the above edge-case test, it would have caught the flaw in his method's design, and been able to correct it. A few more like the above, to cover minus numbers and very low values, and his situation would have been greatly different.

If there's a way you can improve testing, it's to write more unit tests. Only leave those bits you really can't test to integration. Everything else should be adequately covered.

## In parting

Remember, using TDD isn't an excuse to leave your common sense at the door. If you're writing a method which you know is going to be used in several places, test those several places, give it very good coverage. If you're writing a sum function like Ricky, you know how it's going to be used, don't just write if statements to cover all your input data, that's using coding to make a test pass an excuse to write bad code.
