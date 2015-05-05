---
layout: post
title: ! 'Fluent NHibernate: Auto Mapping Conventions'
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
---
> **Notice:** The content in this post is out of date, please refer to the [Auto Mapping](https://github.com/jagregory/fluent-nhibernate/wiki/Auto-mapping) page in the [Fluent NHibernate Wiki](https://github.com/jagregory/fluent-nhibernate/wiki) for the latest version.
>
> This is a continuation of my previous [Auto Mapping Introduction](/writings/fluent-nhibernate-auto-mapping-introduction/) post, and is based on the same revision of [Fluent NHibernate](http://www.fluentnhibernate.org).

Auto mappings are generated based on a set of conventions, assumptions about your environment, that mean you can map your entire domain with a miniscule amount of code. Sometimes however, the conventions we supply are not to your liking, perhaps you're a control freak and want 100% control, or more likely you're working against an existing database that has it's own set of standards. You'd still like to use the auto mapper, but can't because it maps your entities all wrong.

Luckily for you we've thought about that, you can customise the conventions that the auto mapper uses.

<!-- more -->

> **What exactly is mapped using conventions?** As of [r190](http://code.google.com/p/fluent-nhibernate/source/detail?r=190): Default lazy load, cacheability, string length, ids, key names, foreign key column names, table names, many-to-many table names, version column names, and a wealth of specific property, one-to-one, one-to-many, and many-to-many overrides.
>
> Although we do allow you to customise a lot of things, not everything is covered yet. If you do encounter a scenario you can't handle, drop us a message on the [mailing list](http://groups.google.com/group/fluent-nhibernate), or even better: supply us a patch.

We'll continue with our store example from before, which comprised of a `Product` and a `Shelf`.

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

Using the standard auto mapping conventions, this assumes a database schema like so:

``` sql
table Product (
  Id int identity primary key,
  Name varchar(100),
  Price decimal,
  Shelf_id int foreign key
)

table Shelf (
  Id int identity primary key
)
```

Nothing too complicated there. The auto mapper has correctly assumed that our Ids are identity's and are primary keys, it's also assumed their names, the name of our foreign key to the `Shelf` table (`ShelfId`), and the length of our `Name` column.

Lets assume for the sake of this post that you're not happy with that schema. You're one of those people that prefers to name their primary key after the table it's in, so our `Product` identity should be called `ProductId`; also, you like your foreign key's to be explicitly named \_FK, and your strings are always a bit longer than `100`.

Remember this fellow?

``` csharp
var autoMappings = AutoPersistenceModel  
  .MapEntitiesFromAssemblyOf<Product>()  
  .Where(t => t.Namespace == &quot;Storefront.Entities&quot;);
```

Lets update it to include some convention overrides. We'll start with the Id name.

``` csharp
var autoMappings = AutoPersistenceModel
  .MapEntitiesFromAssemblyOf<Product>()
  .Where(t => t.Namespace == &quot;Storefront.Entities&quot;)
  .WithConvention(convention =>
  {
    convention.GetPrimaryKeyNameFromType =
      type => type.Name + &quot;Id&quot;;
  });
```

What we did there was use the `WithConvention` method to customise the `Convention` instance that the auto mapper uses. In this case we overwrote the `GetPrimaryKeyNameFromType` function with our own lambda expression; as per our function, our primary key's will now be generated as `TypeNameId`; which means our schema now looks like this:

``` sql
table Product (
  ProductId int identity primary key,
  Name varchar(100),
  Price decimal,
  Shelf_id int foreign key
)

table Shelf (
  ShelfId int identity primary key
)
```

> The convention functions are called against their respective mapping part for every generated entity, and the result of their execution is used to generate the mappings. The part that they work against is usually discernible from their name, or their parameters. `GetTableName` for example works against an entity `Type`, while `GetVersionColumnName` is called against every `PropertyInfo` gleaned from your entities. *As there is no API documentation (as of writing), it's a matter of intellisense poking to find which conventions are applicable to what you want to override.*

As you can see, our primary key's now have our desired naming convention. Lets do the other two together, as they're so simple; we'll override the foreign key naming, and change the default length for strings.

``` csharp
autoMappings
  .WithConvention(convention =>
  {
    convention.GetPrimaryKeyNameFromType =
      type => type.Name + &quot;Id&quot;;
    convention.GetForeignKeyNameOfParent =
      type => type.Name + &quot;_FK&quot;;
    convention.DefaultStringLength = 250;
  });
```

That's all there is to it, when combined with the other conventions you can customise the mappings quite heavily while only adding a few lines to your auto mapping.

This is our final schema:

``` sql
table Product (
  ProductId int identity primary key,
  Name varchar(250),
  Price decimal,
  Shelf_FK int foreign key
)

table Shelf (
  ShelfId int identity primary key
)
```

Next time: how to apply your own type conventions that apply to all properties of a specific type in your domain, and how to utilise NHibernate's `IUserType`s.
