---
layout: post
title: ! 'Fluent NHibernate: Auto Mapping Components'
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
  dsq_thread_id: '644565858'
---
> **Notice:** The content in this post may be out of date, please refer to the <a href="https://github.com/jagregory/fluent-nhibernate/wiki/Auto-mapping">Auto Mapping</a> page in the <a href="https://github.com/jagregory/fluent-nhibernate/wiki">Fluent NHibernate Wiki</a> for the latest version.</p>

<p>I&#8217;ve just committed a change that should allow automatic mapping of simple components; by simple, I mean components that just map properties, nothing fancy. I&#8217;ll be looking to expand this functionality in the future, but for the time being any kind of relationships aren&#8217;t supported within components. With that in mind, I&#8217;ll walk through how to automap your components.</p>

<p>Lets imagine this database structure:</p>

``` sql
table Person (
  Id int primary key,
  Name varchar(200),
  Address_Number int,
  Address_Street varchar(100),
  Address_PostCode varchar(8)
)
```

<p>We want to map that to the following model:</p>

``` csharp
namespace Domain
{
  public class Person
  {
    public virtual int Id { get; set; }
    public virtual string Name { get; set; }
    public virtual Address Address { get; set; }
  }
}

namespace Domain.Components
{
  public class Address
  {
    public int Number { get; set; }
    public string Street { get; set; }
    public string PostCode { get; set; }
  }
}
```

<p>With this design, <code>Address</code> is actually a component, which isn&#8217;t a full entity, more of a way of providing a clean model to a normalised database structure. I&#8217;ll get started by setting up the auto-mapper.</p>

``` csharp
var autoMappings = AutoPersistenceModel
  .MapEntitiesFromAssemblyOf<Person>()
  .Where(type = type.Namespace.EndsWith("Domain"));

var sessionFactory = new Configuration()  
  .AddProperty(ConnectionString, ApplicationConnectionString)  
  .AddAutoMappings(autoMappings)  
  .BuildSessionFactory();
```

<p>That's our auto mappings integrated with NHibernate. Next we need to instruct the auto mapper in how to identify components; after the <code>Where</code> call, we can add a call to <code>WithConvention</code> which is where we'll give it a hand.</p>

``` csharp
.WithConvention(convention =>
{
  convention.IsComponentType =
    type => type.Namespace.EndsWith("Domain.Components");
})
```

<p>The <code>IsComponentType</code> convention is what Fluent NHibernate uses to determine whether a type is one that will be mapped as a component, rather than a full entity.</p>

<p>There are two things you need to know about this convention:</p>

<ol>
<li>You can only set this convention once, so you&#8217;ll need to use it in a way that allows you to identify multiple component types with it; there are several options to this, including using the namespace (the above example), or checking a suffix on the type name (anything that ends in &#8220;Component&#8221;, for example).</li>

<li>This is not an exclusive call, so you need to segregate your component types from your standard entity types (so they&#8217;ll be excluded by the <code>Where</code> call), otherwise they&#8217;ll be auto-mapped as full entities as well as components - <em>not good</em>. I've done that in this example by separating components into their own namespace.</li>
</ol>

<p>With that, the <code>Address</code> should now be automatically mapped as a component; the auto mapper will pick up the three properties and map them as properties on the component.</p>

<p>There&#8217;s one more thing, for illustrative purposes I&#8217;ve deliberately gone against Fluent NHibernate&#8217;s inbuilt convention for naming columns. By default any columns mapped in a convention will be prefixed with their property name, so <code>person.HomeAddress.Street</code> would be mapped against a column called <code>HomeAddressStreet</code>; this is my personal preference, but not what our database contains! We can control how our columns are named by altering the <code>GetComponentColumnPrefix</code> convention, like so:</p>

``` csharp
.WithConvention(convention =>
{
  convention.IsComponentType =
    type => type == typeof(Address);
  convention.GetComponentColumnPrefix =
    property => property.Name + "_";
})
```

<p>The convention now specifies that columns should be named ComponentPropertyName_PropertyName, so <code>person.Address.Street</code> is now correctly mapped against <code>Address_Street</code>.</p>

<p>Magic.</p>

<h4>Update:</h4>
<p>I've updated this post to reflect some recent changes whereby the <code>GetComponentColumnPrefix</code> convention was updated to use the component property instead of the component type. This is to allow for multiple component properties on an entity that are of the same type. If you still need to use the type you can access it through the <code>PropertyInfo</code> parameter.</p>
