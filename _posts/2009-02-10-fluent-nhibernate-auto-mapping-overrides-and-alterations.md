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
> **Notice:** This is an excerpt from the [Auto Mapping](https://github.com/jagregory/fluent-nhibernate/wiki/Auto-mapping) wiki page. It is recommended you refer to those pages for the latest version of this content, as this blog post will not be maintained for correctness.

When using the Auto Mapping facilities of [Fluent NHibernate](http://www.fluentnhibernate.org) you can use the `ForMappingsThatDeriveFrom` method described in [Altering Entities](https://github.com/jagregory/fluent-nhibernate/wiki/Auto-mapping) to override the mappings for specific entities, but that can quickly become cluttered if you're having to alter many entities.

<!-- more -->

An alternative is to use an `IAutoMappingOverride<T>`, which is an interface you can implement to override the mappings of a particular auto-mapped class.

``` csharp
public class PersonMappingOverride : IAutoMappingOverride<Person>
{
  public void Override(AutoMap<Person> mapping)
  {
  }
}
```

This example overrides the auto-mapping of a `Person` entity. Within the `Override` method you can perform any actions on the mapping that you can in the [Fluent Mappings](https://github.com/jagregory/fluent-nhibernate/wiki/Fluent-mapping).

To use overrides, you need to instruct your `AutoPersistenceModel` instance to use them. Typically this would be done in the context of a [Fluent Configuration](https://github.com/jagregory/fluent-nhibernate/wiki/Fluent-configuration) setup, but I'll just illustrate with the `AutoPersistenceModel` on it's own.

``` csharp
AutoPersistenceModel.MapEntitiesFromAssemblyOf<Person>()
  .Where(type => type.Namespace == "Entities")
  .UseOverridesFromAssemblyOf<PersonMappingOverride>();
```

It's the `UserOverridesFromAssemblyOf<T>` call that instructs the `AutoPersistenceModel` to read any overrides that reside the assembly that contains `T`.

These overrides are made possible with use of the configuration alteration capabilities of the `AutoPersistenceModel`. You can use these features yourself to create your own customisations, or simply to separate your configuration into logical sections.

An alteration is an implementation of the `IAutoMappingAlteration` interface, and is a self contained piece of configuration logic that can be applied with others to an `AutoPersistenceModel` prior to any mappings being generated. These are simple to use, but very powerful.

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

The `Alter(AutoPersistenceModel model)` method is where you place your logic for altering the model, you can do anything in here you like. The overrides functionality, for example, inspects an assembly looking for any `IMappingOverride<T>` instances and executes each one against the model.

You need to instruct your `AutoPersistenceModel` to use any alterations you may have, and you do that using the `WithAlterations` method. Typically this would be done in the context of a FluentConfiguration setup, but I'll just illustrate with the `AutoPersistenceModel` on it's own.

``` csharp
AutoPersistenceModel.MapEntitiesFromAssemblyOf<Person>()  
  .WithAlterations(alterations =>
    alterations.AddFromAssemblyOf<WhereAlteration>());
```

The `WithAlterations` method takes a lambda action that allows you to set multiple alterations on your model; you can add single alterations with `Add`, and everything from an assembly like the above example.

Before your mappings are generated, the alterations are all run against the `AutoPersistenceModel`. There's currently no ordering of alterations, so you cannot rely on the ability to stack alterations.
