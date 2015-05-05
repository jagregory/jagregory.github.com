---
layout: post
title: ! 'Fluent NHibernate: Conventions Rewrite'
tags:
- AutoMapping
- Conventions
- Fluent NHibernate
- FluentNHibernate
status: publish
type: post
published: true
meta:
  aktt_notify_twitter: 'no'
  _edit_last: '2'
  dsq_thread_id: '644650355'
---
I've just committed a rather large update to the Fluent NHibernate conventions code. This post explains why I've done this, and gives you some starting points to update your code. Anything else you need can be found on the [wiki](https://github.com/jagregory/fluent-nhibernate/wiki) under [conventions](https://github.com/jagregory/fluent-nhibernate/wiki/Conventions) and [converting to new-style conventions](https://github.com/jagregory/fluent-nhibernate/wiki/Converting-to-new-style-conventions).

<!-- more -->

**So why have I rewritten conventions?** Our original implementation was simple, but not really maintainable into the future. It was a single class that was a major violation of separation of concerns, and it just kept growing and growing. It didn't gracefully degrade either; if we didn't have the exact convention you needed it was tough luck, there was very little you could do short of modifying the code yourself.

Our original design worked something like this:

``` csharp
.WithConventions(conventions =>
{
  conventions.TableName = type => type.Name + "Table";
  conventions.DefaultLazy = true;
})
```

As you can see, it's a fairly simple design. Lambda functions were set that got called in various places throughout the mapping generation cycle. It was a good design for simple scenarios; however, when you start overriding more conventions, and introducing logic into them, it can quickly become a massive ball of mud. So while there was an initial simplicity to it, that simplicity was quickly lost if you were trying to do anything clever with it. This is another thing that the rewrite aims to solve.

**So how have things changed?** The ability to define conventions inline is gone, for starters. Instead what you have is a series of interfaces of varying degrees of granularity; any classes implementing any of the interfaces will be automagically hooked into the mapping generation cycle. What this equates to is you'll have a folder/namespace in your projects dedicated to conventions, each class making an alteration to the conventions when it's called. As each convention is an interface, it means you can implement multiples of them in a single class, which allows you to group common conventions into a single class if you desire.

## Example: Customising the table name

``` csharp
public class TableNameConvention : IClassConvention
{
  public bool Accept(IClassMap classMap)
  {
    return true; // apply to all mappings
  }

  public void Apply(IClassMap classMap)
  {
    // will produce table names like: tbl_Customer, tbl_Product
    classMap.WithTable("tbl_" + classMap.EntityType.Name);
  }
}
```

This is a simple implementation of the `IClassConvention` interface, which is applied to all class mappings (hence the `return true` in `Accept`) and simply prefixes the table name with `tbl_`.

## Example: Adding your conventions

There's one thing you need to do to get Fluent NHibernate to use your conventions, and that's to inform the convention discovery mechanism of where it's to search for conventions. You do this using the `PersistenceModel`s `ConventionFinder` property, or through the `ConventionDiscovery` property through [Fluent Configuration](http://wiki.fluentnhibernate.org/show/FluentConfiguration).

``` csharp
Fluently.Configure()
  .Mappings(m =>
  {
    m.FluentMappings
      .AddFromAssemblyOf<Entity>()
      .ConventionDiscovery.AddFromAssemblyOf<MyConvention>())
  })
```

That's all there is to it really, certainly from a users perspective anyway. The architecture is designed in such a way that you have a much greater control of the granularity of your conventions; if you need a convention we haven't explicitly supplied, you can use the convention &#8220;above&#8221; the one you want, and implement it yourself. If you need a convention for just Bag collections (which we don't have one for), you just need to create an implementation of `IHasManyConvention` and limit it to bags. Easy.

## Some shortcuts

I realise that the new design is more verbose than it was originally, and if your scenario really is one that only uses one or two conventions, then the new design might be too much for you. To cater for you people, I've created some basic inline support. I really don't recommend you use these unless you're doing something <em>really</em> simple. Separation is always preferred.

There's the `ConventionBuilder` class which has several static properties (`Class` for example, there's one for each convention) which allow you to create an inline convention.

``` csharp
ConventionBuilder.Class.Always(x => x.SetAttribute("something", "true"))
ConventionBuilder.Id.Always(x => x.ColumnName("ID"))

ConventionBuilder.Property.When(
  x => x.Property.PropertyType == typeof(int),
  x => x.ColumnName(x.Property.Name + "Num")
)
```

These can be used directly in the `ConventionDiscovery` property mentioned above; it has an `Add` method that can take a params array of conventions, there's also a `Setup` method which can be used for multiple additions.

``` csharp
.ConventionDiscovery.Add(
  ConventionBuilder.Class.Always(x => x.SetAttribute("something", "true")),
  ConventionBuilder.Id.Always(x => x.ColumnName("ID"))
)

.ConventionDiscovery.Setup(c =>
{
  c.AddFromAssemblyOf<MyConvention>();
  c.Add(ConventionBuilder.Id.Always(x => x.ColumnName("ID")));
})
```

In addition to that, there's a limited selection of very common conventions which can be used inline. Again, I don't advocate using these for anything complicated. If you start having logic in your conventions, or even if the lambdas end up being multi-line, I'd suggest using the full conventions. These helpers live in the `FluentNHibernate.Conventions.Helpers` namespace.

``` csharp
Table.Is(x => "tbl_" + x.EntityType.Name)
PrimaryKey.Name.Is("ID")
DynamicUpdate.AlwaysTrue()
```

These can be used in the same way as the `ConventionBuilder` above.

## Regarding auto mapping

The auto mapper uses a small subset of conventions to discover various parts of your mappings. It was originally the case that these special conventions were lumped in with the rest of the conventions, even though you couldn't use them outside of the automapper. As the old style conventions have gone, the automapper now has a separate set of conventions (they're the same ones, just moved) that it uses. So in addition to the `ConventionDiscovery` property, the auto mapper has a `WithSetup` method that you can use to configure the auto mapping specific ones (`IsBaseType` primarily).

## Further reading

So this post should have given you a basic introduction to the changes I've made. To go further, you're going to have to know what [interfaces are available](https://github.com/jagregory/fluent-nhibernate/wiki/Available-conventions) to implement. You should probably also read the [general conventions](https://github.com/jagregory/fluent-nhibernate/wiki/Convertings) wiki, how to [convert your existing conventions](https://github.com/jagregory/fluent-nhibernate/wiki/Converting-to-new-style-conventions) to the new style, and the [convention shortcuts](https://github.com/jagregory/fluent-nhibernate/wiki/Convention-shortcut) if it interests you. For maintainers, or just curious people, there's also the wiki on how the [conventions work behind-the-scenes](http://wiki.fluentnhibernate.org/show/Conventions).
