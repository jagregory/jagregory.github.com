---
layout: post
title: ObjectField - A GridView field
tags:
- .Net
- Code
- Hobby Projects
- NHibernate
status: publish
type: post
published: true
meta:
  dsq_thread_id: '644650895'
---
> The version of the ObjectField that this post refers to is now out of date. Please go to the [ObjectField 1.1](/writings/objectfield-11/) post for the latest version.

I encountered a problem while binding a complex object to a GridView, in that the BoundField doesn't support specifying a nested value in it's DataField property. So if you have a list of Customer's, and want to display the TelephoneNumber property from inside the customer's ContactDetails property, you're out of luck.

```xml
<asp:BoundField DataField="ContactDetails.TelephoneNumber" />
```

The above would fall over with an exception along the lines of:
`A field or property with the name 'ContactDetails.TelephoneNumber' was not found on the selected data source.`

<!-- more -->

This is a mind-boggling flaw in the BoundField, with the main solution being to create a nested GridView, which is just overkill for most situations. This problem especially rears it's ugly head if you're using an ORM layer such as [NHibernate](http://www.nhibernate.org/) or [SubSonic](http://www.subsonicproject.com).

So what have I done? I've just gone and created a solution to this problem.

Introducing the ObjectField, a GridView field that allows binding against hierarchical structured objects. In short, it takes a BoundField and splits it on full-stops (periods!) using each element to find an object.

```xml
<jag:ObjectField DataField="ContactDetails.TelephoneNumber" />
```

The above is now possible! Huzzah.

## Extras

There's one extra thing you should know about. The field has a couple of additional properties that can be useful.

The first is `AllowNulls` which defaults to `true`, this will make the field return silently when a null is encountered anywhere along the object hierarchy; this can be useful if you know that there might be a null somewhere along the lines.

The second property is `NullValue`, which is displayed by the field when `AllowNulls` is `true` and a null is encountered. Setting this value allows you to give a user-friendly message if a value is null.

## Downloads

The ObjectField is open-source under the [new BSD License](http://en.wikipedia.org/wiki/BSD_licenses); read the license for what you’re allowed to do.
