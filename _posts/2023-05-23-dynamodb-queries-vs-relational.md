---
layout: post
title: How DynamoDB queries behave compared to relational databases
date: 2023-05-23
published: true
---

I wanted to write about how using Async Iterators in Node.JS can make querying DynamoDB tables more pleasant, but I got
side-tracked with explaining why pagination and is more often necessary when using DynamoDB than when using relational
databases.

So instead of the thing I meant to write about, here's a refresher on how bounded and unbounded queries are treated
differently by typical relational databases and DynamoDB.

<!-- more -->

## Relational databases

There's two kinds of queries to understand: unbounded and bounded.

### Unbounded queries

An unbounded query is one without an explicit upper limit on the number of records, _this is generally a bad idea_.

As there's always a hard limit somewhere, unbounded queries put the responsibility for enforcing the limits of the
query onto the underlying database engine or hardware. In most cases, the behaviour you see with unbounded queries is
they will run for as long as possible until they either complete and return all the data you requested or fail and
return an error.

Small tables won't be an issue, the query will complete quickly and return the data you want.

Queries over _not too large_ tables will be slower than usual but will likely complete eventually and return all the
data.

Large tables are where the problem lies. You run the risk of hitting timeouts (in the database client or
server, or lower in the stack) or exhausting resources like available memory which would cause a query to fail and
potentially affect the health of your database.

Unbounded queries can be insidious when they are written for small tables which don't remain small tables. As the tables
accumulate data over months and years, queries start slowing down, until one day you start experiencing timeouts or out
of memory issues.

### Bounded queries

A bounded query is a query which you're putting a deliberate and explicit upper limit on the number of records that will
be returned by the query. In a relational database (such as PostgreSQL or SQL Server) you do this using queries
with `limit` (or `top` in SQL Server), such as: `select * from users limit 30`

When you do that, the database behaves pretty much how you would expect it to: you ask for up to `30` rows and it will
return you up to `30` rows. By being explicit in how many records you're expecting to return, assuming you've chosen a
reasonable limit, your query duration and resource consumption should be stable regardless of how many rows are present
in the table, even as the table grows.

To summarise:

- Bounded queries - you ask for `30` rows, the database gives you (up to) `30` rows.
- Unbounded queries - you ask for everything, the database will give you everything or it will fail. All or nothing.

## DynamoDB

DynamoDB also supports both bounded and unbounded queries, but for all queries it also applies strict constraints which
make all queries bounded in a much more obvious way than relational databases.

Bounded queries can can use a `Limit` parameter when running a query, but unlike relational databases DynamoDB may
return fewer than that limit _even if there are more records available_. This is a crucial difference from relational
databases, and will affect how you design your application.

From here on the behaviour is the same regardless of whether you're running a bounded or an unbounded query against a
DynamoDB table.

From the DynamoDB documentation:

> The result set for a `Query` is limited to 1 MB per call.
>
> The maximum item size in DynamoDB is 400 KB, which includes both attribute name binary length (UTF-8 length) and
> attribute value lengths (again binary length). The attribute name counts towards the size limit.
>
> -- [API Specific Limits](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/ServiceQuotas.html#limits-api)

_(the same is true for `Scan`)_

Whilst there's no hard upper limit on the number of individual records a query or scan can return, they are constrained
by the total size of the data being returned. When a query exceeds this limit, DynamoDB will respond with all the
records it was able to process prior to hitting the limit, regardless of how many were asked for.

So the maximum you can return from a single query is 1 MB and the largest record you can have is 400 KB, which means in
absolute worst-case scenario if all your records are the largest they're allowed to be **your query could return just
two items**! even if you asked for everything.

It's also worth mentioning the impact of filter expressions and projections, or rather their non-impact. You may think
that by adding a filter expression (to exclude certain items from your queries) or projection expressions (to limit the
attributes returned) would allow you to avoid the 1 MB limit but that is not the case:

> DynamoDB calculates the number of read capacity units consumed based on item size, not on the amount of data that is
> returned to an application. For this reason, the number of capacity units consumed is the same whether you request all
> of the attributes (the default behavior) or just some of them (using a projection expression). The number is also the
> same whether or not you use a filter expression.
>
> -- [Query operations in DynamoDB](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/Query.html)

You can think of this a bit like a [MapReduce](https://en.wikipedia.org/wiki/MapReduce)-style algorithm. In the first
phase DynamoDB reaches out to any nodes which may contain data for your query (map). It collects as much data as it can
until it hits the 1 MB limit, then it stops. Then a second phase starts where it applies any filters or projections
(reduce), and then returns the results to the caller.

By the time DynamoDB applies any filtering to your queries it has already reached the limits of the amount of data
it will scan. This also means the only benefit applying filtering and projections on the query (instead of in your own
code) is to minimise the amount of data which is transferred and serialized/deserialized.

> Why DynamoDB doesn't pass filters down to the nodes is something for smarter people than me to understand.

In a result set which has more records available but weren't returned to us because of the above limits, DynamoDB will
also return a `LastEvaluatedKey` which is the key of the last record in the result set before the limit was exceeded. If
we pass that key as the `ExclusiveStartKey` in a subsequent `Query`, DynamoDB will carry on from where it left off and
return you the next batch of records until it either runs out of records to return or it hits a limit again. Repeat that
process until DynamoDB stops returning a `LastEvaluatedKey` in the response and you've now retrieved all the data for
your query (or scan).

### What does this look like in an application?

> I've exaggerated the item sizes in these examples to keep them brief. In reality, your items should be considerably
> smaller than what's in these examples and you'll be getting many more items per-page of results.

First, we're going to query for all the Orders that a particular User has made. We make an initial `Query` with that
user's ID as the partition key, and don't supply a `LastEvaluatedKey` because we're reading the first page of results.

```
Query(pk: "user1", LastEvaluatedKey: null) ->

  items:
  - order#1  - 100kb
  - order#2  - 100kb
  - order#3  - 100kb
  - order#4  - 100kb
  - order#5  - 100kb
  - order#6  - 100kb
  - order#7  - 100kb
  - order#8  - 100kb
  - order#9  - 100kb
  - order#10 - 100kb
  lastEvaluatedKey: order#10

  1 MB limit reached.
```

DynamoDB returned `10` order records for that query, it also returned a `LastEvaluatedKey` indicating there is more data
available but it didn't return it because it hit a limit.

So we issue a followup query using the `LastEvaluatedKey` as the `ExclusiveStartKey`, **exclusive** being a significant
word here meaning that it will start returning records _after_ this start key:

```
Query(pk: "user1", ExclusiveStartKey: "order#10") ->

  items:
  - order#11 - 100kb
  - order#12 - 400kb
  - order#13 - 200kb
  - order#14 - 200kb
  - order#15 - 100kb
  lastEvaluatedKey: order#15

  1 MB limit reached.
```

This time the query returned only returned `5` order records, much fewer than last time. We can assume from the size of
the individual items that so few items were returned because of those large `200kb` and `400kb` items. This is a pretty
consistent behaviour you'll see when querying DynamoDB tables: the number of items in query result sets varies based on
the size of the data being returned.

The query also returned a `LastEvaluatedKey` again, so we issue another query:

```
Query(pk: "user1", ExclusiveStartKey: "order#15") ->

  items:
  - order#16 - 100kb
  - order#17 - 100kb
  - order#18 - 100kb
  lastEvaluatedKey: null

  No more records.
```

This time DynamoDB returned us `3` order records and no `LastEvaluatedKey`, indicating it has reached the end of the
records which match our query.

In our application we should be collecting the records as we're iterating over the pages. When we finally reach the
last page we can return everything as one list to our caller, who should be non-the-wiser about multiple queries
happening.

#### A note about limits

If you want to constrain the total number of records that DynamoDB will return `Limit` is useful, but bear in mind it is
better thought of as a "batch size" limit than a "total records" limit.

> This is also true in relational databases, but because we can do much larger result sets in relational databases it's
> easy to treat `limit` as a total record limit. When you combine a `limit` with an `offset` in PostgreSQL you'll get
> the same behaviour as below.

Using the examples above, if we were to ask DynamoDB to return only `5` records, it would work exactly as you'd expect:

```
Query(pk: "user1", Limit: 5, LastEvaluatedKey: null) ->

  items:
  - order#1  - 100kb
  - order#2  - 100kb
  - order#3  - 100kb
  - order#4  - 100kb
  - order#5  - 100kb
  lastEvaluatedKey: null

  No more records.
```

DynamoDB returns `5` records, and doesn't have a `LastEvaluatedKey` because there's no more data to return.

However, what if we wanted to return `30` items?

```
Query(pk: "user1", Limit: 30, LastEvaluatedKey: null) ->

  items:
  - order#1  - 100kb
  - order#2  - 100kb
  - order#3  - 100kb
  - order#4  - 100kb
  - order#5  - 100kb
  - order#6  - 100kb
  - order#7  - 100kb
  - order#8  - 100kb
  - order#9  - 100kb
  - order#10 - 100kb
  lastEvaluatedKey: order#10

  1 MB limit reached.
```

As before, DynamoDB makes an attempt to return `30` records but stops at `10` because of the aforementioned limits. So
again as before we issue a followup query, but what should we pass as the `Limit` this time?

```
Query(pk: "user1", Limit: ???, ExclusiveStartKey: "order#10")
```

This is where you see the difference with `Limit` being a batch size limit, not a total record limit. You can't just
pass `30` to every subsequent query because DynamoDB will just keep attempting to fetch `30` more records every
query.

Instead, you need to keep a rolling tally yourself, and use that to determine an appropriate limit and stop querying
either when there's no more `LastEvaluatedKey` or when you hit your total records:

```
Query(pk: "user1", Limit: 30 - totalFetchedSoFar, ExclusiveStartKey: "order#10")
```

### A note about filters

Filters add an extra surprise to the mix: Sometimes a DynamoDB query with a filter applied will return an empty result
set with a `LastEvaluatedKey` (indicating there's more data to fetch). This can be confounding the first time it
happens.

If you remember back to the earlier note about filters:

> In the first phase DynamoDB reaches out to any nodes which may contain data for your query (map). It collects as much
> data as it can until it hits the 1 MB limit, then it stops. Then a second phase starts where it applies any filters or
> projections (reduce), and then returns the results to the caller.

If DynamoDB fetches the maximum 1 MB of data and then applies a filter, if that filter excludes every record that was
just fetched, there'll be nothing left to return. In this case, DynamoDB will return an empty result set with
a `LastEvaluatedKey` pointing to the last item it filtered out.

The main takeaway from this is: rely on `LastEvaluatedKey` to tell if there's no more data available not `Items.length`
otherwise you may incorrectly assume you've fetched all the data when you haven't.

## Conclusion

Queries with relational databases tend to behave predictably. You ask them for an amount of rows and they'll give you
those rows (or they'll die trying). They may run out of memory, run out of time, or your users will just move on before
they've completed, but they will give you those rows you asked for.

DynamoDB on the other hand is much less accommodating. Whether you ask DynamoDB for everything or just ask for just `30`
records, there's a good chance DynamoDB will decide to give you fewer records than you wanted. You need to factor this
into how you write your data access code, because it's much more likely to happen than you expect, and this is why
you should almost always implement paginated queries with DynamoDB.
