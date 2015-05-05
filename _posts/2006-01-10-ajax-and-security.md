---
layout: post
title: AJAX and Security
tags:
- AJAX
- Security
status: publish
type: post
published: true
meta: {}
---
I've been creating a content management system over the past few weeks with all the bells and whistles you'd expect from a new web project. One thing that has caught my eye is the potential security risk when using AJAX.

For said project I've been using the [Ajax.Net library](http://ajax.schwarz-interactive.de/csharpsample/default.aspx) which, like most others, outputs wrapped calls to a server-side functions in javascript.

<!-- more -->

With that in mind then, surely anyone can open up the rendered source, see your methods and then execute them at will, potentially causing havoc. Initially I was using Ajax for most of my interaction with the server - something which seems pointless in hindsight. This meant that I had a create user function exposed to the public, potentially anyone could create themselves an account within the system by using the Javascript. This isn't much of a problem from within the context of this project, because you can only ever view the page with the javascript when you're authorised to create users; so it doesn't make any difference. If this was public though, it could be a serious security risk. An example could be a comment form on a blog post, if you expose the method of creating a new comment through javascript then someone, with a little bit of work, could use the javascript to post automated comments.

Once again, nothing major but I think it is definitely something you should bare in mind when creating your pages. I guess the moral of this little story is don't use Ajax for the sake of it and if you do use it make sure that the functions you are calling are harmless. Anything dealing with security should be left to post-backs but user experience improving features are fine - auto complete text boxes for example.
