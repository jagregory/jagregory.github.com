---
layout: post
title: ObjectField 1.1
tags:
- .Net
- Code
- Hobby Projects
status: publish
type: post
published: true
meta:
  dsq_thread_id: '644650593'
---
I've updated the `ObjectField` to be considerably simpler than it was before. While writing my [Data-binding hierarchical objects](/writings/data-binding-hierarchical-objects/) post I wrote this about the `BoundField` implementation:

> Using a `TypeDescriptor` to get the property... This strikes me as a bit odd to be honest, because the `DataBinder` has the ability to evaluate a hierarchical path.

Which is interesting, because I was using a `TypeDescriptor` in my `ObjectField` implementation!

<!-- more -->

Originally, the `ObjectField` was using the method below to evaluate the hierarchical paths, which to be honest is a bit verbose.

``` csharp
private object GetNestedValue(object component, string field)
{
	string[] properties = field.Split('.');

	foreach (string property in properties)
	{
		PropertyDescriptor descriptor =
			TypeDescriptor.GetProperties(component).Find(property, true);

		if (descriptor == null && !AllowNulls)
		{
			// no descriptor, and we're not allowing nulls so complain that
			// we can't find the object
			throw new HttpException(string.Format(MissingFieldErrorMessage,
				property));
		}
		else if (descriptor == null)
		{
			// silently return, with the NullValue if present
			component = NullValue;
			break;
		}

		component = descriptor.GetValue(component);
	}

	return component;
}
```

The `GetNestedValue` method was splitting the `DataField` value and then recursively evaluating each property.

Here's the same implementation using the `DataBinder`:

``` csharp
// looking to bind against child-objects
object component = DataBinder.GetDataItem(controlContainer);

return DataBinder.Eval(component, DataField);
```

Magic!

As a side effect of this change, the `ObjectField` can now support everything regular data-binding does. So you can use indexers and such in your `DataField` now.

A couple of other things you should know: the `AllowNulls` property has been removed because it's no longer supported, and the `NullValue` field has also been removed because the `BoundField` already supported it in the form of `NullDisplayText`.

## Downloads

The ObjectField is open-source under the [new BSD License](http://en.wikipedia.org/wiki/BSD_licenses); read the license for what you’re allowed to do.

You can download the source here: [Download Source](http://jagregory.googlecode.com/files/ObjectField-1.1-source.zip).
You can download the latest binary here: [Download Binary](http://jagregory.googlecode.com/files/ObjectField-1.1.zip).

The source is also accessible from Subversion at: [http://jagregory.googlecode.com/svn/trunk/ObjectField/](http://jagregory.googlecode.com/svn/trunk/ObjectField/) (using user jagregory-read-only)
