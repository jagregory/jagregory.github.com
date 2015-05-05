---
layout: post
title: Static method abuse
tags:
- .Net
- Opinion
status: publish
type: post
published: true
meta:
  dsq_thread_id: '644650894'
---
I dislike static methods, there I said it.

Like everything, they have their place; but as the old analogy says, when you have a hammer everything looks like a nail. **Static methods are being abused.**

<!-- more -->

## Don't make me instantiate

For some reason programmers seem to be allergic to instantiating objects, to the point of where half the functionality is implemented in static classes and methods. You can go for days without seeing an instance in my current project's code-base.

I think it's symptomatic of a bigger problem. If you think creating instances is wasteful, maybe you're creating too many. You're most likely violating the Single Responsibility Principal (SRP) or Separation of Concerns (SoC). Too many dependencies usually means your class is trying to do too much, get it spit-up, and get it clean.

## State vs. stateless

One justification for using static methods that is often touted around is that if a method doesn't have any state, then it should be static. To me this is a fallacy, because state isn't everything. Take the following repository example:

### Using static methods

``` csharp
Customer customer = Repository<Customer>.FindByID(102);

customer.Name = "James";

Repository<Customer>.Save(customer);
```

### Using an instance

``` csharp
IRepository<Customer> repos = new Repository<Customer>();

Customer customer = repos.FindByID(102);

customer.Name = "James";

repos.Save(customer);
```

Noticeably the first example is one line less than the second. However, it's compromising readability in removing that line. Instead of using the `repos` instance, you're forced to fully-qualify every method call with `Repository<Customer>`, which is introducing more noise per-line.

Even though the methods `FindByID` and `Save` don't have any shared state, they both form a part of the encapsulation of data-access (in this case).

> If a method forms a key part of an encapsulation, then it shouldn't be static.

When you make the decision of creating a static method due to it being stateless, you're revealing more implementation details than necessary. A big part of encapsulation is hiding implementation details from the consumer.

While the methods are stateless, they might not always be that way; perhaps the repository could share a session between calls in the future. With an instance based design, you won't have any problems. Try introducing state into a static method, and things either get very messy, or you end up converting everything to instances and having to rewrite any usages.

> Static methods tie you in at an early stage to a specific design, making it very difficult to refactor out later.

## Not all bad

So where are the good static methods? *The `Math` class is a good example*. It contains a set of functions that are only loosely related (apart from being mathematical), that are guaranteed to be stateless, and most importantly are simple. Architecturally the methods in the `Math` class could be applied to a wide swath of objects (`int`, `float`, `double`, `decimal` etc...) and to have them as instance methods would complicate the class hierarchy more than it would benefit it.

> Static methods should be fire-and-forget, disposable, simple, and effective.

## Object-orientation

Static methods aren't associated with an object, they're tied to a type. This is a big distinction. People are under the belief that because statics sit in the same class definition as instance methods, that it makes them object-oriented.

Two key points of object-oriented design that static methods violate are inheritance and polymorphism. The inability to substitute a method with an implementation in a derived class is pretty unforgivable, and heavily restricting.

## Finally, testing

The argument that you're most likely to encounter against using static methods is that of testing. It's certainly one that I agree with, I just didn't want it to seem like that's the main reason of my argument.

Statics are bad for testing because they can't be substituted easily. A major part of unit testing is being able to isolate what you're testing from it's dependencies; isolation allows you to verify one part of the system at a time. Static methods aren't overridable in a sub-class, and so they aren't mockable either (without the use of TypeMock).

Of the two examples used above, in the first example it would be very hard to test that code without actually going to the database, because of the ties to the static methods. The second example could be refactored so the IRepository dependency is injected, and thus replaceable at test time.

Not being able to test in isolation is the final nail in the coffin for static methods and me.
