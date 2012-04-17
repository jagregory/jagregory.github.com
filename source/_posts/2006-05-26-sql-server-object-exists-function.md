---
layout: post
title: SQL Server Object Exists Function
tags:
- Code
- SQL
status: publish
type: post
published: true
meta:
  dsq_thread_id: '644650633'
---
> <strong>Update:</strong> Added separate versions for SQL Server 2000 and SQL Server 2005, due to the differences in the system objects tables.It may just be me, but when writing migration/create scripts for use with SQL Server I get quite agitated at having to write an ugly, long-winded, drop statement at the start of every object definition.

The support for dropping objects is one of the few things I would say MySQL has SQL Server over the barrel for.Baring in mind that if you try to drop an object that doesn’t exist, you’ll get an execution error; here’s how to drop a table in MySQL:

``` sql
DROP TABLE IF EXISTS customers
```

Here’s how to drop the same table, if you’re using SQL Server:

``` sql
IF EXISTS(SELECT 1 FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'customers') AND type = (N'U'))    DROP TABLE customers
```

As always, when something annoys you enough and you’re in the middle of something else, it’s about time you wrote that solution. So I’ve created a simple user-defined function that checks if an object exists then returns a <code>BIT 0</code> or <code>1</code> depending.

To use the function, all you have to do is call <code>dbo.ObjectExists</code> with two parameters, the first being the name of the object you want to check on, the second being the type of object.

``` sql
IF dbo.ObjectExists('customers', 'U') = 1
    DROP TABLE customers
```

<dl>
  <dt>Common Object Types:</dt>
  <dd><code>P</code> - Stored Procedure</dd>
  <dd><code>U</code> - User Table</dd>
  <dd><code>FN</code> - User-Defined Function</dd>
</dl>

Thanks to this little function, you can now almost match the simplicity of MySQL.

## ...and now the code

### SQL Server 2000

``` sql
CREATE FUNCTION dbo.ObjectExists(@Object VARCHAR(100), @Type VARCHAR(2)) RETURNS BIT
AS
BEGIN
  DECLARE @Exists BIT
  IF EXISTS(SELECT 1 FROM dbo.sysobjects WHERE [ID] = OBJECT_ID(@Object) AND type = (@Type))
    SET @Exists = 1
  ELSE
    SET @Exists = 0
  RETURN @Exists
END
```

### SQL Server 2005

``` sql
CREATE FUNCTION dbo.ObjectExists(@Object VARCHAR(100), @Type VARCHAR(2)) RETURNS BIT
AS
BEGIN
  DECLARE @Exists BIT
  IF EXISTS(SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(@Object) AND type = (@Type))
    SET @Exists = 1
  ELSE
    SET @Exists = 0
  RETURN @Exists
END
```