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
> **Notice:** The content in this post may be out of date, please refer to the <a href="https://github.com/jagregory/fluent-nhibernate/wiki/Auto-mapping">Auto Mapping</a> page in the <a href="https://github.com/jagregory/fluent-nhibernate/wiki">Fluent NHibernate Wiki</a> for the latest version.

<p>I&#8217;ve already covered how to auto map a basic domain, as well as how to customise some of the conventions that the auto mapper uses. There are some more in-depth customisations you can do to the conventions that I&#8217;ll cover now.</p>

<p>We&#8217;re going to use the same domain as before, but with a few extensions.</p>

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

<p>We&#8217;ve extended our domain with a <code>Description</code> and a <code>ReplenishmentDay</code> for the <code>Product</code>; the replenishment day is represented by a type-safe enum (using the <a href='http://www.javacamp.org/designPattern/enum.html'>type-safe enum pattern</a>). Also there&#8217;s a <code>Description</code> against the <code>Shelf</code> too (not sure why you&#8217;d have a description of a shelf, but hey, that&#8217;s customers for you). These changes are mapped against the following schema:</p>

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

<p>Now, if you&#8217;ve been following along you&#8217;ll remember that we made all strings default to 250; and yet the new description columns are 2000 characters long. The customer has stipulated that all descriptions of anything in the domain will always be 2000 or less characters, so lets map that without affecting our other rule for strings.</p>

``` csharp
autoMappings
  .WithConvention(convention =>
  {
    convention.AddTypeConvention(new DescriptionTypeConvention());
    convention.DefaultStringLength = 250;

    // other conventions
  });
```

<p>We&#8217;re using the Fluent NHibernate&#8217;s <code>ITypeConvention</code> support now, which allows you to override the mapping of properties that have a specific type. The <code>AddTypeConvention</code> method takes a <code>ITypeConvention</code> instance and applies that to every property that gets mapped. Baring in mind that our convention in this case is for a <code>string</code> property, and only for ones that are called &#8220;Description&#8221;, lets see how the <code>DescriptionTypeConvention</code> is declared.</p>

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

<p>It&#8217;s fairly expressive of what it does, but I&#8217;ll cover it for completeness. The <code>ITypeConvention</code> specifies two methods: <code>bool CanHandle(Type)</code> and <code>void AlterMap(IProperty)</code>. <code>CanHandle</code> should be implemented to return <code>true</code> for types that you want this convention to deal with; this can be handled in any way you want, you could check the name, or it&#8217;s ancestry, but in our case we just check whether it&#8217;s a string. <code>AlterMap</code> is where the bulk of the work happens; this method gets called for every property mapping that has a type that <code>CanHandle</code> returns <code>true</code> for. We&#8217;ve implemented <code>AlterMap</code> to firstly check if the property is called &#8220;Description&#8221; (if it isn&#8217;t, we do nothing) and then alter the length of the property. Simple really.</p>

<p>With a simple implementation like this, we&#8217;re able to map every Description property (that&#8217;s a <code>string</code>) so that it has a length of 2000, all with an addition of only one line to our auto mapping configuration.</p>

<h2 id='iusertype_support'>IUserType support</h2>

<p>The other alteration to our domain was the addition of the <code>ReplenishmentDay</code>. There were two interesting things to consider for this change. Firstly, it&#8217;s stored in an <code>int</code> column, which obviously doesn&#8217;t match our type; and secondly the column is called <code>RepOn</code>, which we mustn&#8217;t change. We&#8217;re going to utilise NHibernate&#8217;s <code>IUserType</code> to handle this column.</p>

<blockquote>
<p>For the sake of this example we&#8217;re going to assume you&#8217;ve got an <code>IUserType</code> called <code>ReplenishmentDayUserType</code>, but as it&#8217;s beyond the scope of this post I won&#8217;t actually show the implementation as it can be quite lengthy. It&#8217;s best to just assume that the <code>IUserType</code> reads an <code>int</code> from the database and can convert it to a <code>ReplenishmentDay</code> instance. There&#8217;s a <a href='http://intellect.dk/post/Implementing-custom-types-in-nHibernate.aspx'>nice example of implementing <code>IUserType</code></a> on <a href='http://intellect.dk'>Jakob Andersen</a>&#8217;s blog.</p>
</blockquote>

<p>So how do we tell Fluent NHibernate to use an <code>IUserType</code> instead of the specified type? Easy, with another <code>ITypeConvention</code>.</p>

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

<p>Here&#8217;s how our new <code>ReplenishmentDayTypeConvention</code> looks:</p>

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

<p>As you can see, we handle any <code>ReplenishmentDay</code> types, and then supply a <code>IUserType</code> using the <code>CustomTypeIs<T>()</code> method, and override the column name with <code>TheColumnNameIs(string)</code>. Again, easy!</p>

<p>So that&#8217;s it, with those conventions we&#8217;re able to keep our standard rule that all strings should be 250 characters or less, unless they&#8217;re a Description, then they can be 2000 or less. Replenishment days use our type-safe enum, but are persisted to an <code>int</code> in the database, which also has a custom column name.</p>

<p>Next time: How to override conventions on an entity-by-entity basis.</p>