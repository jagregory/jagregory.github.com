---
layout: post
title: ! 'Fluent NHibernate: Auto mapping and base-classes'
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
  dsq_thread_id: '644651294'
---
Carrying on with the [Fluent NHibernate](http://www.fluentnhibernate.org) Auto Mapping theme, I'll now demonstrate how to map inheritance hierarchies.

There are two main things that you'd want to do with inherited classes, either ignore the base class all together, or map them using an inheritance strategy. I'm going to start with the former, then move on to the latter.

<!-- more -->

## Ignoring base-types

This scenario is where you may have a base class in your domain that you use to simplify your entities, you've moved common properties into it so you don't have to recreate them on every entity; typically this would be the Id and perhaps some audit information. So lets start with a model that has a base class we'd like to ignore.

``` csharp
namespace Entities
{
  public abstract class Entity
  {
    public virtual int Id { get; set; }
  }

  public class Person : Entity
  {
    public virtual string FirstName { get; set; }
    public virtual string LastName { get; set; }
  }

  public class Animal : Entity
  {
    public virtual string Species { get; set; }
  }
}
```

Relatively simple model here, we've got an `Entity` base class that defines the `Id`, then the `Person` and `Animal` entities. We have no desire to have `Entity` mapped by NHibernate, so we need a way to tell the auto mapper to ignore it.

For those individuals from traditional XML mapping land, this is what we're going to be recreating:

``` xml
<class name="Person">
  <id name="Id" type="Int32">
    <generator class="identity" />
  </id>

  <property name="FirstName" />
  <property name="LastName" />
</class>

<class name="Animal">
  <id name="Id" type="Int32">
    <generator class="identity" />
  </id>

  <property name="Species" />
</class>
```

We need to initialise the NHibernate configuration, and supply it with any auto mappings we're going to create:

``` csharp
var autoMappings = AutoPersistenceModel  
  .MapEntitiesFromAssemblyOf<Entity>()  
  .Where(t => t.Namespace == "Entities");  

var sessionFactory = new Configuration()  
  .AddProperty(ConnectionString, ApplicationConnectionString)  
  .AddAutoMappings(autoMappings)  
  .BuildSessionFactory();
```

The first section is the configuration of Fluent NHibernate, which we're telling to map anything in the `Entities` namespace from the assembly that contains our `Entity` base-class; then we configure NHibernate and inject our auto mappings.

If we were to run this now, we wouldn't get the mapping we desire. Fluent NHibernate would see `Entity` as an actual entity and map it with `Animal` and `Person` as subclasses; this is not what we desire, so we need to modify our auto mapping configuration to reflect that.

After `MapEntitiesFromAssemblyOf<Entity>()` we need to alter the conventions that the auto mapper is using so it can identify our base-class.

``` csharp
var autoMappings = AutoPersistenceModel  
  .MapEntitiesFromAssemblyOf<Entity>()
  .WithConventions(convention =>
  {
    convention.IsBaseType =
      type => type == typeof(Entity);
  })
  .Where(t => t.Namespace == "Entities");
```

We've added the `WithConventions` call in which we replace the `IsBaseType` convention with our own. This convention is used to identify whether a type is simply a base-type for abstraction purposes, or a legitimate storage requirement. In our case we've set it to return `true` if the type is an `Entity`.

With this change, we now get our desired mapping. `Entity` is ignored as far is Fluent NHibernate is concerned, and all the properties (`Id` in our case) are treated as if they were on the specific subclasses.

<h2 id='basetype_as_an_inheritance_strategy'>Base-type as an inheritance strategy</h2>

What we're going to do is create a simple model that we'll map as a [table-per-subclass](http://www.hibernate.org/hib_docs/nhibernate/html/inheritance.html) inheritance strategy, which is the equivalent of the NHibernate `joined-subclass` mapping.

``` csharp
namespace Entities
{
  public class Person
  {
    public virtual int Id { get; set; }
    public virtual string FirstName { get; set; }
    public virtual string LastName { get; set; }
  }

  public class Employee : Person
  {
    public virtual DateTime StartDate { get; set; }
  }

  public class Guest : Person
  {
    public virtual int GuestPassId { get; set; }
  }
}
```

Relatively simple model here, we've got an `Person` class that defines the `Id` and name properties, then the `Employee` and `Guest` subclass entities.

The XML equivalent is as follows:

``` xml
<class name="Person">
  <id name="Id" type="Int32">
    <generator class="identity" />
  </id>

  <property name="FirstName" />
  <property name="LastName" />

  <joined-subclass name="Employee">
    <key column="PersonId" />
    <property name="StartDate" />
  </joined-subclass>

  <joined-subclass name="Guest">
    <key column="PersonId" />
    <property name="GuestPassId" />
  </joined-subclass>
</class>
```

Again we configure NHibernate session factory to integrate with the auto mapping:

``` csharp
var autoMappings = AutoPersistenceModel  
  .MapEntitiesFromAssemblyOf<Person>()  
  .Where(t => t.Namespace == "Entities");  

var sessionFactory = new Configuration()  
  .AddProperty(ConnectionString, ApplicationConnectionString)  
  .AddAutoMappings(autoMappings)  
  .BuildSessionFactory();
```

This is the same configuration that I used in the first example, except that if you recall the reason we had to change the last example was because it was mapping it as a joined-subclass - that's right, we don't need to do anything now! Our mapping is complete, Fluent NHibernate automatically assumes that any inherited classes (that haven't had their base-type excluded by the `IsBaseType` convention) should be mapped as joined-subclasses.

That's how to deal with base-classes with Fluent NHibernate's auto mapping.
