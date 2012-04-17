---
layout: post
title: ! 'Fluent NHibernate: Auto mapping, overrides and alterations'
tags:
- AutoMapping
- Fluent NHibernate
- FluentNHibernate
- NHibernate
status: publish
type: post
published: true
meta:
  aktt_notify_twitter: 'no'
  _edit_last: '2'
  dsq_thread_id: '644651281'
---
> **Notice:** This is an excerpt from the <a href='https://github.com/jagregory/fluent-nhibernate/wiki/Auto-mapping'>Auto Mapping</a> wiki page. It is recommended you refer to those pages for the latest version of this content, as this blog post will not be maintained for correctness.

<p>When using the Auto Mapping facilities of <a href="http://www.fluentnhibernate.org">Fluent NHibernate</a> you can use the <code>ForMappingsThatDeriveFrom</code> method described in <a href='https://github.com/jagregory/fluent-nhibernate/wiki/Auto-mapping'>Altering Entities</a> to override the mappings for specific entities, but that can quickly become cluttered if you&#8217;re having to alter many entities.</p>

<p>An alternative is to use an <code>IAutoMappingOverride<T></code>, which is an interface you can implement to override the mappings of a particular auto-mapped class.</p>

``` csharp
public class PersonMappingOverride : IAutoMappingOverride<Person>
{
  public void Override(AutoMap<Person> mapping)
  {
  }
}
```

<p>This example overrides the auto-mapping of a <code>Person</code> entity. Within the <code>Override</code> method you can perform any actions on the mapping that you can in the <a href='https://github.com/jagregory/fluent-nhibernate/wiki/Fluent-mapping'>Fluent Mappings</a>.</p>

<p>To use overrides, you need to instruct your <code>AutoPersistenceModel</code> instance to use them. Typically this would be done in the context of a <a href='https://github.com/jagregory/fluent-nhibernate/wiki/Fluent-configuration'>Fluent Configuration</a> setup, but I&#8217;ll just illustrate with the <code>AutoPersistenceModel</code> on it&#8217;s own.</p>

``` csharp
AutoPersistenceModel.MapEntitiesFromAssemblyOf<Person>()
  .Where(type => type.Namespace == "Entities")
  .UseOverridesFromAssemblyOf<PersonMappingOverride>();
```

<p>It&#8217;s the <code>UserOverridesFromAssemblyOf<T></code> call that instructs the <code>AutoPersistenceModel</code> to read any overrides that reside the assembly that contains <code>T</code>.</p>

<p>These overrides are made possible with use of the configuration alteration capabilities of the <code>AutoPersistenceModel</code>. You can use these features yourself to create your own customisations, or simply to separate your configuration into logical sections.</p>

<p>An alteration is an implementation of the <code>IAutoMappingAlteration</code> interface, and is a self contained piece of configuration logic that can be applied with others to an <code>AutoPersistenceModel</code> prior to any mappings being generated. These are simple to use, but very powerful.</p>

``` csharp
public class WhereAlteration : IAutoMappingAlteration
{
  public void Alter(AutoPersistenceModel model)
  {
    model.Where(type => IsMappable(type));
  }

  private bool IsMappable(Type type)
  {
    // some logic
  }
}
```

<p>The <code>Alter(AutoPersistenceModel model)</code> method is where you place your logic for altering the model, you can do anything in here you like. The overrides functionality, for example, inspects an assembly looking for any <code>IMappingOverride<T></code> instances and executes each one against the model.</p>

<p>You need to instruct your <code>AutoPersistenceModel</code> to use any alterations you may have, and you do that using the <code>WithAlterations</code> method. Typically this would be done in the context of a FluentConfiguration setup, but I&#8217;ll just illustrate with the <code>AutoPersistenceModel</code> on it&#8217;s own.</p>

``` csharp
AutoPersistenceModel.MapEntitiesFromAssemblyOf<Person>()  
  .WithAlterations(alterations =>
    alterations.AddFromAssemblyOf<WhereAlteration>());
```

<p>The <code>WithAlterations</code> method takes a lambda action that allows you to set multiple alterations on your model; you can add single alterations with <code>Add</code>, and everything from an assembly like the above example.</p>

<p>Before your mappings are generated, the alterations are all run against the <code>AutoPersistenceModel</code>. There&#8217;s currently no ordering of alterations, so you cannot rely on the ability to stack alterations.</p>