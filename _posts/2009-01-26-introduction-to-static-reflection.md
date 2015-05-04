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
<blockquote>This post could've also been called "Fluent NHibernate secrets exposed!" but it sounded a bit sensationalist.</blockquote>

<p>You may have heard people mention static reflection recently, quite possibly because it&#8217;s used extensively in <a href='http://www.fluentnhibernate.org'>Fluent NHibernate</a>, <a href='http://ayende.com/projects/rhino-mocks.aspx'>Rhino Mocks</a>, and I believe <a href='http://www.lostechies.com/blogs/jimmy_bogard/'>Jimmy Bogard&#8217;s</a> new <a href='http://www.codeplex.com/AutoMapper'>AutoMapper</a> also uses it; pretty much any of the new &#8220;fluent&#8221; interfaces use some kind of static reflection.</p>

<p><strong>So what actually is static reflection?</strong> Well, it&#8217;s a statically compiled way of utilising the Reflection API.</p>

<p>Traditionally, if you wanted to use the Reflection API to interrogate your classes, you&#8217;d need to utilise strings to refer to properties and methods; this can make your design quite brittle, because you have to make sure these strings are kept up-to-date whenever you rename anything. What&#8217;s worse is that because reflection is late-bound, you aren&#8217;t aware of the problems until the code is actually executed, so this renaming could introduce hidden bugs that don&#8217;t appear until runtime. With the growing popularity of refactoring techniques, it&#8217;s becoming more important that we can use reflection without having to worry about this problem.</p>

<blockquote>
<p>It&#8217;s very true that tools like Resharper can certainly help with refactoring reflection-based code, but none of them are perfect and they only help the people that use them.</p>
</blockquote>

<p>In C# 3 we were introduced to lambda expressions and Linq, and with them came the <code>Func<></code> and <code>Expression<></code> classes; these are the key to static reflection. The <code>Func<></code> set of classes allow you to use lambda expressions that return a value, while an <code>Expression<></code> can be used to programatically access the contents of a delegate.</p>

<p>Combining <code>Func<></code> and <code>Expression<></code> can give us a very powerful way to statically retrieve <code>PropertyInfo</code> (and similar) instances from a lambda expression. For example <code>Expression<Func<Customer, object>></code> represents an expression that contains a delegate that returns a value (of type object), with a <code>Customer</code> parameter; I&#8217;ll illustrate:</p>

``` csharp
// method to receive an expression
public PropertyInfo GetProperty<TEntity>(Expression<Func<TEntity, object>> expression)

// usage
GetProperty<Customer>(customer => customer.Name);
```

<p>What this is actually doing is creating a lambda that returns a value, the value of <code>customer.Name</code> in this case. Here&#8217;s the trick, we don&#8217;t actually care about the value that&#8217;s returned! In-fact, we don&#8217;t even evaluate this expression at all.</p>

<blockquote>
<p>The reason we use <code>object</code> in the <code>Func</code> signature, rather than a more specific type, is because we want to allow <em>any</em> property to be used; however, if you were only interested in <code>string</code> properties, then you could restrict it by replacing this parameter.</p>
</blockquote>

<p>The <code>Expression</code> API itself is very in-depth, so I won&#8217;t go into the intricacies of it but here&#8217;s a very simple implementation of static reflection.</p>

``` csharp
public PropertyInfo GetProperty<TEntity>(Expression<Func<TEntity, object>> expression)
{
  var memberExpression = expression.Body as MemberExpression;

  if (memberExpression == null)
    throw new InvalidOperationException("Not a member access.");

  return memberExpression.Member as PropertyInfo; // Should account for FieldInfo too
}
```

<p>Stepping through this code, we start by getting the body of the expression which we cast to a <code>MemberExpression</code>; this is us grabbing the <code>customer.Name</code> part of our expression. Now we can get the member itself and cast it to a <code>PropertyInfo</code>, this is the <code>Name</code> part of the expression body. That&#8217;s it! We&#8217;ve not evaluated the expression, but we&#8217;ve inspected it and retrieved the property.</p>

<blockquote>
<p>This example is for illustrative purposes, there are many different types of expressions which would be excluded by this. If you are to implement your own static reflection parser, you should cater for these other types of expressions.</p>
</blockquote>

<p>As this example shows, we&#8217;re able to use reflection without having to resort to strings. The great thing about this is that if you change the name of a member inside a lambda, you&#8217;ll get a compile error if you haven&#8217;t updated all the references! No more hidden bugs.</p>

<p>So that&#8217;s how the magic behind Fluent NHibernate (and others) works, simple when you know how!</p>