---
layout: post
title: ! 'Fluent NHibernate: Mapping private and protected properties'
tags:
- Fluent NHibernate
- FluentNHibernate
- NHibernate
status: publish
type: post
published: true
meta:
  aktt_notify_twitter: 'no'
  _edit_last: '2'
  dsq_thread_id: '644651391'
---
> **Notice:** The content in this post may be out of date, please refer to the <a href="https://github.com/jagregory/fluent-nhibernate/wiki/Fluent-mapping">Fluent Mapping</a> page in the <a href="https://github.com/jagregory/fluent-nhibernate/wiki">Fluent NHibernate Wiki</a> for the latest version.

<p>There's been a point of contention for some users of <a href='http://www.fluentnhibernate.org'>Fluent NHibernate</a> since the beginning, and that&#8217;s the lack of a method of mapping private and protected properties on their domain entities.</p>

<p>The issue stems from our use of lambda expressions for static reflection of your entities, one of the appealing properties of Fluent NHibernate; by utilising expressions we&#8217;re able to protect your mappings from refactoring side-effects. However, lambda expressions can only reference properties that are public on an object, so that makes it difficult to use against protected or private properties.</p>

<p>None of the solutions we have are ideal, we&#8217;ll be the first to admit that; but considering Fluent NHibernate was never designed to support these situations, and the limitations C# imposes on us, we&#8217;ve got some pretty reasonable choices. Each option comes with it&#8217;s own compromises, so it&#8217;s important you pick the method that has the compromises you&#8217;re more willing to accept; I&#8217;ll outline the pros and cons of each approach.</p>

<h2 id='nested_expression_exposition_class'>Nested expression exposition class</h2>

``` csharp
public class Product
{
  private int Id { get; set; }
  
  public static class Expressions
  {
    public static readonly Expression<Func<Product, object>> Id = x => x.Id;
  }
}

public ProductMap : ClassMap<Product>
{
  public ProductMap()
  {
    Id(Product.Expressions.Id);
  }
}
```

<p>This option takes advantage of an interesting side effect of nested class scope and access modifiers. If you haven&#8217;t done something like this before, basically nested classes can access their parent&#8217;s private/protected members. We create a nested static class that exposes an <code>Expression</code> for each hidden member. We can then use the expressions declared in this static class to reflect against the hidden members. It&#8217;s reasonably clean, made even more so if you separate the <code>Expressions</code> class into a partial class of your entity; so you could have <code>Product.cs</code> and <code>ProductExpressions.cs</code>.</p>

<h3 id='pros'>Pros</h3>
<ul><li>Refactoring friendly</li><li>Mappings still readable</li></ul>

<h3 id='cons'>Cons</h3>
<ul><li>Modification to entities required</li><li>Need 3 classes to map an entity (entity, expression class, and mapping)</li></ul>

<h2 id='nested_mapping'>Nested mapping</h2>

``` csharp
public class Product
{
  private int Id { get; set; }
  
  public ProductMap : ClassMap<Product>
  {
    public ProductMap()
    {
      Id(x => x.Id);
    }
  }
}
```

<p>Again using the scope trick, you can wrap your mapping inside your entity. This allows you to use the expressions as normal, without having to do any expression tricks. Like the expression class previously, this can be made neater by using partial classes.</p>

<h3 id='pros'>Pros</h3>
<ul><li>Refactoring friendly</li><li>Can use normal expressions</li></ul>

<h3 id='cons'>Cons</h3>
<ul><li>Modification to entities required</li><li>Mapping nested in entity, so can&#8217;t be separated across assemblies/namespaces</li></ul>

<h2 id='reveal_and_string_names'>Reveal static class and string-based names</h2>

``` csharp
public class Product
{
  private int Id { get; set; }
}

public ProductMap : ClassMap<Product>
{
  public ProductMap()
  {
    Id(Reveal.Property("Id"));
  }
}
```

<p>Our final option is different to the previous two, in that it utilises an expression generator to create an expression for a private or protected member. This is essentially what the first two are doing, just with strings instead of nesting tricks.</p>

<h3 id='pros'>Pros</h3>
<ul><li>No modifications to entities needed</li><li>Mappings and entity remain separate</li></ul>

<h3 id='cons'>Cons</h3>
<ul><li>Potential renaming issues</li></ul>

<h2 id='conclusion'>Conclusion</h2>

<p>You have the power, now pick the one that suits you best. Compile time safety, or entity purity? You&#8217;re now free to make the decision, instead of us.</p>

<p>I don&#8217;t think anyone on the Fluent NHibernate team is particularly happy with that we have to write these hacks, but we&#8217;re doing the best with what we&#8217;ve got. We all have different preferences, but at least there&#8217;s something for everyone now.</p>
