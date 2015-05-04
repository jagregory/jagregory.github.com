---
layout: post
title: Preventing debugger property evaluation for side-effect laden properties
tags:
- .Net
- debugger
- fluent interface
status: publish
type: post
published: true
meta:
  aktt_notify_twitter: 'no'
  _edit_last: '2'
  dsq_thread_id: '644651390'
---
<p>Property getters with side-effects, now there's a controversial subject if ever I saw one. Don't do it is the rule; as with any rule though, there's generally an exception that proves it. If you're in this situation and you genuinely do have a scenario that requires a property getter to have side-effects, then there's a side-effect (ha!) that you should be aware of.</p>

<p><strong>The debugger evaluates property getters when showing it's locals and autos windows.</strong> While this feature is indispensable in most cases, it plays havoc with our property-with-side-effects. What the debugger does is call the getter to present it's value in the autos window, at the same time firing our code that has a side-effect. From there you have pretty confusing behavior with code seemingly running itself.</p>

<p>My exception to the rule is mutator properties in a fluent interface. You can often find properties in fluent interfaces that when touched alter the behavior of the next method called.</p>

<p>For example:</p>

``` csharp
string value = null;

Is.Null(value)      // returns true
Is.Not.Null(value)  // returns false
```

<p>The Is class would contain a value tracking whether the next call would be inverted or not, and the Not property would flip that value when called.</p>

<p>Now assume this, you're using <code>Is.Null(value)</code> and you set a breakpoint on it. Your autos window has expanded Is and shows the Not property, what's just happened? The debugger has now called Not and altered your state! Undesirable.</p>

<p><a href="http://msdn.microsoft.com/en-us/library/system.diagnostics.debuggerbrowsableattribute.aspx">DebuggerBrowsable attribute</a> to the rescue; this attribute when used with the DebuggerBrowsableState.Never parameter instructs Visual Studio to never inspect the property you apply it to. Your property won't appear in the autos or locals window, and if you expand the tree of an instance containing the property it will show up with a Browsing Disabled message; you can then force it to evaluate the property, but at least it doesn't do it automatically.</p>

``` csharp
private bool inverted = true;

[DebuggerBrowsable(DebuggerBrowsableState.Never)]
public Is Not
{
  get
  {
    inverted = !inverted;
    return this;
  }
}
```

<p>Sticking the DebuggerBrowsable attribute on your Not property prevents the debugger from hitting it and inverting the switch.</p>

<p>So there you go, if your property-with-side-effects is being invoked by the debugger, you can use the DebuggerBrowsableAttribute to prevent it.</p>

<blockquote>By the way, I'm not advocating properties with side-effects...</blockquote>
