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
I've just committed a breaking change to <a href="http://www.fluentnhibernate.org">Fluent NHibernate</a> (as of <a href="http://code.google.com/p/fluent-nhibernate/source/detail?r=184" title="Revision 184">r184</a>), which I thought I'd document here for anyone interested; it's a reworking of the subclass syntax.

Mapping multiple subclasses with the same parent wasn't a very fluent affair, and it was pretty *wordy* too. You can see a comparison of the old and new syntaxes below.

<!-- more -->

### Before

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

### After

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

Much nicer! The changes you can see here are:

  * `DiscriminateSubClassesOnColumn` now assumes your discriminator is a `string` if you don't specify a type
  * `SubClass` defaults to using the subclass type name as a discriminator value
  * `IdentifiedBy` and `MapSubClassColumns` are now merged into `SubClass` as overloads.

Nested subclasses were never really supported in Fluent NHibernate, but they were *hackable*. You could abuse `DiscriminateSubClassesOnColumn` to let you trick it into creating nested classes. This worked but it led to some really ugly mapping code (and a nasty hack in the Fluent NHibernate codebase). I've given some loving to this area and have managed to really sweeten-up the syntax.

### Before

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

### After

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

The changes in this one are:

  * `SubClass` can now be used within subclasses without having to reuse `DiscriminateSubClassesOnColumn`

All in all, these changes serve to make mapping subclasses in Fluent NHibernate a little bit neater.

## Update

As requested, here are the domain entities that the above mappings represent.

### Two subclasses with shared parent

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

### Subclass of a subclass

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
