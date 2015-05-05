---
layout: post
title: ! 'Fluent NHibernate: Auto Mapping Type Conventions'
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
  dsq_thread_id: '644650848'
---
> **Notice:** The content in this post may be out of date, please refer to the [Auto Mapping](https://github.com/jagregory/fluent-nhibernate/wiki/Auto-mapping) page in the [Fluent NHibernate Wiki](https://github.com/jagregory/fluent-nhibernate/wiki) for the latest version.

I've already covered how to auto map a basic domain, as well as how to customise some of the conventions that the auto mapper uses. There are some more in-depth customisations you can do to the conventions that I'll cover now.

<!-- more -->

We're going to use the same domain as before, but with a few extensions.

``` csharp
public class Product  
{  
  public int Id { get; set; }  
  public virtual string Name { get; set; }
  public virtual string Description { get; set; }
  public virtual decimal Price { get; set; }
  public virtual ReplenishmentDay ReplenishmentDay { get; set; }
}  

public class Shelf  
{  
  public virtual int Id { get; set; }  
  public virtual IList<Product> Products { get; set; }  
  public virtual string Description { get; set; }
}

public class ReplenishmentDay
{
  public static readonly ReplenishmentDay Monday = new ReplenishmentDay("mon");
  /* ... */
  public static readonly ReplenishmentDay Sunday = new ReplenishmentDay("sun");

  private string day;

  private ReplenishmentDay(string day)
  {
    this.day = day;
  }
}
```

We've extended our domain with a `Description` and a `ReplenishmentDay` for the `Product`; the replenishment day is represented by a type-safe enum (using the [type-safe enum pattern](http://www.javacamp.org/designPattern/enum.html)). Also there's a `Description` against the `Shelf` too (not sure why you'd have a description of a shelf, but hey, that's customers for you). These changes are mapped against the following schema:

``` sql
table Product (
  ProductId int identity primary key,
  Name varchar(250),
  Description varchar(2000),
  Price decimal,
  RepOn int,
  Shelf_FK int foreign key
)

table Shelf (
  ShelfId int identity primary key,
  Description varchar(2000)
)
```

Now, if you've been following along you'll remember that we made all strings default to 250; and yet the new description columns are 2000 characters long. The customer has stipulated that all descriptions of anything in the domain will always be 2000 or less characters, so lets map that without affecting our other rule for strings.

``` csharp
autoMappings
  .WithConvention(convention =>
  {
    convention.AddTypeConvention(new DescriptionTypeConvention());
    convention.DefaultStringLength = 250;

    // other conventions
  });
```

We're using the Fluent NHibernate's `ITypeConvention` support now, which allows you to override the mapping of properties that have a specific type. The `AddTypeConvention` method takes a `ITypeConvention` instance and applies that to every property that gets mapped. Baring in mind that our convention in this case is for a `string` property, and only for ones that are called "Description", lets see how the `DescriptionTypeConvention` is declared.

``` csharp
public class DescriptionTypeConvention : ITypeConvention
{
  public bool CanHandle(Type type)
  {
    return type == typeof(string);
  }

  public void AlterMap(IProperty propertyMapping)
  {
    if (propertyMapping.Property.Name != "Description") return;

    propertyMapping.WithLengthOf(2000);
  }
}
```

It's fairly expressive of what it does, but I'll cover it for completeness. The `ITypeConvention` specifies two methods: `bool CanHandle(Type)` and `void AlterMap(IProperty)`. `CanHandle` should be implemented to return `true` for types that you want this convention to deal with; this can be handled in any way you want, you could check the name, or it's ancestry, but in our case we just check whether it's a string. `AlterMap` is where the bulk of the work happens; this method gets called for every property mapping that has a type that `CanHandle` returns `true` for. We've implemented `AlterMap` to firstly check if the property is called "Description" (if it isn't, we do nothing) and then alter the length of the property. Simple really.

With a simple implementation like this, we're able to map every Description property (that's a `string`) so that it has a length of 2000, all with an addition of only one line to our auto mapping configuration.

<h2 id='iusertype_support'>IUserType support</h2>

The other alteration to our domain was the addition of the `ReplenishmentDay`. There were two interesting things to consider for this change. Firstly, it's stored in an `int` column, which obviously doesn't match our type; and secondly the column is called `RepOn`, which we mustn't change. We're going to utilise NHibernate's `IUserType` to handle this column.

<blockquote>
For the sake of this example we're going to assume you've got an `IUserType` called `ReplenishmentDayUserType`, but as it's beyond the scope of this post I won't actually show the implementation as it can be quite lengthy. It's best to just assume that the `IUserType` reads an `int` from the database and can convert it to a `ReplenishmentDay` instance. There's a [nice example of implementing `IUserType`](http://intellect.dk/post/Implementing-custom-types-in-nHibernate.aspx) on [Jakob Andersen](http://intellect.dk)'s blog.
</blockquote>

So how do we tell Fluent NHibernate to use an `IUserType` instead of the specified type? Easy, with another `ITypeConvention`.

``` csharp
autoMappings
  .WithConvention(convention =>
  {
    convention.AddTypeConvention(new DescriptionTypeConvention());
    convention.AddTypeConvention(new ReplenishmentDayTypeConvention());
    convention.DefaultStringLength = 250;

    // other conventions
  });
```

Here's how our new `ReplenishmentDayTypeConvention` looks:

``` csharp
public class ReplenishmentDayTypeConvention : ITypeConvention
{
  public bool CanHandle(Type type)
  {
    return type == typeof(ReplenishmentDay);
  }

  public void AlterMap(IProperty propertyMapping)
  {
    propertyMapping
      .CustomTypeIs<ReplenishmentDayUserType>()
      .TheColumnNameIs("RepOn");
  }
}
```

As you can see, we handle any `ReplenishmentDay` types, and then supply a `IUserType` using the `CustomTypeIs<T>()` method, and override the column name with `TheColumnNameIs(string)`. Again, easy!

So that's it, with those conventions we're able to keep our standard rule that all strings should be 250 characters or less, unless they're a Description, then they can be 2000 or less. Replenishment days use our type-safe enum, but are persisted to an `int` in the database, which also has a custom column name.

Next time: How to override conventions on an entity-by-entity basis.
