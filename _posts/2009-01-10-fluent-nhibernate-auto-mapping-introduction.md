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
> **Notice:** The content in this post may be out of date, please refer to the [Auto Mapping](https://github.com/jagregory/fluent-nhibernate/wiki/Auto-mapping) page in the [Fluent NHibernate Wiki](https://github.com/jagregory/fluent-nhibernate/wiki) for the latest version.
>
> **Note:** this was written against [r190](http://code.google.com/p/fluent-nhibernate/source/detail?r=190) of [Fluent NHibernate](http://www.fluentnhibernate.org), so you need to be at least at that revision to follow along.

Fluent NHibernate has a concept called Auto Mapping, which is a mechanism for automatically mapping all your entities based on a set of conventions.

Auto mapping utilises the principal of [convention over configuration](http://en.wikipedia.org/wiki/Convention_over_Configuration). Using this principal, the auto mapper inspects your entities and makes assumptions of what particular properties should be. Perhaps you have a property with the name of `Id` and type of `int`, the auto mapping might (and will by default) decide that this is an auto-incrementing primary key.

<!-- more -->

By using the auto mappings, you can map your entire domain with very little code, and certainly no XML. There are still scenarios where it may not be suitable to use the auto mapping, at which point it would be more appropriate to use the standard mapping; however, for most greenfield applications (and quite a few brownfield ones too) auto mapping will be more than capable.

## Getting started with a simple example

Although it isn't the purpose of this post give an in-depth walkthrough of Auto Mapping, it's not out of scope for a simple example! So I'll go through how to map a simple domain using the Fluent NHibernate AutoMapper.

Imagine what the entities might be like for a simple shop; in-fact, let me show you.

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

You can't get much simpler than that. We've got a product, with an auto-incrementing primary key called `Id`, a `Name` and a `Price`. The store has some shelves it fills with products, so there's a `Shelf` entity, which has an `Id` again, and a list of the `Product`s on it; the `Product` collection is a *one-to-many* or *Has Many* relationship to the `Product`.

> I'm going to make the assumption here that you have *an existing NHibernate infrastructure*, if you don't then it's best you consult a general NHibernate walkthrough before continuing.
>
> Unless otherwise specified, any code samples are assumed to be placed with your NHibernate `SessionFactory` initialisation code.

We're going to be using the `AutoPersistenceModel` to do our mapping. To begin with we should take a look at the static `MapEntitiesFromAssemblyOf<T>` method; this method takes a generic type parameter from which we determine which assembly to look in for mappable entities.

``` csharp
AutoPersistenceModel.MapEntitiesFromAssemblyOf<Product>();
```

That's it, you've mapped your domain... Ok, there might be a *little* bit more to do than that. Let me explain.

The `MapEntitiesFromAssemblyOf<T>` method creates an instance of an `AutoPersistenceModel` that's tied to the assembly that `Product` is declared. No mappings are actually generated until you come to  your entities into NHibernate.

A typical NHibernate setup looks something like this:

``` csharp
var sessionFactory = new Configuration()
  .AddProperty(ConnectionString, ApplicationConnectionString)
  .AddAssembly(typeof(Product).Assembly)
  .BuildSessionFactory();
```

What we need to do is get our auto mappings in the middle of that.

``` csharp
var autoMappings = AutoPersistenceModel
  .MapEntitiesFromAssemblyOf<Product>();

var sessionFactory = new Configuration()
  .AddProperty(ConnectionString, ApplicationConnectionString)
  .AddAutoMappings(autoMappings)
  .BuildSessionFactory();
```

Notice the substitution of `AddAssembly` for `AddAutoMappings`. This allows us to stop NHibernate from looking for `hbm.xml` files, and use our auto mapped entities instead.

> If you're dealing with an existing system, it might not be feasible to completely replace your existing entities with auto mapped ones; in this scenario, you can leave the `AddAssembly` call in there, and Fluent NHibernate will quite happily work with existing mappings.

We're now capable of getting NHibernate to accept our auto mapped entities, there's just one more thing we need to deal with. The auto mapper doesn't know which classes are your entities, and which ones are your services (and everything else). The setup we're using above simply maps every class in your assembly as an entity, which isn't going to be very useful; so I'll introduce one final method: `Where(Func<Type, bool>)`.

The `Where` method takes a lambda expression which is used to limit types based on your own criteria. The most common usage is limiting based on a namespace, but you could also look at the type name, or anything else exposed on the `Type` object.

``` csharp
var autoMappings = AutoPersistenceModel
  .MapEntitiesFromAssemblyOf<Product>()
  .Where(t => t.Namespace == "Storefront.Entities");
```

Bringing all that together leaves us with this NHibernate setup:

``` csharp
var autoMappings = AutoPersistenceModel
  .MapEntitiesFromAssemblyOf<Product>()
  .Where(t => t.Namespace == "Storefront.Entities");

var sessionFactory = new Configuration()
  .AddProperty(ConnectionString, ApplicationConnectionString)
  .AddAutoMappings(autoMappings)
  .BuildSessionFactory();
```

That's all there is to automatically mapping your domain entities. It's all a lot easier than writing out mappings, isn't it? There's much more to the auto mapping that I haven't covered here, and I hope to write about those soon. Until then, enjoy!
