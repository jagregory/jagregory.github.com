---
layout: post
title: Freeing the model from its evil web-service oppressors
tags:
- .Net
- Code
- Work
status: publish
type: post
published: true
meta:
  aktt_tweeted: '1'
---
The current system I'm working with has a setup whereby the model (data access objects) are being used by the web-services for delivery; this means that the consumers of the web-services are directly tied to our inner implementation of our data access code. On-top of that, it's old full of bad conventions, and is in need of refactoring.

This is my account of how I freed the model from the web-service.

``` csharp
public class vehicle_info
{
    public int vehicle_id;
    public string vehicle_name;
    public string vehicle_manufacturer;
    public DateTime vehicle_manufactured_date;
    public int vehicle_number_produced;
}
```

That's the existing model. You can see that these have some nasty naming conventions that I just can't live with anymore.

A large problem with pushing your model out to the web-service consumers is that I can't refactor the classes without breaking their implementations; if I rename a field in my model, the consumers will have to update their code to deal with it. This is an issue because not all the consumers are able to update their code. So we're stuck with how the classes were built years ago, with awful naming conventions, and no ability to change.

What's the ideal setup then? It's my opinion that we should be using specialised DTOs (Data Transfer Objects) for this purpose, they'll exist solely to be the transport mechanism for the web-service. With DTOs you're separating what your service pushes out from what you use internally, which allows you to refactor your internal design without any problems with integration.

``` csharp
public class VehicleWebServiceDto
{
    public int vehicle_id;
    public string vehicle_name;
    public string vehicle_manufacturer;
    public DateTime vehicle_manufactured_date;
    public int vehicle_number_produced;
}
```

There's an issue with using DTOs in an existing web-service environment, it's unlikely your DTOs will be named the same as your original objects (if they do, you're fine). We can't just swap it out with a DTO, because the signatures won't match in the WSDL.

When we change the web-service to return those DTOs instead of the original classes, we end up with this mismatch in the output:

``` xml
<vehicle_info>
  <vehicle_id>int</vehicle_id>
  <vehicle_name>string</vehicle_name>
	...

<VehicleWebServiceDto>
  <vehicle_id>int</vehicle_id>
  <vehicle_name>string</vehicle_name>
	...
```

How can we get around this? Make the signatures match.

You can control the way objects are serialized by the web-service through the serialization attributes; namely the <code>XmlRoot</code> and <code>SoapType</code> attributes are the ones you're looking for, these allow you to override what name is output in the xml for your class. Slap on those attributes, one for the standard HTTP usage and the other for SOAP, and give them your old class name; then as far as the consumers of the webservice can see, you're giving them the same old classes. Now you have a separate DTO from your domain layer, but without breaking the schema.

These are the updated DTO objects:

``` csharp
[XmlRoot("vehicle_info"), SoapType("vehicle_info")]
public class VehicleWebServiceDto
{
    public int vehicle_id;
    public string vehicle_name;
    public string vehicle_manufacturer;
    public DateTime vehicle_manufactured_date;
    public int vehicle_number_produced;
}
```

Which now produce this xml:

``` xml
<vehicle_info>
  <vehicle_id>int</vehicle_id>
  <vehicle_name>string</vehicle_name>
	...
```

We are now free to refactor our code as much as we like, without affecting the output of the web-service.

``` csharp
public class Vehicle
{
    public int ID { get; set; }
    public string Name { get; set; }
    public ManufacturingDetails ManufacturingDetails { get; set; }
}

public class ManufacturingDetails
{
    public Manufacturer Manufacturer { get; set; }
    public DateTime ManufacturedDate { get; set; }
    public int NumberProduced { get; set; }
}

public class Manufacturer
{
    public int ID { get; set; }
    public string Name { get; set; }
}
```

Magic.