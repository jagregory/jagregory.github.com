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
> **Notice:** The content in this post may be out of date, please refer to the <a href="https://github.com/jagregory/fluent-nhibernate/wiki/Fluent-configuration">Fluent Configuration</a> page in the <a href="https://github.com/jagregory/fluent-nhibernate/wiki">Fluent NHibernate Wiki</a> for the latest version.

<p>There&#8217;s been a grey area of how to actually configure your application to use <a href='http://www.fluentnhibernate.org'>Fluent NHibernate</a>, and also how to configure some more complicated situations (such as mixing fluent and non-fluent mappings). After some thought I&#8217;ve committed a change that should make things clearer. What follows is a few examples of how this new API can be used.</p>

<blockquote>
<p>I&#8217;m going to assume that you&#8217;ve got an application already set up, or you know how to structure a standard NHibernate application. If you don&#8217;t, I suggest you read up on that first.</p>
</blockquote>

<p>All the examples that follow are tailored to directly replace your <code>SessionFactory</code> instantiation code.</p>

<h2 id='introducing_the_configuration_api'>Introducing the configuration API</h2>

<p>You can now <code>Fluently.Configure</code> your application. The API is broken down into five main methods, three of which are required.</p>

``` csharp
Fluently.Configure()
  .Database(/* your database settings */)
  .Mappings(/* your mappings */)
  .ExposeConfiguration(/* alter Configuration */) // optional
  .BuildSessionFactory();
```

<p>You can combine these methods in various ways to setup your application.</p>

<ol><li><code>Fluently.Configure</code> starts the configuration process</li><li><code>Database</code> is where you specify your database configuration</li><li><code>Mappings</code> is where you supply which mappings you&#8217;re using</li><li><code>ExposeConfiguration</code> is optional, but allows you to alter the raw Configuration object</li><li><code>BuildSessionFactory</code> is the final call, and it creates the NHibernate SessionFactory instance from your configuration.</li></ol>

<h2 id='exclusively_fluent'>Exclusively fluent</h2>

<p>If you&#8217;re in the situation where your application is exclusively using fluent mappings, then this is the configuration for you.</p>

``` csharp
var sessionFactory = Fluently.Configure()
  .Database(SQLiteConfiguration.Standard.InMemory)
  .Mappings(m =>
    m.FluentMappings
      .AddFromAssemblyOf<YourEntity>())
  .BuildSessionFactory();
```

<p>This setup uses the SQLite database configuration, but you can substitute that with your own; it then adds any fluent mappings from the assebly that contains <code>YourEntity</code>.</p>

<h2 id='automappings'>Automappings</h2>

<p>If you&#8217;re using only auto mappings, then this config is for you.</p>

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

<p>Replace the code inside <code>AutoMappings.Add</code> with your auto mapping configuration. You can see more about auto mappings in my <a href='http://blog.jagregory.com/tag/automapping/'>automapping tag</a>.</p>

<h2 id='mixed_fluent_mappings_and_auto_mappings'>Mixed fluent mappings and auto mappings</h2>

<p>If you&#8217;re using a combination of standard fluent mappings and auto mappings, then this example should show you how to get started.</p>

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

<p>You can see that this is a combination of the two previous examples, the <code>Mappings</code> method can accept multiple kinds of mappings.</p>

<h2 id='hbm_mappings'>HBM mappings</h2>

<p>You&#8217;ve not yet got around to using Fluent NHibernate fully, but you are configuring your database with it; this configuration will let you configure your database and add your traditional hbm mappings.</p>

``` csharp
var sessionFactory = Fluently.Configure()
  .Database(SQLiteConfiguration.Standard.InMemory)
  .Mappings(m =>
    m.HbmMappings
      .AddFromAssemblyOf<YourEntity>())
  .BuildSessionFactory();
```

<p>The <code>HbmMappings</code> property allows you to add HBM XML mappings in a few different ways, this example adds everything from an assembly which defines <code>YourEntity</code>; however, you can add from an assembly instance, or just add single types.</p>

<h2 id='mixed_hbm_and_fluent_mappings'>Mixed HBM and fluent mappings</h2>

<p>You&#8217;re migrating your entities to Fluent NHibernate but haven&#8217;t quite got them all across yet - this is for you.</p>

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

<h2 id='the_whole_shebang_fluent_auto_and_hbm_mappings'>The whole shebang: fluent, auto, and hbm mappings</h2>

<p>You&#8217;re a crazy fool and map a bit of everything, then this is how you&#8217;d configure it.</p>

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

<h3 id='exporting_hbmxml_mappings'>Exporting hbm.xml mappings</h3>

<p>In the <code>Mappings</code> call, you can do the following:</p>

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

<p>That will export all of your fluent and automapped mappings in hbm.xml format to whatever location you specify.</p>

<h3 id='altering_nonautomapped_conventions'>Altering non-automapped conventions</h3>

<p>If you want to override conventions that are used by your non-automapped classes, then you can use the <code>AlterConventions</code> method on <code>FluentMappings</code>.</p>

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

<h3 id='validation'>Validation</h3>

<p>If you forget to setup your database, or don&#8217;t add any mappings, instead of pulling out your hair over obscure NHibernate exceptions, the <code>BuildSessionFactory</code> method will throw a more helpful exception to try to point you in the right direction. It&#8217;ll tell you whether you&#8217;ve forgot to add any entities, or not setup your database.</p>

<p>That's it for now, I hope this helps to make configuring your application a little clearer.</p>