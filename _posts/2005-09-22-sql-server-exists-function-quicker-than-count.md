---
layout: post
title: ! 'SQL Server: Exists() function quicker than Count()'
tags:
- Code
- SQL
status: publish
type: post
published: true
meta: {}
---
You've seen the title; it's true.

I've been running an "administration" query to modify a table with around 190,000 records in. This table, segments, contains a status column called Coded. This value is derived from another table, faults. If any faults belonging to a segment has a coded status of 0 then the segment coded value is also 0.

My query did an update on each row in the segments table, retrieving a `count` of how many faults there are with a coded status of `0` that belong to the current segment. If the `count` is greater than `0` then the segment coded is set to `0`, otherwise to `1`.

It ran for over 2 hours without any sign of finishing.

I changed the query to do a simple case statement with an `exists` on the faults table where `Coded = 0` and it’s just finished in 4 minutes. Unbelievable.

<!-- more -->

### Update

I thought I should give a bit of an explanation as to why this is happening. It basically all boils down to the way the two functions operate that makes the biggest difference. A `count` statement counts every row that matches the where statement, so even if you only need to know about one record (like in my case) it’ll still read every other row too. On the other hand the `exists` function will return as soon as its conditions are met, so if the first row it finds matches it’ll only read one row.
