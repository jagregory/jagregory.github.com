---
layout: post
title: ! 'Getting with it: Test-Driven Development'
tags:
- Code
- TDD
status: publish
type: post
published: true
meta:
  dsq_thread_id: '644650525'
---
Test-driven development is a practice that has started to make some serious headway into the average developer world of .Net. The tools have reached a stage of maturity where they offer solutions to most (if not all) aspects of test-driven development. Alongside the improved tools there has been a dramatic increase in the quantity and quality of articles addressing the needs of new and established test-driven developers. The combined effect of this is of a reduced learning curve for the average developer.

On a personal note, test-driven development is something I should have started doing a long time ago, it's certainly something that I've known about long-enough to be unable to claim ignorance. I take no pride in saying that my sole reason for not learning sooner is laziness. I bet I'm not the only one though. There's a lot to learn, and not all of it is simply new tools, some of it is mental too; rewiring your brain isn't an easy task.

Having broke through the pain barrier, I can now vouch for the other side and say it really is nicer.

So how would I convince my-self from six months ago, that test-driven development is a worthwhile pursuit? Well after a bit of ear twisting about being lazy, I'd have to raise the point of security. I don't mean the "IM <span class="caps">IN UR HARD DRIVE</span>, STEALIN <span class="caps">UR FILEZ</span>" security, but the knowledge that you're the one who'll find bugs in your code, not the tester (or worse, the customer). A record of bugless (or bug-minimal) releases will bode well at your performance reviews. That, and nobody likes people finding problems in their code, so it's best you find them first.

That all sounds rather selfish and egotistical. What about the team, the flexibility, and the clean structured code-base? I'm a big advocate of a clean code-base, and a well oiled team can't be beat, but from experience, not everybody else feels the same way. Developers tend to respond more readily to two things: money, and fun. I'm generalising of course, but your average-joe developer isn't an altruist, he isn't going to go out of his way to help others. Give him the prospect of some extra cash, or even just the chance to break out of the mundane, and it's a whole different game.

This was the turning point for me, where test-driven development past the point of being a nice-to-have practice and entered the territory of being something that could benefit me in my daily life. I also discovered it's pretty fun too.

> Test-Driven Development = Security in code = Security in your job

*N.B. I shall not be held responsible for anyone who still proceeds to lose their job, even while practicing test-driven development.*

One last thing that I haven't mentioned. There's a feeling. A feeling of joy, a reassuring warmth. You get this feeling often when you're test-driven. Found a bug? Write a test. Test fails. Fix the bug. Test passes. You've fixed the bug; knowledge, safety, and security.

## Learning to drive

When learning how to test drive your development, it's important to know that you aren't specifically learning a new tool as many people have put it. Not in the same respect as learning a new <span class="caps">IDE</span> or source control system. Test-driven development isn't something physical. As I mentioned earlier, it requires you to rewire your programming brain. Although to successfully master test-driven development you are required to learn some physical tools (<a href="http://www.nunit.org/">NUnit</a> for example), the primary change will be a
mental one.

The most basic changes to your mental-model will be that your tests literally drive your code. You've probably heard it before, but you test first<sup><a href="#fn1">1</a></sup>.

What follows is a simple run-through of how you'd test-drive some simple development, and how changes to a system would be handled.

I'm going to try to keep the code as terse as possible, as to not complicate the theory with execution. There will be some boilerplate code that I will not include, such as setting up the fixtures. <a href="http://xprogramming.com">Ron Jeffries</a> provides a <a href="http://www.xprogramming.com/xpmag/acsUsingNUnit.htm">good introduction to NUnit</a> for .Net developers.

### The First Iteration

To set the scene: you're a developer building a system for a very small shop. They've been working primarily from spreadsheets, but feel they're ready to move on to a real system.

While other developers are creating the rest of the system, we're tasked with creating the method for retrieving the price for the products. As this is a very small outfit, we're only going to start with one product. Very small outfit.

We're told that the product we're going to be passed is an Apple, so following our mantra we're going to write our test first.

``` csharp
[Test]
public void ReturnsCorrectPriceForApples()
{
  Inventory inventory = new Inventory();

  Assert.AreEqual(0.5, inventory.GetPrice("Apple"), "One apple should cost 50p.");
}
```

You can see that we've now written our first test, unfortunately this test will not pass yet as we can't even compile.

Never fear, lets create the class.

``` csharp
class Inventory
{
  public double GetPrice(string product)
  {
    return 0;
  }
}
```

We've now created the class, so the code compiles and we're able to execute our first test.

It failed. This one of the key steps in test-driven development. Make a test, and make it fail, then write the functionality required to make the test pass. Baring that in mind, we'll now modify our code to allow the test to pass.

``` csharp
public double GetPrice(string product)
{
  return 0.5;
}
```

It passed, that's one test under our belt.


You'll notice that this isn't a very good design, but we've written enough code for the method to work for it's current usage. We're letting the tests drive our code, which means we're ending up with only the code we require. <span class="caps">YAGNI</span>: You Aren't Gonna Need It<sup><a href="#fn2">2</a></sup>.

### The Second Product

Our implementation of <code>GetPrice</code> is painfully simple, so simple that we don't even support multiple products. This worked fine for us while the customer only had one product, but they've now expanded and have requested their second product be added. Lets write another test to cover this new request.

``` csharp
[Test]
public void ReturnsCorrectPriceForSausages()
{
  Inventory inventory = new Inventory();

  Assert.AreEqual(2.99, inventory.GetPrice("Sausages"), "One pack of sausages should cost £2.99");
}
```

Once again, if we compile and run this test it will fail, because we've hard-coded the method to always return <code>£0.50</code>. So lets update the method to work for sausages too.

``` csharp
public double GetPrice(string product)
{
  if (product == "Apple")
    return 0.5;
  else
    return 2.99;
}
```

The test now passes.

Once again, this code isn't pretty, but it does the job. We could implement this in a much better way, but we don't have the time, there's always more urgent things that need doing. What's important in what we've just been doing is creating the tests, which serve as our safety net for when we eventually do decide to make this code nicer. We know that by re-running our tests, our code still works as it did originally.

### Refactoring

Fast forward a couple of months in our systems life. The customer now wants some more products adding, after all there's only so much you can do with apples and sausages. They've supplied us with a list of products, with their prices:

``` html
<table>
	<tr>
		<td><strong>Product</strong></td>
		<td><strong>Price</strong></td>
	</tr>
	<tr>
		<td>Potatoes</td>
		<td>3.99</td>
	</tr>
	<tr>
		<td>Cola</td>
		<td>1.27</td>
	</tr>
	<tr>
		<td>Bread</td>
		<td>0.99</td>
	</tr>
	<tr>
		<td>Milk</td>
		<td>0.47</td>
	</tr>
</table>
```

Looking at our code, we can easily see that this is going to get messy, fast. This is where we turn to refactoring our code.

> "Refactoring is the process of changing a software system in such a way that it does not alter the external behavior of the code yet improves its internal structure." &#8212;Martin Fowler

Test-driven development makes it easier for a developer to refactor, as the tests you create define a contract that the code must adhere to, any breaking of the contract is immediately noticeable.

Lets spend a small amount of time refactoring our current implementation to make it easier for future product additions.

``` csharp
class Inventory
{
  private Dictionary<string, double> products;

  public Inventory()
  {
    products = new Dictionary&lt;string, double&gt;();

    products["Apple"] = 0.5;
    products["Sausages"] = 2.99;
  }

  public double GetPrice(string product)
  {
    return products[product];
  }
}
```

We've now made the code a bit cleaner, and the design a little bit more flexible. If we now re-run our tests, we will see that everything still passes. We are safe in the knowledge that everything the customer requested previously still works. We're now safe to proceed with their new request, adding the new products. Thanks to our refactoring, this change is nice and easy. First things first, we need to create our tests to cover this requirement.

``` csharp
[Test]
public void ReturnsCorrectPricesForOtherProducts()
{
  Inventory inventory = new Inventory();

  Assert.AreEqual(3.99, inventory.GetPrice("Potatoes"), "Potatoes should be £3.99.");
  Assert.AreEqual(1.27, inventory.GetPrice("Cola"), "Cola should be £1.27.");
  Assert.AreEqual(0.99, inventory.GetPrice("Bread"), "Bread should be 99p.");
  Assert.AreEqual(0.47, inventory.GetPrice("Milk"), "Milk should be 47p.");
}
```

As should be realising by now, this test is going to fail. After running to confirm, we need to update our constructor to include the new products.

You may wonder why we bothered to run the test when we know that it was going to fail. Well it's a good practice to get into, because if you don't actually witness your test failing, you don't know for certain whether your test is actually correct. You might be testing the wrong thing. If your test passes when you expect it not to, you know there's something wrong; but if you don't catch it, your pass after your change won't mean anything.

``` csharp
public Inventory()
{
  products = new Dictionary<string, double>();

  products["Apple"] = 0.5;
  products["Sausuages"] = 2.99;
  products["Potatoes"] = 3.99;
  products["Cola"] = 1.27;
  products["Bread"] = 0.99;
  products["Milk"] = 0.47;
}
```

After making this change, our test will now pass. We've now successfully completed our customer's requirement, and our code has become a little bit more manageable in the process.

### Boundary Conditions

The customer is happy with our implementation of their requirements, even if we can see some places for improvement, and the release date is looming. The customer starts integrating their existing data into our system. After importing the list of products from a spreadsheet, the system is given a thorough run through.

The customer noticed that after importing the list of products, whenever anyone bought an apple, the system crashed. After some investigation, it ends up the spreadsheet with the products had apples in all lower-case, while our inventory has it stored with an upper-case letter a.

This exposes a flaw in our testing logic. We've currently just been testing how we expect the method to behave under normal usage, but not actually testing how it will act if we pass it things other than what it's expecting. Our tests should also be testing for invalid data and boundary conditions.

> **Boundary Condition:** A problem or situation that occurs only at a extreme (maximum or minimum) operating parameter.
> An example of a boundary condition would be supplying <code>1</code> and <code>12</code> to a <code>GetDaysInMonth</code> method.

> **Invalid Input:** Anything outside standard operating expectations.
> Using the same example as boundary conditions, invalid input would cover supplying <code>-6</code>, <code>0</code> and <code>76</code> to the <code>GetDaysInMonth</code> method.

We'll write a test to cover the invalid input the customer encountered, we'll pass in a valid product name, but one that's capitalised incorrectly.

``` csharp
[Test]
public void ReturnsCorrectProductPriceWhenPassedIncorrectCasedName()
{
  Inventory inventory = new Inventory();

  Assert.AreEqual(0.5, inventory.GetPrice("AppLE"), "Should return price of Apples, 50p.");
}
```

Running this test will fail, as usual. So lets fix the code to allow case-insensitive product names.

``` csharp
public Inventory()
{
  products = new Dictionary<string, double>();

  products["apple"] = 0.5;
  products["sausuages"] = 2.99;
  products["potatoes"] = 3.99;
  products["cola"] = 1.27;
  products["bread"] = 0.99;
  products["milk"] = 0.47;
}

public GetPrice(string product)
{
  return products[product.ToLower()];
}
```

We've modified our constructor to set the product names as lower-case, then modified our method to convert the inputted product name to lower-case as well. This way our searches are case-insensitive.

Running all our tests should assure us that our existing code still functions, and we're now safe from any case variations from the customer's product list.

While doing this change, it's noticeable that we're also not handling the case for if a price is requested for a product that isn't in the inventory. If this occurs we really should pass a message up to the <span class="caps">GUI</span>, so it can present the user with something.

Due to this being an exceptional situation, it's ideally suited to an exception! Let's write a test to handle this case.

``` csharp
[Test, ExpectedException(typeof(InvalidProductException))]
public void ThrowsAnExceptionForAnInvalidProduct()
{
  Inventory inventory = new Inventory();

  inventory.GetPrice("My Invalid Product");
}
```

We've introduced a new attribute to our test in this case, <code>ExpectedException</code>, this simply allows you to specify what exception you want a method to throw in the situation you're testing.

> **Note:** This test requires the use of a custom exception, I'm not going to show the implementation here as it's simple stuff. I've chosen to use a custom exception so our "GUI guys" know what to capture for this case.

> It's generally regarded as good practice to wrap your internal errors in something that's meaningful to the rest of the application, hiding the implementation details. An <code>InvalidProductException</code> is much easier to understand and implement than <code>NullReferenceException</code>, <code>IndexOutOfRangeException</code> etc. This is another topic in itself though.

To make this test pass, we need to update our <code>GetPrice</code> method to handle invalid products.

``` csharp
public double GetPrice(string product)
{
  if (!products.ContainsKey(product))
    throw new InvalidProductException("Product supplied, " + product +", is not in the inventory.");

  return products[product];
}
```

We're now doing a simple check to see if the internal product Dictionary contains an entry for the requested product, if it doesn't we'll throw one of our <code>InvalidProductException</code>'s.

Running our test again will now assure us that our method throws an exception in these circumstances.

We can now return to integration and the customer can be assured that it all works.

### Learning Conclusions

What have we witnessed in running through this little exercise?

<ol>
	<li><strong>How easy it is to test first</strong> &#8211; It's really not that complicated. Once you've learnt to apply the restraint needed to stop yourself from just diving in, it's easy.</li>
		<li><strong>The security you get from tests</strong> &#8211; If you've come from an environment that doesn't have any code tests, you're probably enjoying the reassurance that tests bring. You're at least safe in the knowledge that you haven't broken anything existing with your new features. The more tests you introduce, the more solid your base for making changes becomes.</li>
		<li><strong>Ease of refactoring</strong> &#8211; As with the above, it's easy to refactor your existing code when you've got a suite of tests in-place.</li>
		<li><strong>Light-weight nature of your code</strong> &#8211; When you're only coding to make your tests pass, you're less likely to code features that aren't required. This makes your code as light as possible.</li>
</ol>

## Dealing with Legacies

Lets be honest here, nobody likes legacy code. You know the kind of code I mean. The code written by the mysterious and elusive previous developers. Usually it's dire, sometimes it's shocking, most of the time it's untested.

Testing legacy code can be a nightmare in itself, but it is possible. What you need to remember in this situation is that you can't be a hero. There's no way you can create a test suite that covers the whole system, it's just not feasible.

Your best approach to testing legacy code is an incremental one. If you find a bug in the system, write a test that fails because of it, then fix the code and run your test. That way you have a test that covers that bug, and you're now safe from that bug showing up again. Eventually, if you continue this way, you'll end-up with a nice suite of tests covering your common bugs.

Often the system you're trying to test will be an unstructured mess, it'll be very hard to separate out logical concerns. It may be possible for you to utilise mock and stub objects<sup><a href="#fn3">3</a></sup> in these situations, which will help you break down the barriers. Sometimes even this isn't possible, and these may be the cases where you're either going to have to live with a few hundred lines of setup code for your tests, or live without automated testing, at least until you can rework the code to facilitate testing more readily.

Another form of legacy that you're no doubt going to encounter is that of the legacy mind. How you write code may have been turned on its head by the introduction of test-driven development, and you're going to slip back into your old ways every now and again. This happens to everyone at some point, but if you can force yourself to maintain your standards then you'll eventually break the barrier and you wont look back. If I code without unit tests now, I feel an overwhelming sense of insecurity and dirtiness. It's a good thing!

## Recommended Reading

<ul>
	<li><a href="http://c2.com/cgi/wiki?ExtremeProgrammingRoadmap">Extreme Programming Roadmap</a> Great resource, lots of discussion, including some from the greats.</li>
		<li><a href="http://www.martinfowler.com/">Martin Fowler</a> Lots of good articles.</li>
		<li><a href="http://codebetter.com/blogs/jeremy.miller">Jeremy Miller</a> Plenty of reading material, lots of insightful stuff. Rules of <span class="caps">TDD</span>: <a href="http://codebetter.com/blogs/jeremy.miller/archive/2005/10/20/133437.aspx">1</a>, <a href="http://codebetter.com/blogs/jeremy.miller/archive/2006/03/09/140465.aspx">2</a>, <a href="http://codebetter.com/blogs/jeremy.miller/archive/2006/05/30/145752.aspx">3</a>, <a href="http://codebetter.com/blogs/jeremy.miller/archive/2007/04/27/Jeremy_2700_s-Fourth-Law-of-Test-Driven-Development_3A00_-Keep-Your-Tail-Short.aspx">4</a></li>
		<li><a href="http://www.xprogramming.com/xpmag/acsUsingNUnit.htm">Adventures in C#: Using NUnit</a> Good introduction to using NUnit.</li>
		<li><cite><a href="http://www.amazon.co.uk/gp/product/0735619492?ie=UTF8&tag=jamegreg-21&linkCode=as2&camp=1634&creative=6738&creativeASIN=0735619492">Extreme Programming Adventures in C#</a></cite>, Ron Jeffries &#8211; Honest and friendly introduction to <span class="caps">TDD</span> and XP.</li>
		<li><cite><a href="http://www.amazon.co.uk/gp/product/0201485672?ie=UTF8&tag=jamegreg-21&linkCode=as2&camp=1634&creative=6738&creativeASIN=0201485672">Refactoring: Improving the Design of Existing Code</a></cite>, Martin Fowler &#8211; Refactoring bible.</li>
</ul>

## References

<p id="fn1"><sup>1</sup> <a href="http://www.extremeprogramming.org/rules/testfirst.html">Extreme Rules: Test First</a>, ExtremeProgramming.org</p>
<p id="fn2"><sup>2</sup> <a href="http://c2.com/xp/YouArentGonnaNeedIt.html">You Aren't Gonna Need It</a>, Extreme Programming Roadmap</p>
<p id="fn3"><sup>3</sup> <a href="http://martinfowler.com/articles/mocksArentStubs.html">Mocks Aren't Stubs</a>, Martin Fowler</p>