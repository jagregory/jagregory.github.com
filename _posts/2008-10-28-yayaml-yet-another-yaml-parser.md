---
layout: post
title: ! 'YaYAML: Yet another YAML parser'
tags:
- .Net
- Hobby Projects
- OMeta
- Parsers
- YAML
- YaYAML
status: publish
type: post
published: true
meta:
  _edit_last: '2'
  aktt_tweeted: '1'
---
I don't want to make much ceremony around this, but I thought I'd mention it incase anybody else is interested.

As a part of a project I'm working on I needed a simple file to store some data in, and I didn't want it to be XML (for no reason other than the verbosity). I could have used my own format, but instead I've gone for [YAML](http://yaml.net). If you've worked with Ruby on Rails at all, then you'll be familiar with YAML. It's a human readable (and writable) text format.

Of course, I still needed to be able to parse my YAML document. There was a project announced 2 years ago to create a .Net parser, but like many things, it seems very much abandoned. So, after my [recent adventure with OMeta#](/writings/getting-started-with-ometa/), I thought I'd hack on this too.

<!-- more -->

## Introducing YaYAML: Yet another YAML parser.

Don't get your hopes up, I've only implemented exactly what I needed out of the spec, which is very little indeed. However, it's something I will carry on with when time permits. So what can you parse with YaYAML? Only documents containing a single flat sequence or mapping. **No nesting, no multiple documents in a file, no variables.**

It's possible to parse these two example files:
``` yaml
- a list
- of text
- strings
```

``` yaml
a: mapping
of: various
key: and
value: pairs
```

``` yaml
- name: James
  age: 23
- name: Peter
  age: 34
```

That's it!

You can find the source in my [YaYAML github repository](http://github.com/jagregory/yayaml).
