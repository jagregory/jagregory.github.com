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
<p>I&#8217;ve just committed a rather large update to the Fluent NHibernate conventions code. This post explains why I&#8217;ve done this, and gives you some starting points to update your code. Anything else you need can be found on the <a href="https://github.com/jagregory/fluent-nhibernate/wiki">wiki</a> under <a href="https://github.com/jagregory/fluent-nhibernate/wiki/Conventions">conventions</a> and <a href="https://github.com/jagregory/fluent-nhibernate/wiki/Converting-to-new-style-conventions">converting to new-style conventions</a>.</p>

<p><strong>So why have I rewritten conventions?</strong> Our original implementation was simple, but not really maintainable into the future. It was a single class that was a major violation of separation of concerns, and it just kept growing and growing. It didn&#8217;t gracefully degrade either; if we didn&#8217;t have the exact convention you needed it was tough luck, there was very little you could do short of modifying the code yourself.</p>

<p>Our original design worked something like this:</p>

``` csharp
.WithConventions(conventions =>
{
  conventions.TableName = type => type.Name + "Table";
  conventions.DefaultLazy = true;
})
```

<p>As you can see, it&#8217;s a fairly simple design. Lambda functions were set that got called in various places throughout the mapping generation cycle. It was a good design for simple scenarios; however, when you start overriding more conventions, and introducing logic into them, it can quickly become a massive ball of mud. So while there was an initial simplicity to it, that simplicity was quickly lost if you were trying to do anything clever with it. This is another thing that the rewrite aims to solve.</p>

<p><strong>So how have things changed?</strong> The ability to define conventions inline is gone, for starters. Instead what you have is a series of interfaces of varying degrees of granularity; any classes implementing any of the interfaces will be automagically hooked into the mapping generation cycle. What this equates to is you&#8217;ll have a folder/namespace in your projects dedicated to conventions, each class making an alteration to the conventions when it&#8217;s called. As each convention is an interface, it means you can implement multiples of them in a single class, which allows you to group common conventions into a single class if you desire.</p>

<h2 id="example_customising_the_table_name">Example: Customising the table name</h2>

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

<p>This is a simple implementation of the <code>IClassConvention</code> interface, which is applied to all class mappings (hence the <code>return true</code> in <code>Accept</code>) and simply prefixes the table name with <code>tbl_</code>.</p>

<h2 id="example_adding_your_conventions">Example: Adding your conventions</h2>

<p>There&#8217;s one thing you need to do to get Fluent NHibernate to use your conventions, and that&#8217;s to inform the convention discovery mechanism of where it&#8217;s to search for conventions. You do this using the <code>PersistenceModel</code>s <code>CovnentionFinder</code> property, or through the <code>ConventionDiscovery</code> property through <a href="http://wiki.fluentnhibernate.org/show/FluentConfiguration">Fluent Configuration</a>.</p>

``` csharp
Fluently.Configure()
  .Mappings(m =>
  {
    m.FluentMappings
      .AddFromAssemblyOf<Entity>()
      .ConventionDiscovery.AddFromAssemblyOf<MyConvention>())
  })
```

<p>That&#8217;s all there is to it really, certainly from a users perspective anyway. The architecture is designed in such a way that you have a much greater control of the granularity of your conventions; if you need a convention we haven&#8217;t explicitly supplied, you can use the convention &#8220;above&#8221; the one you want, and implement it yourself. If you need a convention for just Bag collections (which we don&#8217;t have one for), you just need to create an implementation of <code>IHasManyConvention</code> and limit it to bags. Easy.</p>

<h2 id="some_shortcuts">Some shortcuts</h2>

<p>I realise that the new design is more verbose than it was originally, and if your scenario really is one that only uses one or two conventions, then the new design might be too much for you. To cater for you people, I&#8217;ve created some basic inline support. I really don&#8217;t recommend you use these unless you&#8217;re doing something <em>really</em> simple. Separation is always preferred.</p>

<p>There&#8217;s the <code>ConventionBuilder</code> class which has several static properties (<code>Class</code> for example, there&#8217;s one for each convention) which allow you to create an inline convention.</p>

``` csharp
ConventionBuilder.Class.Always(x => x.SetAttribute("something", "true"))
ConventionBuilder.Id.Always(x => x.ColumnName("ID"))

ConventionBuilder.Property.When(
  x => x.Property.PropertyType == typeof(int),
  x => x.ColumnName(x.Property.Name + "Num")
)
```

<p>These can be used directly in the <code>ConventionDiscovery</code> property mentioned above; it has an <code>Add</code> method that can take a params array of conventions, there&#8217;s also a <code>Setup</code> method which can be used for multiple additions.</p>

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

<p>In addition to that, there&#8217;s a limited selection of very common conventions which can be used inline. Again, I don&#8217;t advocate using these for anything complicated. If you start having logic in your conventions, or even if the lambdas end up being multi-line, I&#8217;d suggest using the full conventions. These helpers live in the <code>FluentNHibernate.Conventions.Helpers</code> namespace.</p>

``` csharp
Table.Is(x => "tbl_" + x.EntityType.Name)
PrimaryKey.Name.Is("ID")
DynamicUpdate.AlwaysTrue()
```

<p>These can be used in the same way as the <code>ConventionBuilder</code> above.</p>

<h2 id="regarding_auto_mapping">Regarding auto mapping</h2>

<p>The auto mapper uses a small subset of conventions to discover various parts of your mappings. It was originally the case that these special conventions were lumped in with the rest of the conventions, even though you couldn&#8217;t use them outside of the automapper. As the old style conventions have gone, the automapper now has a separate set of conventions (they&#8217;re the same ones, just moved) that it uses. So in addition to the <code>ConventionDiscovery</code> property, the auto mapper has a <code>WithSetup</code> method that you can use to configure the auto mapping specific ones (<code>IsBaseType</code> primarily).</p>

<h2 id="further_reading">Further reading</h2>

<p>So this post should have given you a basic introduction to the changes I&#8217;ve made. To go further, you&#8217;re going to have to know what <a href="https://github.com/jagregory/fluent-nhibernate/wiki/Available-conventions">interfaces are available</a> to implement. You should probably also read the <a href="https://github.com/jagregory/fluent-nhibernate/wiki/Convertings">general conventions</a> wiki, how to <a href="https://github.com/jagregory/fluent-nhibernate/wiki/Converting-to-new-style-conventions">convert your existing conventions</a> to the new style, and the <a href="https://github.com/jagregory/fluent-nhibernate/wiki/Convention-shortcut">convention shortcuts</a> if it interests you. For maintainers, or just curious people, there&#8217;s also the wiki on how the <a href="http://wiki.fluentnhibernate.org/show/Conventions">conventions work behind-the-scenes</a>.</p>
