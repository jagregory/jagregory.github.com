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
I've updated the <code>ObjectField</code> to be considerably simpler than it was before. While writing my [Data-binding hierarchical objects](/writings/data-binding-hierarchical-objects/) post I wrote this about the <code>BoundField</code> implementation:

> Using a <code>TypeDescriptor</code> to get the property... This strikes me as a bit odd to be honest, because the <code>DataBinder</code> has the ability to evaluate a hierarchical path.

Which is interesting, because I was using a <code>TypeDescriptor</code> in my <code>ObjectField</code> implementation!

Originally, the <code>ObjectField</code> was using the method below to evaluate the hierarchical paths, which to be honest is a bit verbose.

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

The <code>GetNestedValue</code> method was splitting the <code>DataField</code> value and then recursively evaluating each property.

Here's the same implementation using the <code>DataBinder</code>:

``` csharp
// looking to bind against child-objects
object component = DataBinder.GetDataItem(controlContainer);
                
return DataBinder.Eval(component, DataField);
```

Magic!

As a side effect of this change, the <code>ObjectField</code> can now support everything regular data-binding does. So you can use indexers and such in your <code>DataField</code> now.

A couple of other things you should know: the <code>AllowNulls</code> property has been removed because it's no longer supported, and the <code>NullValue</code> field has also been removed because the <code>BoundField</code> already supported it in the form of <code>NullDisplayText</code>.

## Downloads

The ObjectField is open-source under the <a href="http://en.wikipedia.org/wiki/BSD_licenses">new BSD License</a>; read the license for what you’re allowed to do.

You can download the source here: <a href="http://jagregory.googlecode.com/files/ObjectField-1.1-source.zip">Download Source</a>.
You can download the latest binary here: <a href="http://jagregory.googlecode.com/files/ObjectField-1.1.zip">Download Binary</a>.

The source is also accessible from Subversion at: <a href="http://jagregory.googlecode.com/svn/trunk/ObjectField/">http://jagregory.googlecode.com/svn/trunk/ObjectField/</a> (using user jagregory-read-only)
