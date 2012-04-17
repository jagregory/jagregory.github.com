---
layout: post
title: Behaviours in MSpec
tags:
- BDD
- MSpec
status: publish
type: post
published: true
meta:
  aktt_notify_twitter: 'no'
  _edit_last: '2'
  dsq_thread_id: '644651399'
---
<blockquote>Cross posted to <a href="http://www.lostechies.com/blogs/jagregory/archive/2010/01/18/behaviours-in-mspec.aspx">Los Techies</a></blockquote>

<p><a href="http://github.com/machine/machine.specifications">MSpec</a> is awesome, I think it's praised by myself and others enough for that particular point to not need any expansion; however, there is a particular feature I would like to highlight that hasn't really got a lot of press: behaviours.</p>

<p>Behaviours define reusable specs that encapsulate a particular set of, you guessed it, behaviours; you're then able to include these specs in any context that exhibits a particular behaviour.</p>

<p>Lets go with the cliche'd Vehicle example. Given an <code>IVehicle</code> interface, with <code>Car</code> and <code>Motorbike</code> implementations; these all expose a <code>StartEngine</code> method and some properties reflecting the state of the vehicle. We'll start the engine and verify that it is actually started, whether it's got anything on the rev counter, and whether it's killing our planet in the process (zing!).</p>

``` csharp
public interface IVehicle
{
  void StartEngine();
  bool IsEngineRunning { get; }
  bool IsPolluting { get; }
  int RevCount { get; }
}

public class Car : IVehicle
{
  public bool IsEngineRunning { get; private set; }
  
  public void StartEngine()
  {
    // use your imagination...
  }
}

public class Motorbike : IVehicle
{
  public bool IsEngineRunning { get; private set; }

  public void StartEngine()
  {
    // use your imagination...
  }
}
```

<p>Those are our classes, if rather contrived, but they'll do. Now what we need to do is write some specs for them.</p>

``` csharp
public class when_a_car_is_started
{
  Establish context = () =>
    vehicle = new Car();
  
  Because of = () =>
    vehicle.StartEngine();
  
  It should_have_a_running_engine = () =>
    vehicle.IsEngineRunning.ShouldBeTrue();
  
  It should_be_polluting_the_atmosphere = () =>
    vehicle.IsPolluting.ShouldBeTrue();
  
  It should_be_idling = () =>
    vehicle.RevCount.ShouldBeBetween(0, 1000);
  
  static Car vehicle;
}

public class when_a_motorbike_is_started
{
  Establish context = () =>
    vehicle = new Motorbike();
  
  Because of = () =>
    vehicle.StartEngine();
  
  It should_have_a_running_engine = () =>
    vehicle.IsEngineRunning.ShouldBeTrue();

  It should_have_a_running_engine = () =>
    vehicle.IsEngineRunning.ShouldBeTrue();

  It should_be_polluting_the_atmosphere = () =>
    vehicle.IsPolluting.ShouldBeTrue();

  It should_be_idling = () =>
    vehicle.RevCount.ShouldBeBetween(0, 1000);
  
  static Motorbike vehicle;
}
```

<p>Those are our specs, there's not much in there but already you can see that we've got duplication. Our two contexts contain identical specs, they're the same in what they're verifying, the only difference is the vehicle instance. This is where behaviours can come in handy.</p>

<p>With behaviours we can extract the specs and make them reusable. Lets do that.</p>

<p>Create a class for your behaviour and adorn it with the <code>Behaviors</code> attribute &mdash; this ensures MSpec recognises your class as a behaviour definition and not just any old class &mdash; then move your specs into it.</p>

``` csharp
[Behaviors]
public class VehicleThatHasBeenStartedBehaviors
{
  protected static IVehicle vehicle;
  
  It should_have_a_running_engine = () =>
    vehicle.IsEngineRunning.ShouldBeTrue();

  It should_have_a_running_engine = () =>
    vehicle.IsEngineRunning.ShouldBeTrue();

  It should_be_polluting_the_atmosphere = () =>
    vehicle.IsPolluting.ShouldBeTrue();

  It should_be_idling = () =>
    vehicle.RevCount.ShouldBeBetween(0, 1000);
}
```

<p>We've now got our specs in the behaviour, and have defined a field for the vehicle instance itself (it won't compile otherwise). This is our behaviour complete, it defines a set of specifications that verify that a particular behaviour.</p>

<p>Lets hook that behaviour into our contexts from before:</p>

``` csharp
public class when_a_car_is_started
{
  Establish context = () =>
    vehicle = new Car();
  
  Because of = () =>
    vehicle.StartEngine();
  
  Behaves_like<VehicleThatHasBeenStartedBehaviors> a_started_vehicle;
  
  protected static Car vehicle;
}

public class when_a_motorbike_is_started
{
  Establish context = () =>
    vehicle = new Motorbike();
  
  Because of = () =>
    vehicle.StartEngine();
  
  Behaves_like<VehicleThatHasBeenStartedBehaviors> a_started_vehicle;
  
  protected static Motorbike vehicle;
}
```

<p>We've now put to use the <code>Behaves_like</code> feature, which references our behaviour class and imports the specs into the current context. Now when you run your specs, the specs from our behaviour are imported and run in each context. We don't need to assign anything to that field, just defining it is enough; the name you choose for the field is what's used by MSpec as the description for what your class is behaving like. In our case this is translated roughly to <em>"when a motorbike is started it behaves like a started vehicle"</em>.</p>

<p>There are a couple of things you need to be aware of to get this to work: your fields must be <code>protected</code>, both in the behaviour and the contexts; and the fields must have identical names. If you don't get these two correct your behaviour won't be hooked up properly. It's also good to know that the fields <strong>do not</strong> need to have the same type, as long as the value from your context is assignable to the field in the behaviour then you're good; this is key to defining reusable specs for classes that share a sub-set of functionality.</p>

<p>In short, behaviours are an excellent way of creating reusable specs for shared functionality, without the need to create complex inheritance structures. It's not a feature you should use lightly, as it can greatly reduce the readability of your specs, but it is a good feature if you've got a budding spec explosion nightmare on your hands.</p>
