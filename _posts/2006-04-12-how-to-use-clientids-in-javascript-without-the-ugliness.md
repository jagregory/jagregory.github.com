---
layout: post
title: How-to use ClientIDs in JavaScript without the ugliness
tags:
- .Net
- Code
- JavaScript
status: publish
type: post
published: true
---
ASP.Net has an interesting way of handing the potential ID conflicts caused by embedding third-party controls within your web-page; it prefixes any sub-controls with their parent's ID.

`<asp:TextBox ID="txtUsername" Runat="server" />` within a standard page simply has an ID of `txtUsername` within the HTML output. On the other hand, the following example would result in something along the lines of `_parent_txtUsername` as the ID:

``` html
<div id="parent" runat="server">
  <asp:TextBox ID="txtUsername" Runat="server" />
</div>
```

This isn't really much of a problem when all you are working with is server-side code, but when you start tinkering with JavaScript, things become quite annoying and get an overall feeling of hackiness.

<!-- more -->

One solution, which I have used time-and-again, is to use a script block at the end of your page where you create a series of variables that contain the actual IDs. You then use these variables to reach the actual elements via JavaScript.

``` html
<script type="text/javascript">
  var txtUsernameID = '<%= txtUsername.ClientID %>';
  var txtPasswordID = '<%= txtPassword.ClientID %>';
</script>
```

This solution works fine, but it isn't exactly pretty and it doesn't weigh well on my conscience.

## Javascript Mapping

I've created a simple class that traverses the control structure and outputs an object that contains the mappings, as above, but without any client-side intervention; not a `<%= ...ClientID %>` in sight.

An example of the output would be:

``` js
var ClientIDs = {
  txtUsername = 'ctrl0_txtUsername',
  txtPassword = 'ctrl0_txtPassword'
};
```

Which enables you to reference elements, that you know are server-controls, by calling `ClientIDs.txtUsername`.

### Before:
``` html
<script type="text/javascript">
  var txtUsernameID = '<%= txtUsername.ClientID %>';
  var txtPasswordID = '<%= txtPassword.ClientID %>';

  function validate() {
    var username = $(txtUsernameID).value;
    var password = $(txtPasswordID).value;

    if (username == 'james') {
      alert("you shouldn't be here!");
    }
  }
</script>
```

### After:

``` html
<script type="text/javascript">
  function validate() {
    var username = $(ClientIDs.txtUsername).value;
    var password = $(ClientIDs.txtPassword).value;

    if (username == 'james') {
      alert("you shouldn't be here!");
    }
  }
</script>
```

## ServerControlIDs class

### Methods

`void Emit(page)` - Builds the controls of the page into a mapped structure, registering a client-side script block for the output.

`void Emit(control, literal)` - Builds the controls of the control into a mapped structure, rendering the output into the literal control supplied. The literal is best suited to being placed into the `<head>` tag, which helps improve the semantic nature of your page.

### Properties

`bool Whitespace` - Sets whether the output should contain whitespace, provided only for “prettifying” your code; defaults to off.

`string VariableName` - Sets the JavaScript variable name used; defaults to ClientID.

### Usage

To use this class, simply create an instance in the PreRender event for your page — this ensures that all the controls have been set to their correct state — then call the Emit method you desire.

## History

  * [1.1] Removed IDs from Repeater/DataGrid contained controls.
  * [1.0] Initial release

## Download

> Future James: This is all gone folks. Left here for curiosity.
