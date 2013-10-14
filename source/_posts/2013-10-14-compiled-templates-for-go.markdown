---
layout: post
title: Compiled Templates for Go
date: 2013-10-14 16:12
comments: true
tags:
- golang
type: post
published: true
---
[Cote](https://github.com/jagregory/cote) is a compiled templating language for [Go](http://golang.org).

<!-- more -->

Template languages fall roughly into two criteria: template specific language or the same language your system uses, and a custom markup language or they don't care. [Cote](https://github.com/jagregory/cote) falls into the second of both criteria, it uses pure Go for logic and the content can be anything. Your output can be anything text based.

<table>
  <thead>
    <tr>
      <th></th>
      <th>Custom code?</th>
      <th>Custom markup?</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>ERB</td>
      <td>No</td>
      <td>No</td>
    </tr>
    <tr>
      <td>HAML</td>
      <td>No</td>
      <td>Yes</td>
    </tr>
    <tr>
      <td>Jade</td>
      <td>No</td>
      <td>Yes</td>
    </tr>
    <tr>
      <td>Go html/template</td>
      <td>Yes</td>
      <td>No</td>
    </tr>
    <tr>
      <td>_.template</td>
      <td>No</td>
      <td>No</td>
    </tr>
    <tr>
      <td>Cote</td>
      <td>No</td>
      <td>No</td>
    </tr>
  </tbody>
</table>

Cote uses the same tokens as ERB and ASP.Net (and I imagine quite a few other languages), specificically `<%= %>` for any code which should write to the output stream and `<% %>` for code which doesn't. Inside a code block you can write any valid Go code, outside can be anything.

``` erb
<html>
  <head>
    <title><%= locals.Title %></title>
  </head>
  <body>
    <h1>Products</h1>
    <ul>
      <% for _, p := range locals.Products { %>
        <li><%= p.Name %></li>
      <% } %>
    </ul>
  </body>
</html>
```

As mentioned previously, Cote templates are compiled. A template is converted into pure Go and compiled into your package. No dependency on Cote is needed outside of your build pipeline. This adds some overhead to development (a template change requires a recompile), but it makes the impact on runtime as minimal as possible.

There's an executable (aptly named `cote`) which will take a template and spit out a Go function which can be called to render the template. Cote uses a very simplistic form of code generation to build your templates. It's really simple.

Given the above template, `cote` would produce a Go file roughly like:

``` go
package templates

func Products(locals ProductsLocals) []byte {
  // ... snip ...

  fmt.Fprint(w, "<html><head><title>")
  fmt.Fprint(w, locals.Title)
  fmt.Fprint(w, "</title></head><body><h1>Products</h1><ul>")

  for _, p := range locals.Products {
    fmt.Fprint(w, "<li>")
    fmt.Fprint(p.Name)
    fmt.Fprint("</li>")
  }

  fmt.Fprint("</ul></body></html>")

  // ... snip ...
}
```

Brute force. Ugly. Fast, very fast.

Each template produces a `[]byte` which can easily be written to your HTTP response.

``` go
import "templates"

func(w http.ResponseWriter, r *http.Request) {
  html := templates.Products(ProductsLocals{
    Title: "Products listing",
    Products: products,
  })

  w.Write(html)
}
```

To learn more about Cote, take a look at the README on Github: [https://github.com/jagregory/cote](https://github.com/jagregory/cote).