---
layout: post
title: Nested DataGrid/Repeater with Key Value access
tags:
- .Net
- Code
status: publish
type: post
published: true
meta: {}
---
One of my colleagues was having a problem with a datagrid nested in a repeater. We’ve done this kind of thing before with no problems, but this time the dataset wasn’t allowing key access to columns (i.e <code>Container.DataItem("ID")</code>). We toiled for quite some time trying to figure out why, with no avail. Eventually we just ended up using the direct index of the column; which worked fine as long as we didn’t change the column ordering.

``` aspx-vb
<asp:Repeater id="rptLogins" Runat="server">
  <ItemTemplate>
    <%# DataBinder.Eval(Container, "DataItem.Password") %>

    <asp:DataGrid id="dgUsageDetail" Runat="server" DataSource='%# Container.DataItem.Row.GetChildRows("myRelation") %>' AutoGenerateColumns="false">
      <Columns>
        <asp:TemplateColumn HeaderText="Date">
          <ItemTemplate><%# DataBinder.Eval(Container, "DataItem(1)", "{0:dd/MM/yyyy}") %></ItemTemplate>
        </asp:TemplateColumn>
        <asp:TemplateColumn HeaderText="Time">
          <ItemTemplate><%# DataBinder.Eval(Container, "DataItem(1)", "{0:T}") %></ItemTemplate>
        </asp:TemplateColumn>
        <asp:TemplateColumn HeaderText="Page Visited">
          <ItemTemplate><%# Container.DataItem(2) %></ItemTemplate>
        </asp:TemplateColumn>
      </Columns>
    </asp:DataGrid>
  </ItemTemplate>
</asp:Repeater>
```

I was never happy with this solution, for the above reason. In my opinion if you’re referencing columns you should never, ever reference them by index because it’s making your code reliant on the physical structure of the database. Something you may not have any control over what-so-ever.

Anyway, just now I was working on my own little project (…on my lunch) and I needed to do the same thing; perfect time for some investigation. If you look at the DataSource of the above nested datagrid you’ll see it’s bound to the current rows <code>GetChildRows</code> method, ends up (fairly obviously in hind sight) this returns a simple 1-dimensional array of DataRow objects. These DataRow objects (to my knowledge) basically contain an internal array of values, these values map to their parents <code>Columns</code> collection. There’s no reference to the actual name of the column, hence why the key access doesn’t work.

The solution is quite simple. So simple it’s unbelievable… Replace <code>Row.GetChildRows("myRelation")</code> with <code>Row.CreateChildView("myRelation")</code>. This creates a DataView object of the child rows, so essentially it’s a mini-dataset for you to deal with as if it were standard. Keyed referencing is back in action!

> Note: For those that are wondering, a dataview isn’t actually a mini-dataset but a filtered view of its parent dataset.
