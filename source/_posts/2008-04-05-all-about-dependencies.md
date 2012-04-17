---
layout: post
title: All about dependencies
tags:
- .Net
- Alt.Net
- Code
- Opinion
- TDD
status: publish
type: post
published: true
meta:
  aktt_tweeted: '1'
---
> This article serves as an introduction to the concept of <a href="http://martinfowler.com/articles/injection.html">Dependency Injection</a>, and why you'd want to use it. It is not a getting started guide for using containers. If you're interested in those, my personal preference is <a href="http://www.castleproject.org/container/">Castle Windsor</a> and you can find their <a href="http://www.castleproject.org/container/gettingstarted/index.html">getting started guide here</a>.

What are dependencies? Also referred to as couplings, dependencies are other modules that one module requires to fulfil it's purpose.

Are dependencies bad? No, of course they're not, otherwise we wouldn't be able to create anything. However, highly coupled code can cause a lot of problems for your application.

If your code requires knowledge of how a dependency works, then your code is highly coupled. If your code is tied explicitly to an implementation, then your code is also highly coupled.

Take the following example:

``` csharp
public class ProductUpdater
{
	public void StoreChanges(Product product)
	{
	  SqlDataStore dataStore = new SqlDataStore();

	  dataStore.CreateConnection();
	  dataStore.OpenConnection();

	  dataStore.Update(product);

	  dataStore.CloseConnection();
	}
}
```

The above example is highly coupled to the <code>SqlDataStore</code>. Firstly, it directly creates an instance, which means there's no way for us to replace that instance if we need to (I'll come to why you'd want to do that in a bit). Secondly, it relies on a great deal of knowledge of <code>SqlDataStore</code>'s implementation. In this code we can see that you need to create a connection and open it before you can update the record; that's quite a bit of implementation knowledge. If the <code>SqlDataStore</code> was to change so that the <code>OpenConnection</code> method created a connection if one didn't already exist, then we'd need to change every caller of  that code to remove the <code>CreateConnection</code> call; in large system situations like that can quickly lead to a fear of change and refactoring.

I mentioned directly creating an instance stops us from replacing it if need be.  Well when would you actually want to do this? For those unfamiliar with unit testing, you probably haven't encountered <a href="http://www.martinfowler.com/bliki/TestDouble.html">test doubles</a>; there are different types of test doubles, but for the purposes of this example they're interchangeable.

A test double serves as a swap-in replacement for one of your dependencies. These allow you to execute a piece of code under test, without having to worry about whether things are being put in your database, or e-mails sent for example. If your code is creating instances within methods, those instances cannot be replaced by a test double. Without that ability, testing becomes considerably more difficult.

Tightly tying your code to an instance of a class reduces the flexibility and reuse of your code. Take the above example, that same code could be used to update the product in a cache instead of the database; similarly, you could use an in-memory storage instead of a database for when you're running in a test or demo environment. If only your method wasn't so tightly tied to the implementation.

This is solved by using <a href="http://martinfowler.com/articles/injection.html">Dependency Injection</a>, which is a part of the <a href="http://en.wikipedia.org/wiki/Dependency_inversion_principle"Dependency Inversion Principal</a> and <a href="http://en.wikipedia.org/wiki/Inversion_of_Control">Inversion of Control</a>.

> [DIP] seeks to "invert" the conventional notion that high level modules in software should depend upon the lower level modules. The principle states that high level or low level modules should not depend upon each other, instead they should depend upon abstractions. -- Wikipedia

Essentially, dependency injection allows you to stop instantiating your dependencies. Instead they're "injected" into your object when it is instantiated itself. This allows the dependencies to be swapped out like we mentioned above.

So taking the original example, here's a version of it that's been updated to use dependency injection.

``` csharp
public class ProductUpdater
{
	private SqlDataStore dataStore;
	
	public ProductUpdater(SqlDataStore dataStore)
	{
		this.dataStore = dataStore;
	}
	
	public void StoreChanges(Product product)
	{
	  dataStore.CreateConnection();
	  dataStore.OpenConnection();

	  dataStore.Update(product);

	  dataStore.CloseConnection();
	}
}
```

The above implementation now allows us to create a test double, and replace the <code>SqlDataStore</code> in our tests. As I mentioned before, we could now easily push in an in-memory implementation without any changes to the code required.

We can take this further though, because we're still tied to a concrete class. Lets make <code>SqlDataStore</code> implement an interface, so we can create other implementations.

``` csharp
public interface IDataStore
{
	void CreateConnection();
	void OpenConnection();
	void Update(Product product);
	void CloseConnection();
}

public class ProductUpdater
{
	private IDataStore dataStore;
	
	public ProductUpdater(IDataStore dataStore)
	{
		this.dataStore = dataStore;
	}
	
	public void StoreChanges(Product product)
	{
	  dataStore.CreateConnection();
	  dataStore.OpenConnection();

	  dataStore.Update(product);

	  dataStore.CloseConnection();
	}
}
```

Now our example is no longer specifically tied to a <code>SqlDataStore</code>, so we could quite easily pass it a <code>FileSystemDataStore</code>, or an <code>InMemoryDataStore</code>, or anything else that implements <code>IDataStore</code>. All that without having to touch a single line within the <code>ProductUpdater</code>.

That's the power of dependency injection, and why you should stop hard-coding your dependencies.
