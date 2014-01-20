---
layout: post
title: ! 'Fluent NHibernate: Auto Mapping Entity Conventions'
tags:
- AutoMapping
- Conventions
- Fluent NHibernate
- FluentNHibernate
- NHibernate
- Tutorial
status: publish
type: post
published: true
meta:
  aktt_notify_twitter: 'no'
  _edit_last: '2'
  dsq_thread_id: '644650600'
---
> **Notice:** The content in this post is out of date, please refer to the <a href="https://github.com/jagregory/fluent-nhibernate/wiki/Auto-mapping">Auto Mapping</a> page in the <a href="https://github.com/jagregory/fluent-nhibernate/wiki">Fluent NHibernate Wiki</a> for the latest version.

<p>This post should be short and sweet. We want to alter our <strong>has many</strong> relationship from <code>Shelf</code> to <code>Product</code> so that it has a cascade set on it. We don&#8217;t want this to affect all one-to-many&#8217;s in our domain, so we need to do this alteration only on the <code>Shelf</code> entity rather than with an <code>ITypeConvention</code>.</p>

<p>So how exactly do you supply conventions only for a specific entity? Easy! with <code>ForTypesThatDeriveFrom<T>(ClassMap<T>)</code>.</p>

``` csharp
autoMappings
  .WithConvention(convention =>
  {
    // our conventions
  })
  .ForTypesThatDeriveFrom<Shelf>(map =>
  {
    map.HasMany<Product>()
      .Cascade.All();
  });
```

<p>The <code>ForTypesThatDeriveFrom</code> method takes a generic parameter that&#8217;s the entity you want to customise. The parameter is an expression that allows you to alter the underlying <code>ClassMap<T></code> that is generated by the auto mapper. Anything you can do in the non-auto fluent mapping, you can do in this override. So for our case, we map a <code>HasMany</code> of <code>Product</code>, and specify it&#8217;s cascade; this overrides the <code>HasMany</code> that will have been generated by the auto mapper.</p>

<p>That&#8217;s it. We&#8217;ve overridden the auto mapping explicitly for a specific type, while not affecting the general conventions of the system. You can do this for as many types as you need in your domain; however, baring in mind readability, it may sometimes be more appropriate to map entities explicitly using the standard fluent mapping if you find yourself overriding a lot of conventions.</p>