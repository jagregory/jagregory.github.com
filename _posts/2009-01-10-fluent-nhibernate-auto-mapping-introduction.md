---
layout: post
title: ! 'Fluent NHibernate: Auto Mapping Introduction'
tags:
- AutoMapping
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
  dsq_thread_id: '644651125'
---
> <strong>Notice:</strong> The content in this post may be out of date, please refer to the <a href="https://github.com/jagregory/fluent-nhibernate/wiki/Auto-mapping">Auto Mapping</a> page in the <a href="https://github.com/jagregory/fluent-nhibernate/wiki">Fluent NHibernate Wiki</a> for the latest version.</p>

> <strong>Note:</strong> this was written against <a href="http://code.google.com/p/fluent-nhibernate/source/detail?r=190">r190</a> of <a href="http://www.fluentnhibernate.org">Fluent NHibernate</a>, so you need to be at least at that revision to follow along.</p>

<p>Fluent NHibernate has a concept called Auto Mapping, which is a mechanism for automatically mapping all your entities based on a set of conventions.</p>

<p>Auto mapping utilises the principal of <a href="http://en.wikipedia.org/wiki/Convention_over_Configuration">convention over configuration</a>. Using this principal, the auto mapper inspects your entities and makes assumptions of what particular properties should be. Perhaps you have a property with the name of <code>Id</code> and type of <code>int</code>, the auto mapping might (and will by default) decide that this is an auto-incrementing primary key.</p>

<p>By using the auto mappings, you can map your entire domain with very little code, and certainly no XML. There are still scenarios where it may not be suitable to use the auto mapping, at which point it would be more appropriate to use the standard mapping; however, for most greenfield applications (and quite a few brownfield ones too) auto mapping will be more than capable.</p>

<h2>Getting started with a simple example</h2>

<p>Although it isn't the purpose of this post give an in-depth walkthrough of Auto Mapping, it's not out of scope for a simple example! So I'll go through how to map a simple domain using the Fluent NHibernate AutoMapper.</p>

<p>Imagine what the entities might be like for a simple shop; in-fact, let me show you.</p>

``` csharp
public class Product
{
  public int Id { get; set; }
  public virtual string Name { get; set; }
  public virtual decimal Price { get; set; }
}

public class Shelf
{
  public virtual int Id { get; set; }
  public virtual IList<Product> Products { get; set; }
}
```

<p>You can't get much simpler than that. We've got a product, with an auto-incrementing primary key called <code>Id</code>, a <code>Name</code> and a <code>Price</code>. The store has some shelves it fills with products, so there's a <code>Shelf</code> entity, which has an <code>Id</code> again, and a list of the <code>Product</code>s on it; the <code>Product</code> collection is a <em>one-to-many</em> or <em>Has Many</em> relationship to the <code>Product</code>.</p>

> I'm going to make the assumption here that you have <em>an existing NHibernate infrastructure</em>, if you don't then it's best you consult a general NHibernate walkthrough before continuing.
>
> Unless otherwise specified, any code samples are assumed to be placed with your NHibernate <code>SessionFactory</code> initialisation code.

<p>We're going to be using the <code>AutoPersistenceModel</code> to do our mapping. To begin with we should take a look at the static <code>MapEntitiesFromAssemblyOf<T></code> method; this method takes a generic type parameter from which we determine which assembly to look in for mappable entities.</p>

``` csharp
AutoPersistenceModel.MapEntitiesFromAssemblyOf<Product>();
```

<p>That's it, you've mapped your domain... Ok, there might be a <em>little</em> bit more to do than that. Let me explain.</p>

<p>The <code>MapEntitiesFromAssemblyOf<T></code> method creates an instance of an <code>AutoPersistenceModel</code> that's tied to the assembly that <code>Product</code> is declared. No mappings are actually generated until you come to  your entities into NHibernate.</p>

<p>A typical NHibernate setup looks something like this:</p>

``` csharp
var sessionFactory = new Configuration()
  .AddProperty(ConnectionString, ApplicationConnectionString)
  .AddAssembly(typeof(Product).Assembly)
  .BuildSessionFactory();
```

<p>What we need to do is get our auto mappings in the middle of that.</p>

``` csharp
var autoMappings = AutoPersistenceModel
  .MapEntitiesFromAssemblyOf<Product>();

var sessionFactory = new Configuration()
  .AddProperty(ConnectionString, ApplicationConnectionString)
  .AddAutoMappings(autoMappings)
  .BuildSessionFactory();
```

<p>Notice the substitution of <code>AddAssembly</code> for <code>AddAutoMappings</code>. This allows us to stop NHibernate from looking for <code>hbm.xml</code> files, and use our auto mapped entities instead.</p>

> If you're dealing with an existing system, it might not be feasible to completely replace your existing entities with auto mapped ones; in this scenario, you can leave the <code>AddAssembly</code> call in there, and Fluent NHibernate will quite happily work with existing mappings.

<p>We're now capable of getting NHibernate to accept our auto mapped entities, there's just one more thing we need to deal with. The auto mapper doesn't know which classes are your entities, and which ones are your services (and everything else). The setup we're using above simply maps every class in your assembly as an entity, which isn't going to be very useful; so I'll introduce one final method: <code>Where(Func<Type, bool>)</code>.</p>

<p>The <code>Where</code> method takes a lambda expression which is used to limit types based on your own criteria. The most common usage is limiting based on a namespace, but you could also look at the type name, or anything else exposed on the <code>Type</code> object.</p>

``` csharp
var autoMappings = AutoPersistenceModel
  .MapEntitiesFromAssemblyOf<Product>()
  .Where(t => t.Namespace == "Storefront.Entities");
```

<p>Bringing all that together leaves us with this NHibernate setup:</p>

``` csharp
var autoMappings = AutoPersistenceModel
  .MapEntitiesFromAssemblyOf<Product>()
  .Where(t => t.Namespace == "Storefront.Entities");

var sessionFactory = new Configuration()
  .AddProperty(ConnectionString, ApplicationConnectionString)
  .AddAutoMappings(autoMappings)
  .BuildSessionFactory();
```

<p>That's all there is to automatically mapping your domain entities. It's all a lot easier than writing out mappings, isn't it? There's much more to the auto mapping that I haven't covered here, and I hope to write about those soon. Until then, enjoy!</p>
