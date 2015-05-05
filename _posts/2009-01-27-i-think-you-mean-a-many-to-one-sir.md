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
> This is a question that crops up **a lot**, in various forms, on the [Fluent NHibernate](http://www.fluentnhibernate.org) and [NHibernate Users](http://groups.google.com/group/nhusers) mailing lists. *My one-to-one mapping isn't working, what's wrong?* aka Incorrectly using a one-to-one relationship when you actually need a many-to-one.

There's a common misunderstanding where people try to use a one-to-one relationship where a many-to-one is appropriate. I believe this is because people tend to get tunnel vision when designing their entities, which leads them to make incorrect assumptions. They focus on one entity at a time, and when that has a single entity related to it, they jump to the conclusion it's a one-to-one they need; after all, there's their current entity (one) and the related entity (to-one). They're actually forgetting that there can be multiple instances of their *current entity*.

<!-- more -->

There's also a big distinction between what's possible in the domain, and what's possible by design in the database; for example, two businesses may **never** share an address in your application, but in the database there's nothing stopping two rows in the Business table from referencing the same address row in the database. This is logic that can be applied on-top of a database design, but there's nothing in the underlying pattern to disallow it.

## Many-to-one

Lets have a look at what actually is a many-to-one. Here's a small database schema and the related entity.

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

This is a standard many-to-one relationship, many `Customers` to one `Address`; the tables are linked by the `AddressId` key in the `Customer` table. You can see how people can misinterpret this as a one-to-one relationship when designing the Customer entity; the customer has one address, so it must be a one-to-one. People forget about this scenario:

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

That is, the first and third customer both reference the first address.

## One-to-one

**So what actually is a one-to-one relationship then?** A one-to-one is a relationship between two tables that share a mutually exclusive primary key value.

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

You can see in this design `Customer` has no direct reference to `Address`, the two tables share a primary key value; so there would be a record in `Customer` with a primary key of `1`, and a record in `Address` that also has a primary key of `1`. It's fairly common to have the primary key on the second table (`Address` in our case) be manually inserted on creation of a record in the first, so it may only be the first table that has a true auto-incrementing primary key.

It's also noticeable that both examples have exactly the same class design, this probably contributes to the confusion too, as it's not immediately clear from the class what kind of relationship it is.

So just remember this: **if you think you're mapping a one-to-one, you probably aren't!** It's pretty uncommon to find a one-to-one relationship in a properly designed schema, 90% of the time it'll be a many-to-one you need.
