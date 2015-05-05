---
layout: post
title: ! 'Fluent NHibernate: Configuring your application'
tags:
- Configuration
- Fluent NHibernate
- FluentNHibernate
- NHibernate
status: publish
type: post
published: true
meta:
  aktt_notify_twitter: 'no'
  _edit_last: '2'
  dsq_thread_id: '644650972'
---
> **Notice:** The content in this post may be out of date, please refer to the [Fluent Configuration](https://github.com/jagregory/fluent-nhibernate/wiki/Fluent-configuration) page in the [Fluent NHibernate Wiki](https://github.com/jagregory/fluent-nhibernate/wiki) for the latest version.

There's been a grey area of how to actually configure your application to use [Fluent NHibernate](http://www.fluentnhibernate.org), and also how to configure some more complicated situations (such as mixing fluent and non-fluent mappings). After some thought I've committed a change that should make things clearer. What follows is a few examples of how this new API can be used.

<!-- more -->

> I'm going to assume that you've got an application already set up, or you know how to structure a standard NHibernate application. If you don't, I suggest you read up on that first.

All the examples that follow are tailored to directly replace your `SessionFactory` instantiation code.

## Introducing the configuration API

You can now `Fluently.Configure` your application. The API is broken down into five main methods, three of which are required.

``` csharp
Fluently.Configure()
  .Database(/* your database settings */)
  .Mappings(/* your mappings */)
  .ExposeConfiguration(/* alter Configuration */) // optional
  .BuildSessionFactory();
```

You can combine these methods in various ways to setup your application.

  1. `Fluently.Configure` starts the configuration process
  2. `Database` is where you specify your database configuration
  3. `Mappings` is where you supply which mappings you're using
  4. `ExposeConfiguration` is optional, but allows you to alter the raw Configuration object
  5. `BuildSessionFactory` is the final call, and it creates the NHibernate SessionFactory instance from your configuration.

## Exclusively fluent

If you're in the situation where your application is exclusively using fluent mappings, then this is the configuration for you.

``` csharp
var sessionFactory = Fluently.Configure()
  .Database(SQLiteConfiguration.Standard.InMemory)
  .Mappings(m =>
    m.FluentMappings
      .AddFromAssemblyOf<YourEntity>())
  .BuildSessionFactory();
```

This setup uses the SQLite database configuration, but you can substitute that with your own; it then adds any fluent mappings from the assebly that contains `YourEntity`.

## Automappings

If you're using only auto mappings, then this config is for you.

``` csharp
var sessionFactory = Fluently.Configure()
  .Database(SQLiteConfiguration.Standard.InMemory)
  .Mappings(m =>
    m.AutoMappings.Add(
      // your automapping setup here
      AutoPersistenceModel.MapEntitiesFromAssemblyOf<YourEntity>()
        .Where(type => type.Namspace.EndsWith("Entities"))))
  .BuildSessionFactory();
```

Replace the code inside `AutoMappings.Add` with your auto mapping configuration. You can see more about auto mappings in my [automapping tag](http://blog.jagregory.com/tag/automapping/).

## Mixed fluent mappings and auto mappings

If you're using a combination of standard fluent mappings and auto mappings, then this example should show you how to get started.

``` csharp
var sessionFactory = Fluently.Configure()
  .Database(SQLiteConfiguration.Standard.InMemory)
  .Mappings(m =>
  {
    m.FluentMappings
      .AddFromAssemblyOf<YourEntity>();

    m.AutoMappings.Add(
      // your automapping setup here
      AutoPersistenceModel.MapEntitiesFromAssemblyOf<YourEntity>()
        .Where(type => type.Namspace.EndsWith("Entities")));
  })
  .BuildSessionFactory();
```

You can see that this is a combination of the two previous examples, the `Mappings` method can accept multiple kinds of mappings.

## HBM mappings

You've not yet got around to using Fluent NHibernate fully, but you are configuring your database with it; this configuration will let you configure your database and add your traditional hbm mappings.

``` csharp
var sessionFactory = Fluently.Configure()
  .Database(SQLiteConfiguration.Standard.InMemory)
  .Mappings(m =>
    m.HbmMappings
      .AddFromAssemblyOf<YourEntity>())
  .BuildSessionFactory();
```

The `HbmMappings` property allows you to add HBM XML mappings in a few different ways, this example adds everything from an assembly which defines `YourEntity`; however, you can add from an assembly instance, or just add single types.

## Mixed HBM and fluent mappings

You're migrating your entities to Fluent NHibernate but haven't quite got them all across yet - this is for you.

``` csharp
var sessionFactory = Fluently.Configure()
  .Database(SQLiteConfiguration.Standard.InMemory)
  .Mappings(m =>
  {
    m.HbmMappings
      .AddFromAssemblyOf<YourEntity>();

    m.FluentMappings
      .AddFromAssemblyOf<YourEntity>();
  })
  .BuildSessionFactory();
```

## The whole shebang: fluent, auto, and hbm mappings

You're a crazy fool and map a bit of everything, then this is how you'd configure it.

``` csharp
var sessionFactory = Fluently.Configure()
  .Database(SQLiteConfiguration.Standard.InMemory)
  .Mappings(m =>
  {
    m.HbmMappings
      .AddFromAssemblyOf<YourEntity>();

    m.FluentMappings
      .AddFromAssemblyOf<YourEntity>();

    m.AutoMappings.Add(
      // your automapping setup here
      AutoPersistenceModel.MapEntitiesFromAssemblyOf<YourEntity>()
        .Where(type => type.Namspace.EndsWith("Entities")));
  })
  .BuildSessionFactory();
```

### Exporting hbm.xml mappings

In the `Mappings` call, you can do the following:

``` csharp
.Mappings(m =>
{
  m.FluentMappings
    .AddFromAssemblyOf<YourEntity>()
    .ExportTo(@"C:\your\export\path");

  m.AutoMappings
    .Add(...)
    .ExportTo(@"C:\your\export\path");
})
```

That will export all of your fluent and automapped mappings in hbm.xml format to whatever location you specify.

### Altering non-automapped conventions

If you want to override conventions that are used by your non-automapped classes, then you can use the `AlterConventions` method on `FluentMappings`.

``` csharp
.Mappings(m =>
  m.FluentMappings
    .AddFromAssemblyOf<YourEntity>()
    .AlterConventions(conventions =>
    {
      conventions.IsBaseType =
        type => type == typeof(BaseType);
    }))
```

### Validation

If you forget to setup your database, or don't add any mappings, instead of pulling out your hair over obscure NHibernate exceptions, the `BuildSessionFactory` method will throw a more helpful exception to try to point you in the right direction. It'll tell you whether you've forgot to add any entities, or not setup your database.

That's it for now, I hope this helps to make configuring your application a little clearer.
