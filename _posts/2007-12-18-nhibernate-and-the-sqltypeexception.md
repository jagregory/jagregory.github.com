---
layout: post
title: NHibernate and the SqlTypeException
tags:
- .Net
- NHibernate
status: publish
type: post
published: true
meta:
  dsq_thread_id: '644650624'
---
[NHibernate](http://www.nhibernate.org) is a wonderful piece of technology, I love it probably more than is reasonable for code. It does however, occasionally scare you with some seemingly odd behavior. I say seemingly, because every time I've had trouble it's actually ended up being my own fault. *This is one of those times.*

Picture a simple page, with a [DeleGrid](/writings/delegrid/) control, being bound using NHiberate. Baring in mind how the DeleGrid works, two queries were being executed, one to return the first page of data and another to get the total row-count for the grid. *These queries were identical apart from the paging in one, and the projection in the other.*

Upon execution of the second query, NHibernate was throwing a `SqlTypeException` for a `SqlDateTime` overflow. `SqlDateTime overflow. Must be between 1/1/1753 12:00:00 AM and 12/31/9999 11:59:59 PM`. This was pretty bizarre. Why on earth would the first query succeed (and bring back records, fully populated), but the same query again would die.

A good place to start for NHibernate debugging is always the logs, so I delved in. I discovered NHibernate was attempting to execute an update statement just before it tried the second query. It just kept getting stranger, why would a straightforward query cause an update?

I thought i'd investigate why the update statement was failing first, then I'd tackle the problem of why it was even updating at all. Looking at the query I identified the column that was causing the exception, it was (as expected) a `DateTime` column that was trying to be set to `DateTime.MinValue`. This exception is thrown because .Net and SQL Server have different ideas over what the minimum value for a `DateTime` should be.

Now, why would this column be being set at all? Well, it ends up that the column in the database was nullable, but the property in the object wasn't. So because `DateTime` is a value type and cannot be set to `null`, NHibernate was populating it with the closest value to `null` as it could manage.

That was the key, as soon as I had that realisation, it was obvious what the problem was.

NHibernate knew that the database had a nullable column, but it had to manage with the non-nullable field on the object. When it came to run the second query, it noticed that the property wasn't null as the mapping file said it should be, so it determined the value must have changed. It then attempted to persist those changes before executing the query!

## To break it down

  1. Nullable column pulled into a non-nullable field forces NHibernate to create the smallest value it can.
  2. NHibernate then checks for any changes, expecting a `null` on that field but finding a value.
  3. Object now considered dirty because value has allegedly changed.
  4. NHibernate performs an update before it pulls back the data agian.

So the fix was simply to make the `DateTime` in the object a `DateTime?`, a nullable `DateTime`. That got rid of the false update, and fixed my queries. Simple when you know what the problem is.

**So the moral of the story is:** Make sure everything is in sync - schema, mappings and POCOs.
