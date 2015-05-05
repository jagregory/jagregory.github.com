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
> **Notice:** The content in this post may be out of date, please refer to the [Auto Mapping](https://github.com/jagregory/fluent-nhibernate/wiki/Auto-mapping) page in the [Fluent NHibernate Wiki](https://github.com/jagregory/fluent-nhibernate/wiki) for the latest version.

I've just committed a change that should allow automatic mapping of simple components; by simple, I mean components that just map properties, nothing fancy. I'll be looking to expand this functionality in the future, but for the time being any kind of relationships aren't supported within components. With that in mind, I'll walk through how to automap your components.

<!-- more -->

Lets imagine this database structure:

``` sql
table Person (
  Id int primary key,
  Name varchar(200),
  Address_Number int,
  Address_Street varchar(100),
  Address_PostCode varchar(8)
)
```

We want to map that to the following model:

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

With this design, `Address` is actually a component, which isn't a full entity, more of a way of providing a clean model to a normalised database structure. I'll get started by setting up the auto-mapper.

``` csharp
var autoMappings = AutoPersistenceModel
  .MapEntitiesFromAssemblyOf<Person>()
  .Where(type = type.Namespace.EndsWith("Domain"));

var sessionFactory = new Configuration()  
  .AddProperty(ConnectionString, ApplicationConnectionString)  
  .AddAutoMappings(autoMappings)  
  .BuildSessionFactory();
```

That's our auto mappings integrated with NHibernate. Next we need to instruct the auto mapper in how to identify components; after the `Where` call, we can add a call to `WithConvention` which is where we'll give it a hand.

``` csharp
.WithConvention(convention =>
{
  convention.IsComponentType =
    type => type.Namespace.EndsWith("Domain.Components");
})
```

The `IsComponentType` convention is what Fluent NHibernate uses to determine whether a type is one that will be mapped as a component, rather than a full entity.

There are two things you need to know about this convention:

  1. You can only set this convention once, so you'll need to use it in a way that allows you to identify multiple component types with it; there are several options to this, including using the namespace (the above example), or checking a suffix on the type name (anything that ends in "Component", for example).
  2. This is not an exclusive call, so you need to segregate your component types from your standard entity types (so they'll be excluded by the `Where` call), otherwise they'll be auto-mapped as full entities as well as components - *not good*. I've done that in this example by separating components into their own namespace.

With that, the `Address` should now be automatically mapped as a component; the auto mapper will pick up the three properties and map them as properties on the component.

There's one more thing, for illustrative purposes I've deliberately gone against Fluent NHibernate's inbuilt convention for naming columns. By default any columns mapped in a convention will be prefixed with their property name, so `person.HomeAddress.Street` would be mapped against a column called `HomeAddressStreet`; this is my personal preference, but not what our database contains! We can control how our columns are named by altering the `GetComponentColumnPrefix` convention, like so:

``` csharp
.WithConvention(convention =>
{
  convention.IsComponentType =
    type => type == typeof(Address);
  convention.GetComponentColumnPrefix =
    property => property.Name + "_";
})
```

The convention now specifies that columns should be named ComponentPropertyName_PropertyName, so `person.Address.Street` is now correctly mapped against `Address_Street`.

Magic.

## Update

I've updated this post to reflect some recent changes whereby the `GetComponentColumnPrefix` convention was updated to use the component property instead of the component type. This is to allow for multiple component properties on an entity that are of the same type. If you still need to use the type you can access it through the `PropertyInfo` parameter.
