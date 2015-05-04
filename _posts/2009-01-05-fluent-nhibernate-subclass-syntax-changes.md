---
layout: post
title: Fluent NHibernate SubClass syntax changes
tags:
- Fluent NHibernate
- FluentNHibernate
- NHibernate
- OpenSource
status: publish
type: post
published: true
meta:
  aktt_notify_twitter: 'no'
  _edit_last: '2'
  dsq_thread_id: '644651215'
---
<p>I've just committed a breaking change to <a href="http://www.fluentnhibernate.org">Fluent NHibernate</a> (as of <a href="http://code.google.com/p/fluent-nhibernate/source/detail?r=184" title="Revision 184">r184</a>), which I thought I'd document here for anyone interested; it's a reworking of the subclass syntax.</p>

<p>Mapping multiple subclasses with the same parent wasn't a very fluent affair, and it was pretty <em>wordy</em> too. You can see a comparison of the old and new syntaxes below.</p>

<h4>Before</h4>

``` csharp
var discriminator = DiscriminateSubClassesOnColumn<string>("Type");

discriminator.SubClass<B>()
  .IdentifiedBy("bID")
  .MapSubClassColumns(m =>
  {
    m.Map(x => x.BProperty);
  });
  
discriminator.SubClass<C>()
  .IdentifiedBy("cID")
  .MapSubClassColumns(m =>
  {
    m.Map(x => x.CProperty);
  });
```

<h4>After</h4>

``` csharp
DiscriminateSubClassesOnColumn("Type")
  .SubClass<B>(m =>
  {
    m.Map(x => x.BProperty);
  })
  .SubClass<C>(m =>
  {
    m.Map(x => x.CProperty);
  });
```

<p>Much nicer! The changes you can see here are:</p>

<ul>
  <li><code>DiscriminateSubClassesOnColumn</code> now assumes your discriminator is a <code>string</code> if you don't specify a type</li>
  <li><code>SubClass</code> defaults to using the subclass type name as a discriminator value</li>
  <li><code>IdentifiedBy</code> and <code>MapSubClassColumns</code> are now merged into <code>SubClass</code> as overloads.</li>
</ul>

<p>Nested subclasses were never really supported in Fluent NHibernate, but they were <em>hackable</em>. You could abuse <code>DiscriminateSubClassesOnColumn</code> to let you trick it into creating nested classes. This worked but it led to some really ugly mapping code (and a nasty hack in the Fluent NHibernate codebase). I've given some loving to this area and have managed to really sweeten-up the syntax.</p>
  
<h4>Before</h4>

``` csharp
DiscriminateSubClassesOnColumn<string>("Type")
  .SubClass<B>()
    .IdentifiedBy("bID")
    .MapSubClassColumns(m =>
    {
      m.Map(x => x.BProperty);
      m.DiscriminateSubClassesOnColumn<string>("Type")
        .SubClass<C>()
          .IdentifiedBy("cID")
          .MapSubClassColumns(m =>
          {
            m.Map(x => x.CProperty);
          });
    });
```

<h4>After</h4>

``` csharp
DiscriminateSubClassesOnColumn("Type")
  .SubClass<B>(m =>
  {
    m.Map(x => x.BProperty);
    m.SubClass<C>(m =>
    {
      m.Map(x => x.CProperty);
    });
  });
```

<p>The changes in this one are:</p>
<ul>
  <li><code>SubClass</code> can now be used within subclasses without having to reuse <code>DiscriminateSubClassesOnColumn</code></li>
</ul>

<p>All in all, these changes serve to make mapping subclasses in Fluent NHibernate a little bit neater.</p>

<h2>Update</h2>
<p>As requested, here are the domain entites that the above mappings represent.</p>

<h4>Two subclasses with shared parent</h4>

``` csharp
public class A
{}

public class B : A
{
  public virtual string BProperty { get; set; }
}

public class C : A
{
  public virtual string CProperty { get; set; }
}
```

<h4>Subclass of a subclass</h4>
``` csharp
public class A
{}

public class B : A
{
  public virtual string BProperty { get; set; }
}

public class C : B
{
  public virtual string CProperty { get; set; }
}
```