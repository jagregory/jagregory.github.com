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
<p>Carrying on with the <a href='http://www.fluentnhibernate.org'>Fluent NHibernate</a> Auto Mapping theme, I&#8217;ll now demonstrate how to map inheritance hierarchies.</p>

<p>There are two main things that you&#8217;d want to do with inherited classes, either ignore the base class all together, or map them using an inheritance strategy. I&#8217;m going to start with the former, then move on to the latter.</p>

<h2 id='ignoring_basetypes'>Ignoring base-types</h2>

<p>This scenario is where you may have a base class in your domain that you use to simplify your entities, you&#8217;ve moved common properties into it so you don&#8217;t have to recreate them on every entity; typically this would be the Id and perhaps some audit information. So lets start with a model that has a base class we&#8217;d like to ignore.</p>

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

<p>Relatively simple model here, we&#8217;ve got an <code>Entity</code> base class that defines the <code>Id</code>, then the <code>Person</code> and <code>Animal</code> entities. We have no desire to have <code>Entity</code> mapped by NHibernate, so we need a way to tell the auto mapper to ignore it.</p>

<p>For those individuals from traditional XML mapping land, this is what we&#8217;re going to be recreating:</p>

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

<p>We need to initialise the NHibernate configuration, and supply it with any auto mappings we&#8217;re going to create:</p>

``` csharp
var autoMappings = AutoPersistenceModel  
  .MapEntitiesFromAssemblyOf<Entity>()  
  .Where(t => t.Namespace == "Entities");  

var sessionFactory = new Configuration()  
  .AddProperty(ConnectionString, ApplicationConnectionString)  
  .AddAutoMappings(autoMappings)  
  .BuildSessionFactory();
```

<p>The first section is the configuration of Fluent NHibernate, which we&#8217;re telling to map anything in the <code>Entities</code> namespace from the assembly that contains our <code>Entity</code> base-class; then we configure NHibernate and inject our auto mappings.</p>

<p>If we were to run this now, we wouldn&#8217;t get the mapping we desire. Fluent NHibernate would see <code>Entity</code> as an actual entity and map it with <code>Animal</code> and <code>Person</code> as subclasses; this is not what we desire, so we need to modify our auto mapping configuration to reflect that.</p>

<p>After <code>MapEntitiesFromAssemblyOf<Entity>()</code> we need to alter the conventions that the auto mapper is using so it can identify our base-class.</p>

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

<p>We&#8217;ve added the <code>WithConventions</code> call in which we replace the <code>IsBaseType</code> convention with our own. This convention is used to identify whether a type is simply a base-type for abstraction purposes, or a legitimate storage requirement. In our case we&#8217;ve set it to return <code>true</code> if the type is an <code>Entity</code>.</p>

<p>With this change, we now get our desired mapping. <code>Entity</code> is ignored as far is Fluent NHibernate is concerned, and all the properties (<code>Id</code> in our case) are treated as if they were on the specific subclasses.</p>

<h2 id='basetype_as_an_inheritance_strategy'>Base-type as an inheritance strategy</h2>

<p>What we&#8217;re going to do is create a simple model that we&#8217;ll map as a <a href='http://www.hibernate.org/hib_docs/nhibernate/html/inheritance.html'>table-per-subclass</a> inheritance strategy, which is the equivalent of the NHibernate <code>joined-subclass</code> mapping.</p>

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

<p>Relatively simple model here, we&#8217;ve got an <code>Person</code> class that defines the <code>Id</code> and name properties, then the <code>Employee</code> and <code>Guest</code> subclass entities.</p>

<p>The XML equivalent is as follows:</p>

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

<p>Again we configure NHibernate session factory to integrate with the auto mapping:</p>

``` csharp
var autoMappings = AutoPersistenceModel  
  .MapEntitiesFromAssemblyOf<Person>()  
  .Where(t => t.Namespace == "Entities");  

var sessionFactory = new Configuration()  
  .AddProperty(ConnectionString, ApplicationConnectionString)  
  .AddAutoMappings(autoMappings)  
  .BuildSessionFactory();
```

<p>This is the same configuration that I used in the first example, except that if you recall the reason we had to change the last example was because it was mapping it as a joined-subclass - that&#8217;s right, we don&#8217;t need to do anything now! Our mapping is complete, Fluent NHibernate automatically assumes that any inherited classes (that haven&#8217;t had their base-type excluded by the <code>IsBaseType</code> convention) should be mapped as joined-subclasses.</p>

<p>That&#8217;s how to deal with base-classes with Fluent NHibernate&#8217;s auto mapping.</p>