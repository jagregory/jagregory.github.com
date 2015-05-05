---
layout: post
title: Introducing the filterable DeleGrid
tags:
- .Net
- Code
- Hobby Projects
- NHibernate
status: publish
type: post
published: true
meta:
  dsq_thread_id: '644650995'
---
The DeleGrid is a paged GridView control that handles data-binding through the use of events and delegates rather than with a traditional collection.

What this means is that you have full control over the data that is shown in the currently displayed page. Traditionally you'd retrieve the whole recordset then page it locally, but with the DeleGrid you can utilise your database/ORMs paging features.

<!-- more -->

To quote myself from when I first [introduced the DeleGrid](/writings/delegrid/):

> [The DeleGrid] came about because I wanted a nice way of implementing paging using NHibernate without having the grid know about it. I really didn’t want NHibernate to leave my data layer, so I needed a nice way of the grid calling my DAL with the paging parameters.

## What's new?

The biggest change in version 1.1 is the introduction of filtering. The filter isn't generated in some black-box fashion, instead it's defined by the programmer. It's built up from the columns in the grid, which define their own filtering behaviour.

The filter acts upon any columns in the grid that implement the IFilterableField interface. Implementing this interface in your own fields is easy, so you're quickly able to create custom filtering behavior for your grid. An example would be a date column, that has a date-picker as a filter control.

![Filter Screenshot](/images/fd-1.png)

I've chosen not to implement the wealth of appearance customisations that are available in the normal templated controls. This is down to two reasons, firstly I don't agree with it, appearance should be controlled solely through CSS. Secondly, there are so many, I couldn't be bothered. So you're only able to attach CSS classes to the buttons and cells, and specify the image urls for the buttons.

## An example implementation

The grid now has a companion project, it's own data library. This separation is to keep you from having to reference System.Web in your data-layer. To use the DeleGrid in your project you'll need to reference `JAGregory.Controls.DeleGrid.dll` and the `JAGregory.Controls.Data.dll` in your web project, then reference `JAGregory.Controls.Data.dll` in your data layer, if they're separate projects.

So to begin with, add the reference to `JAGregory.Controls.DeleGrid.dll` and `JAGregory.Controls.Data.dll` into your web project. This will allow you to use the DeleGrid in your page. Once you've done that, you'll need to reference the control in your page, you can either do this using a Register tag in your page, or in the web.config as so:

``` xml
<pages>
  <controls>
    <add tagPrefix="jag" namespace="JAGregory.Controls"
      assembly="JAGregory.Controls.DeleGrid" />
  </controls>
</pages>
```

With that in place, you can now put the DeleGrid into your page:

``` aspx-cs
<jag:DeleGrid ID="grid" Runat="server" AllowFiltering="true"
  AutoGenerateColumns="false">
    <FilterStyle ToggleOnImageUrl="img/find.png" ToggleOffImageUrl="img/find.png"
      ExecuteImageUrl="img/go.png" />
    <Columns>
        <jag:FilterableTextField HeaderText="Name" DataField="Name" />
        <jag:FilterableBooleanField HeaderText="Active" DataField="Active" />
    </Columns>
</jag:DeleGrid>
```

In this example I'm using a Customer object to bind against it, which simply has the Name and Active properties.

For this grid we've set AllowFiltering to true, which enables the filter, then we've set AutoGenerateColumns to false so we can add our own custom columns. The two columns both implement the aforementioned IFilterableField interface, which allows them to define their own filtering behaviour.

I've also set the image urls so the buttons will be visible.

Now that the page is set up, we need to get down to the binding. In your code-behind:

``` csharp
protected override void OnInit(EventArgs e)
{
  base.OnInit(e);

  // attach the events for requesting the data and totals
  grid.TotalRecordCountRequest += grid_TotalRecordCountRequest;
  grid.PageDataRequest += grid_PageDataRequest;
}

protected override void OnLoad(EventArgs e)
{
  base.OnLoad(e);

  if (!IsPostBack)
    grid.DataBind();
}
```

What've just done is attach the TotalRecordCountRequest and PageDataRequest handlers to the grid, which respectively fetch the total record count for the full grid, and fetch the current page of data from the database; the implementations are below.

``` csharp
private IEnumerable grid_PageDataRequest(object sender, PageDataRequestEventArgs e)
{
  CustomerRepository repos = new CustomerRepository();

  // get the requested page of data from the database
  return repos.FindAllPaged(e.Range, e.Sort, e.Filters);
}

private int grid_TotalRecordCountRequest(object sender, DataRequestEventArgs e)
{
  CustomerRepository repos = new CustomerRepository();

  // get the total records
  return repos.GetAllCount(e.Filters);
}
```

I'm using a [repository pattern](http://www.martinfowler.com/eaaCatalog/repository.html) to handle data-access. In the PageDataRequest handler we're taking the range, sort, and filter info that the grid passed us and sending it off to the repository to get the data. Similarity the TotalRecordCountRequest handler does a similar thing but without the range or sort info.

That's it really for using the DeleGrid, you just need to take the filter info and handle it using your specific ORM.

## Repository implementation

Ok I'll throw you a bone, here's the repository implementation to show how easy it is using NHibernate:

``` csharp
public class CustomerRepository
{
  /// <summary>
  /// Creates a NHibernate ICriteria based on the filters.
  /// </summary>
  /// <param name="filters">Filters to apply.</param>
  /// <returns>ICriteria</returns>
  private ICriteria CreateFilteredCriteria(FilterCriterionCollection filters)
  {
    ICriteria criteria = SessionManager.CurrentSession
      .CreateCriteria(typeof(Customer));

    // criterion handling - write this yourself depending on how your
    // db filters (and what filter types you're supporting)
    foreach (FilterCriterion filter in filters)
    {
      if (filter.Type == typeof(string))
        criteria.Add(Expression.Like(filter.FieldName, "%" + filter.Value + "%"));
      else if (filter.Type == typeof(bool))
        criteria.Add(Expression.Eq(filter.FieldName, filter.Value));
    }

    return criteria;
  }

  /// <summary>
  /// Gets the total record count from the database using the filters.
  /// </summary>
  /// <param name="filters">Filters to apply before getting the count.</param>
  /// <returns>Total number of records in the filtered list</returns>
  public int GetAllCount(FilterCriterionCollection filters)
  {
    return CreateFilteredCriteria(filters)
      .SetProjection(Projections.Count("ID"))
      .UniqueResult<int>();
  }

  /// <summary>
  /// Gets one page of data from the database.
  /// </summary>
  /// <param name="range">Select range (start ID and number of records).</param>
  /// <param name="sort">Sorting to apply.</param>
  /// <param name="filters">Filters to apply.</param>
  /// <returns>List for one page of data.</returns>
  public IList<Customer> FindAllPaged(SelectRange range, SortInfo sort, FilterCriterionCollection filters)
  {
    // create the criteria using the filters, then set the range
    ICriteria criteria = CreateFilteredCriteria(filters)
      .SetFirstResult(range.Start)
      .SetMaxResults(range.Size);

    // only add the sort if one is specified
    if (!string.IsNullOrEmpty(sort.Field))
    {
      if (sort.Direction == Direction.Asc)
        criteria.AddOrder(Order.Asc(sort.Field));
      else
        criteria.AddOrder(Order.Desc(sort.Field));
    }

    return criteria.List<Customer>();
  }
}
```

The <code>CreateFilteredCriteria</code> method is doing most of the leg work. It takes creates an NHibernate criteria, then adds any filter criterions to it. It iterates the filters collection, checking their type and adding the appropriate NHibernate criterion. Simple!

## The example project

I've attached a sample project that uses the grid to display a collection of customers that are paged and filtered. The example uses a SQLite database with NHibernate for data-access, I've done this to keep the extraneous code to a minimum.

## Downloads

The DeleGrid is open-source under the [new BSD License](http://en.wikipedia.org/wiki/BSD_license); read the license for what you’re allowed to do.

You can download the source here: [Download Source](http://jagregory.googlecode.com/files/DeleGrid-1.1-source.zip).
You can download the latest binary here: [Download Binary](http://jagregory.googlecode.com/files/DeleGrid-1.1.zip).
You can download the example project here: [Download Example](http://jagregory.googlecode.com/files/DeleGridExample.zip).

The source is also accessible from Subversion at: [http://jagregory.googlecode.com/svn/trunk/DeleGrid/](http://jagregory.googlecode.com/svn/trunk/DeleGrid/) (using user jagregory-read-only)
