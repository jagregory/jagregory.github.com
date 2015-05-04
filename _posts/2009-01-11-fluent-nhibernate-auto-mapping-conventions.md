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
> **Notice:** The content in this post is out of date, please refer to the <a href="https://github.com/jagregory/fluent-nhibernate/wiki/Auto-mapping">Auto Mapping</a> page in the <a href="https://github.com/jagregory/fluent-nhibernate/wiki">Fluent NHibernate Wiki</a> for the latest version.

> This is a continuation of my previous <a href="/writings/fluent-nhibernate-auto-mapping-introduction/">Auto Mapping Introduction</a> post, and is based on the same revision of <a href="http://www.fluentnhibernate.org">Fluent NHibernate</a>.

<p>Auto mappings are generated based on a set of conventions, assumptions about your environment, that mean you can map your entire domain with a miniscule amount of code. Sometimes however, the conventions we supply are not to your liking, perhaps you&#8217;re a control freak and want 100% control, or more likely you&#8217;re working against an existing database that has it&#8217;s own set of standards. You&#8217;d still like to use the auto mapper, but can&#8217;t because it maps your entities all wrong.</p>

<p>Luckily for you we&#8217;ve thought about that, you can customise the conventions that the auto mapper uses.</p>

<blockquote>
<p><strong>What exactly is mapped using conventions?</strong> As of <a href='http://code.google.com/p/fluent-nhibernate/source/detail?r=190'>r190</a>: Default lazy load, cacheability, string length, ids, key names, foreign key column names, table names, many-to-many table names, version column names, and a wealth of specific property, one-to-one, one-to-many, and many-to-many overrides.</p>

<p>Although we do allow you to customise a lot of things, not everything is covered yet. If you do encounter a scenario you can&#8217;t handle, drop us a message on the <a href='http://groups.google.com/group/fluent-nhibernate'>mailing list</a>, or even better: supply us a patch.</p>
</blockquote>

<p>We&#8217;ll continue with our store example from before, which comprised of a <code>Product</code> and a <code>Shelf</code>.</p>

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

<p>Using the standard auto mapping conventions, this assumes a database schema like so:</p>

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

<p>Nothing too complicated there. The auto mapper has correctly assumed that our Ids are identity&#8217;s and are primary keys, it&#8217;s also assumed their names, the name of our foreign key to the <code>Shelf</code> table (<code>ShelfId</code>), and the length of our <code>Name</code> column.</p>

<p>Lets assume for the sake of this post that you&#8217;re not happy with that schema. You&#8217;re one of those people that prefers to name their primary key after the table it&#8217;s in, so our <code>Product</code> identity should be called <code>ProductId</code>; also, you like your foreign key&#8217;s to be explicitly named _FK, and your strings are always a bit longer than <code>100</code>.</p>

<p>Remember this fellow?</p>

``` csharp
var autoMappings = AutoPersistenceModel  
  .MapEntitiesFromAssemblyOf<Product>()  
  .Where(t => t.Namespace == &quot;Storefront.Entities&quot;);
```

<p>Lets update it to include some convention overrides. We&#8217;ll start with the Id name.</p>

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

<p>What we did there was use the <code>WithConvention</code> method to customise the <code>Convention</code> instance that the auto mapper uses. In this case we overwrote the <code>GetPrimaryKeyNameFromType</code> function with our own lambda expression; as per our function, our primary key&#8217;s will now be generated as <code>TypeNameId</code>; which means our schema now looks like this:</p>

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

<blockquote>
<p>The convention functions are called against their respective mapping part for every generated entity, and the result of their execution is used to generate the mappings. The part that they work against is usually discernible from their name, or their parameters. <code>GetTableName</code> for example works against an entity <code>Type</code>, while <code>GetVersionColumnName</code> is called against every <code>PropertyInfo</code> gleaned from your entities. <em>As there is no API documentation (as of writing), it&#8217;s a matter of intellisense poking to find which conventions are applicable to what you want to override.</em></p>
</blockquote>

<p>As you can see, our primary key&#8217;s now have our desired naming convention. Lets do the other two together, as they&#8217;re so simple; we&#8217;ll override the foreign key naming, and change the default length for strings.</p>

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

<p>That&#8217;s all there is to it, when combined with the other conventions you can customise the mappings quite heavily while only adding a few lines to your auto mapping.</p>

<p>This is our final schema:</p>

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

<p>Next time: how to apply your own type conventions that apply to all properties of a specific type in your domain, and how to utilise NHibernate&#8217;s <code>IUserType</code>s.</p>