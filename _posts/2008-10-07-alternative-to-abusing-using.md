---
layout: post
title: Alternative to abusing using
tags:
- .Net
- Code
- Nuggets
- Opinion
status: publish
type: post
published: true
meta:
  _edit_last: '2'
  aktt_tweeted: '1'
  dsq_thread_id: '644651347'
---
There's been a bit of discussion of late about using statements, and how they're more often being used for purposes other than just releasing resources. As always, there are those people who think it's a flagrant abuse of a feature and shouldn't be done, then there are those that like it. I'm in between. I do like what the using statement gives us, but I also think it is a bit of an abuse.

The "traditional" usage of the using statement can be found quite often in the land of files and streams. Take the following example, which opens a file and then closes it when it drops out of the using scope.

``` csharp
using (var stream = File.OpenRead("myFile.txt"))
{
  // do something with the file
}
```

Examples of the alternative usage can be found all over the place, but Rhino Mocks is one that's close to my heart. Here's from the record/replay syntax, anything in the scope of the using is recorded, and once it drops out of scope it's no longer in record mode.

``` csharp
using (mocks.Record())
{
  Expect.Call(customer.Address)
    .Return("123 Rester St");
}
```

Again, I do like what the using statement gives us outside of releasing resources (I'm not disputing it's usefulness there). However, I think the using keyword itself adds noise and clouds intention.

With the adoption of 3.5, I've started using an alternative syntax instead of usings. Actions and anonymous methods to the rescue.

``` csharp
Scope(() =>
{
  // do something within this scope
});
```

It's a little bit more noisy in the compiler satisfying department, but because you have full control over naming, you can reveal intention more. No more unclear "using".

So how does it work? Simple really, the method takes an Action delegate, which it the executes almost immediately. I say almost, because you can execute code before and after the execution. That gives you the benefits of the using statements wrapping ability.

``` csharp
public void Scope(Action action)
{
  // do something before
  action();
  // do something after
}
```

Some more examples:

``` csharp
File.OpenRead("myFile.txt", file =>
{
  // do something with the file
});
```

``` csharp
mocks.Record(() =>
{
  Expect.Call(customer.Address)
    .Return("123 Rester St");
});
```

I prefer this syntax over the using statement. Of course, it's only valid for 3.5 projects.