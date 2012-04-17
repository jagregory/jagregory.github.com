---
layout: post
title: Data-binding hierarchical objects
tags:
- .Net
- Code
- Hobby Projects
status: publish
type: post
published: true
meta: {}
---
After my post about [my ObjectField column](/writings/objectfield/), I thought I'd elaborate a bit on why it's necessary.

When you're data binding against an object that isn't flat (i.e. has properties that are more than simple types - namely classes), you are bound to encounter the following exception, which is caused by the <code>BoundField</code> incorrectly handling a hierarchical object path.

```
A field or property with the name 'MySubObject.PropertyName' was not found on the selected data source.
```

Take this following Customer object for example:

``` csharp
public class Customer
{
	...
	
	public ContactDetails ContactDetails
	{
		get { return contactDetails; }
	}
}

public class ContactDetails
{
	...
	
	public string TelephoneNumber
	{
		get { return telephoneNumber; }
	}
}
```

If you were to just use <code>DataField="ContactDetails"</code> on a <code>BoundField</code>, it would work fine because it's binding against a property on your customer. However,  if you were to try to get the <code>TelephoneNumber</code> property of the <code>ContactDetails</code> by doing: <code>DataField="ContactDetails.TelephoneNumber"</code>, it would fail because the field can't interpret the two property names; it treats the <code>DataField</code> as one big name, which obviously isn't correct.

The <code>BoundField</code> simply isn't capable of resolving this kind of hierarchical path using late-binding. This is because it uses the DataField as the literal property name on the component, using a TypeDescriptor to get the property.

``` csharp
TypeDescriptor.GetProperties(component).Find(dataField, true);
```

This strikes me as a bit odd to be honest, because the <code>DataBinder</code> has the ability to evaluate a hierarchical path. It's pure speculation, but if this is a conscious decision it may be down to the performance implications of using late binding; however, I can't see that it's any worse than reflection.

Unfortunately there isn't a solution to this if you still want to use the <code>BoundField</code>. If you don't mind a bit of untidy mark-up, you can do this instead:

``` aspx-cs
<asp:TemplateField>
  <ItemTemplate>
    <%# Eval("ContactDetails.TelephoneNumber") %>
  </ItemTemplate>
</asp:TemplateField>
```

This is pretty messy though, and you're going to quadruple the markup for your columns; imagine having 10 of those, it's going to get pretty ugly. My solution is to use the [ObjectField I wrote about previously](/writings/objectfield/), which is a column that derives from <code>BoundField</code> and overrides it's binding mechanism, allowing it to correctly evaluate hierarchical paths.

The <code>ObjectField</code> allows you to use the familiar markup from the <code>BoundField</code>:

``` aspx-cs
<jag:ObjectField BoundField="ContactDetails.TelephoneNumber" />
```

Hopefully one of those solutions will suit you. Personally I'd prefer to see the <code>ObjectField</code>, or other derived field, instead of the nasty <code>TemplateField</code> usage.

*This is a follow up to my ObjectField post, because a few people have been hitting that page in search of the exception, which it doesn't really cover.*