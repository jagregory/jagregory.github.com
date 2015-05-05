---
layout: post
title: Introduction to static reflection
tags:
- .Net
- C#3
- FluentInterface
- Reflection
- StaticReflection
status: publish
type: post
published: true
meta:
  aktt_notify_twitter: 'no'
  _edit_last: '2'
  dsq_thread_id: '644650340'
---
> This post could've also been called "Fluent NHibernate secrets exposed!" but it sounded a bit sensationalist.

You may have heard people mention static reflection recently, quite possibly because it's used extensively in [Fluent NHibernate](http://www.fluentnhibernate.org), [Rhino Mocks](http://ayende.com/projects/rhino-mocks.aspx), and I believe [Jimmy Bogard's](http://www.lostechies.com/blogs/jimmy_bogard/) new [AutoMapper](http://www.codeplex.com/AutoMapper) also uses it; pretty much any of the new "fluent" interfaces use some kind of static reflection.

<strong>So what actually is static reflection?</strong> Well, it's a statically compiled way of utilising the Reflection API.

<!-- more -->

Traditionally, if you wanted to use the Reflection API to interrogate your classes, you'd need to utilise strings to refer to properties and methods; this can make your design quite brittle, because you have to make sure these strings are kept up-to-date whenever you rename anything. What's worse is that because reflection is late-bound, you aren't aware of the problems until the code is actually executed, so this renaming could introduce hidden bugs that don't appear until runtime. With the growing popularity of refactoring techniques, it's becoming more important that we can use reflection without having to worry about this problem.

> It's very true that tools like Resharper can certainly help with refactoring reflection-based code, but none of them are perfect and they only help the people that use them.

In C# 3 we were introduced to lambda expressions and Linq, and with them came the `Func<>` and `Expression<>` classes; these are the key to static reflection. The `Func<>` set of classes allow you to use lambda expressions that return a value, while an `Expression<>` can be used to programatically access the contents of a delegate.

Combining `Func<>` and `Expression<>` can give us a very powerful way to statically retrieve `PropertyInfo` (and similar) instances from a lambda expression. For example `Expression<Func<Customer, object>>` represents an expression that contains a delegate that returns a value (of type object), with a `Customer` parameter; I'll illustrate:

``` csharp
// method to receive an expression
public PropertyInfo GetProperty<TEntity>(Expression<Func<TEntity, object>> expression)

// usage
GetProperty<Customer>(customer => customer.Name);
```

What this is actually doing is creating a lambda that returns a value, the value of `customer.Name` in this case. Here's the trick, we don't actually care about the value that's returned! In-fact, we don't even evaluate this expression at all.

> The reason we use `object` in the `Func` signature, rather than a more specific type, is because we want to allow <em>any</em> property to be used; however, if you were only interested in `string` properties, then you could restrict it by replacing this parameter.

The `Expression` API itself is very in-depth, so I won't go into the intricacies of it but here's a very simple implementation of static reflection.

``` csharp
public PropertyInfo GetProperty<TEntity>(Expression<Func<TEntity, object>> expression)
{
  var memberExpression = expression.Body as MemberExpression;

  if (memberExpression == null)
    throw new InvalidOperationException("Not a member access.");

  return memberExpression.Member as PropertyInfo; // Should account for FieldInfo too
}
```

Stepping through this code, we start by getting the body of the expression which we cast to a `MemberExpression`; this is us grabbing the `customer.Name` part of our expression. Now we can get the member itself and cast it to a `PropertyInfo`, this is the `Name` part of the expression body. That's it! We've not evaluated the expression, but we've inspected it and retrieved the property.

> This example is for illustrative purposes, there are many different types of expressions which would be excluded by this. If you are to implement your own static reflection parser, you should cater for these other types of expressions.

As this example shows, we're able to use reflection without having to resort to strings. The great thing about this is that if you change the name of a member inside a lambda, you'll get a compile error if you haven't updated all the references! No more hidden bugs.

So that's how the magic behind Fluent NHibernate (and others) works, simple when you know how!
