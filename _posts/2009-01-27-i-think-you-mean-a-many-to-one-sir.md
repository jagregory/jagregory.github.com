---
layout: post
title: I think you mean a many-to-one, sir
tags:
- Database
- Design
status: publish
type: post
published: true
meta:
  aktt_notify_twitter: 'no'
  _edit_last: '2'
  dsq_thread_id: '644650344'
---
<blockquote>
<p>This is a question that crops up <strong>a lot</strong>, in various forms, on the <a href='http://www.fluentnhibernate.org'>Fluent NHibernate</a> and <a href='http://groups.google.com/group/nhusers'>NHibernate Users</a> mailing lists. <em>My one-to-one mapping isn&#8217;t working, what&#8217;s wrong?</em> aka Incorrectly using a one-to-one relationship when you actually need a many-to-one.</p>
</blockquote>

<p>There&#8217;s a common misunderstanding where people try to use a one-to-one relationship where a many-to-one is appropriate. I believe this is because people tend to get tunnel vision when designing their entities, which leads them to make incorrect assumptions. They focus on one entity at a time, and when that has a single entity related to it, they jump to the conclusion it&#8217;s a one-to-one they need; after all, there&#8217;s their current entity (one) and the related entity (to-one). They&#8217;re actually forgetting that there can be multiple instances of their <em>current entity</em>.</p>

<p>There&#8217;s also a big distinction between what&#8217;s possible in the domain, and what&#8217;s possible by design in the database; for example, two businesses may <strong>never</strong> share an address in your application, but in the database there&#8217;s nothing stopping two rows in the Business table from referencing the same address row in the database. This is logic that can be applied on-top of a database design, but there&#8217;s nothing in the underlying pattern to disallow it.</p>

<h2 id='manytoone'>Many-to-one</h2>

<p>Lets have a look at what actually is a many-to-one. Here&#8217;s a small database schema and the related entity.</p>

``` sql
table Customer (
  Id int primary key,
  Name varchar(100),
  AddressId int foreign key (Address.Id)
)

table Address (
  Id int primary key,
  Number int,
  Street varchar(100)
)

public class Customer
{
  public int Id { get; set; }
  public string Name { get; set; }
  public Address Address { get; set; }
}
```

<p>This is a standard many-to-one relationship, many <code>Customers</code> to one <code>Address</code>; the tables are linked by the <code>AddressId</code> key in the <code>Customer</code> table. You can see how people can misinterpret this as a one-to-one relationship when designing the Customer entity; the customer has one address, so it must be a one-to-one. People forget about this scenario:</p>

<table class="db-table">
  <caption>Customer</caption>
  <thead>
    <tr>
      <th>Id</th>
      <th>Name</th>
      <th>AddressId</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>1</td>
      <td>Plumbers</td>
      <td>1</td>
    </tr>
    <tr>
      <td>2</td>
      <td>Joiners</td>
      <td>2</td>
    </tr>
    <tr>
      <td>3</td>
      <td>Roofers</td>
      <td>1</td>
    </tr>
  </tbody>
</table>

<table class="db-table">
  <caption>Address</caption>
  <thead>
    <tr>
      <th>Id</th>
      <th>Number</th>
      <th>Street</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>1</td>
      <td>23</td>
      <td>Baker St.</td>
    </tr>
    <tr>
      <td>2</td>
      <td>47</td>
      <td>Jefferson Ave.</td>
    </tr>
  </tbody>
</table>

<p>That is, the first and third customer both reference the first address.</p>

<h2 id='onetoone'>One-to-one</h2>

<p><strong>So what actually is a one-to-one relationship then?</strong> A one-to-one is a relationship between two tables that share a mutually exclusive primary key value.</p>

``` sql
table Customer (
  Id int primary key,
  Name varchar(100),
)

table Address (
  Id int primary key,
  Number int,
  Street varchar(100)
)

public class Customer
{
  public int Id { get; set; }
  public string Name { get; set; }
  public Address Address { get; set; }
}
```

<p>You can see in this design <code>Customer</code> has no direct reference to <code>Address</code>, the two tables share a primary key value; so there would be a record in <code>Customer</code> with a primary key of <code>1</code>, and a record in <code>Address</code> that also has a primary key of <code>1</code>. It&#8217;s fairly common to have the primary key on the second table (<code>Address</code> in our case) be manually inserted on creation of a record in the first, so it may only be the first table that has a true auto-incrementing primary key.</p>

<p>It&#8217;s also noticeable that both examples have exactly the same class design, this probably contributes to the confusion too, as it&#8217;s not immediately clear from the class what kind of relationship it is.</p>

<p>So just remember this: <strong>if you think you&#8217;re mapping a one-to-one, you probably aren&#8217;t!</strong> It&#8217;s pretty uncommon to find a one-to-one relationship in a properly designed schema, 90% of the time it&#8217;ll be a many-to-one you need.</p>
