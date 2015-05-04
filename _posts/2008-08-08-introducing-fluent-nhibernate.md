---
layout: post
title: Introducing Fluent NHibernate
tags:
- .Net
- Code
- DotNet
- FluentInterface
- Hobby Projects
- NHibernate
- OpenSource
status: publish
type: post
published: true
meta:
  _edit_last: '2'
  aktt_tweeted: '1'
  dsq_thread_id: '644650474'
---
> A couple of people have already covered this already, specifically <a href="http://www.IAmNotMyself.com/2008/08/07/SkinningTheCatWithFluentNHibernate.aspx">Bobby Johnson</a>, <a href="http://mhinze.com/fluent-nhibernate-project/">Matt Hinze</a>, and <a href="http://zachariahyoung.com/zy/post/2008/08/fluent-nhibernate-for-creating-entity-mapping-files.aspx">Zachariah Young</a>. I figure I should say something on it anyway.

I've adopted a project from [Jeremy Miller](http://codebetter.com/blogs/jeremy.miller/) that I think has the potential to be a really useful tool. It's called [Fluent NHibernate](http://www.fluentnhibernate.org), and it's primarily a fluent API for mapping classes with NHibernate.

We're all well aware how awesome NHibernate is, but I think we all also have a bit of a dislike for the amount of XML you need to write to get your classes mapped; not only that, but also how the mappings are distinctly separate from the rest of your application. They're often neglected and untested. One of the core tenets of the project is that we need a more succinct, readable, and testable way of writing your mappings.

## The API

Take the following simple hbm file:

``` xml
<?xml version="1.0" encoding="utf-8" ?>
<hibernate-mapping xmlns="urn:nhibernate-mapping-2.2" namespace="Eg" assembly="Eg">
  <class name="Customer" table="Customers">
    <id name="ID">
      <generator class="identity" />
    </id>

    <property name="Name" />
    <property name="Credit" />

    <bag name="Products" table="Products">
      <key column="CustomerID"/>
      <one-to-many class="Eg.Product, Eg"/>
    </bag>

    <component name="Address" class="Eg.Address, Eg">
      <property name="AddressLine1" />
      <property name="AddressLine2" />
      <property name="CityName" />
      <property name="CountryName" />
    </component>
  </class>
</hibernate-mapping>
```

Then compare it to the same mapping, created using the fluent API:

``` csharp
public CustomerMap : ClassMap<Customer>
{
  public CustomerMap()
  {
    Id(x => x.ID);
    Map(x => x.Name);
    Map(x => x.Credit);
    HasMany<Product>(x => x.Products)
      .AsBag();
    Component<Address>(x => x.Address, m =>
    {  
        m.Map(x => x.AddressLine1);  
        m.Map(x => x.AddressLine2);  
        m.Map(x => x.CityName);  
        m.Map(x => x.CountryName);  
    });
  }
}
```

Firstly, you'll note that there is a marginal reduction in lines of code, but that's not what we're particularly striving for. Instead we're intent on reducing the verbosity and <strong>noise</strong> of the code. This manifests itself in a <a href="http://en.wikipedia.org/wiki/Convention_over_Configuration">convention over configuration</a> design for the API, where we choose the most common setups and use those as the default. For example with the <code>id</code> element in the hbm file, you're required to specify what the generator type is; however, in our fluent API we check the type of your identity property and decide what generator we should use. Int's and longs default to identity, while GUIDs use the guid.comb generator. You can change these explicitly, but when you are using the default, it greatly reduces the verbosity of your mapping.

## Testability

Another one of our goals is to make your mappings more robust. I imagine most people have had the problem where you've renamed a property and not updated the mapping file; due to there being no compile time validation, the only way to catch these mistakes are at run time (hopefully you had tests to cover that!). With the way our API is designed, you use the actual properties on your classes to create the mapping, so there's nothing to forget. If you rename a property, your IDE will either rename the property in the mapping, or fail at compilation.

We also want to help you verify that your mappings are set up properly, not just syntactically valid. So to make your 	integration tests a bit easier, we're providing an API for testing your mappings.
	
``` csharp
[Test]
public void VerifyCustomerSaves()
{
    new PersistenceSpecification<Customer>()
        .CheckProperty(x => x.Name, "James Gregory")
        .CheckProperty(x => x.Age, 22)
        .VerifyTheMappings();
}
```

Behind the scenes the <code>PersistenceSpecification</code> creates an instance of your entity, then populates it with the values you specify through the <code>CheckProperty</code> method. This entity is then saved to the database, then reloaded through a separate connection. The returned entity is then compared to the one originally saved, and any differences fail the test. It's a fairly standard integration test, except we've taken the time to write all the wiring up that needs to be done, so you don't have to.

## The Framework

We're working towards our first official release, which will have a fairly solid implementation of the API. Once that's out in the wild, we're going to focus on our Framework.
	
Our framework is a layer that sits on-top of the API to provide an even better experience. We're looking to integrate with your favorite container, which will reduce the code you need to write to integrate NHibernate into your system. Then we're going to tackle extensible conventions, which will allow you to specify your own implied conventions for your application. For example, if you're <strong>always</strong> going to call your identifier "ID", then why should you have to specify it every time? <em>You shouldn't!</em>

Development is progressing at a nice pace, and I expect we'll be able to get our first release out within the next few weeks. The testing API hasn't been kept quite as up to date as the main API, but we're working on that too. It's open-source, so suggestions and patches are welcome.