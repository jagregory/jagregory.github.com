---
layout: post
title: ! 'Futility: Transforming entities into DTOs'
tags:
- .Net
- Code
- Hobby Projects
status: publish
type: post
published: true
meta:
  aktt_tweeted: '1'
  dsq_thread_id: '644651129'
---
> Future James: This is pretty much describing [AutoMapper](http://automapper.codeplex.com/), just take a look at that instead.

I quite dislike mapping DTOs to entities, it's a pain, but mostly tedious and tiresome rather than difficult. I decided to try to ease things by creating a library that would resolve entity instances to their DTO counterparts.

My requirements were few but I was determined not to violate any of them.

  1. Refactoring friendly. No strings for property names, changing names should give compiler errors.
  2. Must simplify code.
  3. Must improve maintainability.

<!-- more -->

## First attempt: Explicit mapping

``` csharp
var mapper = new DtoMapper<Customer, CustomerDto>();

mapper.Pair(mapper.Entity.Name, mapper.Dto.CustomerName);
mapper.Pair(mapper.Entity.Address, mapper.Dto.CustomerAddress);

// ... elsewhere ...

CustomerDto dto = mapper.Transform(customer);
```

With a clever bit of DynamicProxy usage, this implementation successfully mapped properties on an entity to a DTO. I believed it was reasonably clear, but having to use mapper.Entity was a bit obtuse. Dealing with properties on instances without an instance is tricky, especially if you want to avoid using strings.

The explicit mapping is very refactoring friendly. I could rename a property without breaking the mapping, so requirement 1 was satisfied.

``` csharp
var dto = new CustomerDto();

dto.CustomerName = customer.Name;
dto.CustomerAddress = customer.Address;

return dto;
```

As the above code demonstrates, this implementation isn't actually any simpler than just doing simple assignments, it's in-fact more complicated because of the overhead of understanding what the mapper is. This simple assignment method is also refactoring friendly.

So with requirement 2 failed, and requirement 3 no different to doing it manually, it was time to move on.

## Second attempt: Implicit mapping

``` csharp
var mapper = new DtoMapper();

mapper.CreateImplicitMap<Customer, CustomerDto>();

// ... elsewhere ...

CustomerDto dto = mapper.Transform(customer);
```

This is my favourite implementation, it's clean and smart; however, it's also useless.

It did the same as the first example, but implicitly mapped any properties that have the same name together. This is fine, but it would ignore anything that don't have the same names. I could've implemented some logic for guessing names, but that would just be asking for trouble.

Tragically this implementation wasn't that refactoring friendly; you can rename properties, but it would silently stop mapping them unless you renamed it's partner too. That's pretty dangerous stuff. Requirement 1 failed.

It does produce less code than the first implementation, and the simple assignment method, so 2 and 3 are covered.

## Third attempt: Attributes

``` csharp
public class CustomerDto
{
  [DtoPartner(typeof(Customer), "Name")]
  public string CustomerName { get; set; }

  [DtoPartner(typeof(Customer), "Address")]
  public string CustomerAddress { get; set; }
}
```

I could live with this implementation, it's not as clean as the implicit method, but it is still quite clear.

Unfortunately, it fails in the refactoring test. You can't rename a property on Customer without it breaking the mapping, because the property names are strings. Requirement 1 failed.

You could smooth over this with an inspection unit test, which checks the strings against their types to see if the property exists, but that smells, it's not a very good library if you have to verify it even works. I could've also created a static class to represent the Customer instance properties, but that's more noise (you'd need 3 classes, instead of just 2); a pre-build step (ala SubSonic) came to mind, but that's entering into the realm of diminished returns.

## Conclusion?

Sometimes the obvious way is the best way. Old fashioned may be old, but that doesn't make it wrong. Sometimes a cigar is just a cigar.
