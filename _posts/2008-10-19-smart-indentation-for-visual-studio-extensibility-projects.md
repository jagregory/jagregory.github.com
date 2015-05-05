---
layout: post
title: Smart Indentation for Visual Studio Extensibility projects
tags:
- .Net
- Boo
- BooLangStudio
- Code
- Visual Studio
- Visual Studio Extensibility
status: publish
type: post
published: true
meta:
  _edit_last: '2'
  aktt_tweeted: '1'
  dsq_thread_id: '644651075'
---
I said previously in my [Brace Matching post](/writings/brace-matching-and-your-language-service/) that I want to try to document some of my findings while working on [BooLangStudio](http://www.codeplex.com/BooLangStudio). Well this is my second post on the subject.

When you're implementing a custom language in Visual Studio, there's a very good chance that you're going to want to handle indentation slightly differently to the defaults. Every language has it's own rules, after all.

<!-- more -->

Most of the resources I found online we're pretty poor for how to get this working. Most people we're pointing to overriding `OnCommand` in your derived `Source` class, or implementing some interop interface (i.e. `IVsLanguageLineIndent`). I could get none of these working. `OnCommand` never got raised, and the interfaces we're useless.

I tried a few different methods for handling indentation, but none of them worked very well. I tried capturing the enter key press, but that didn't work. Then I tried capturing alterations to the document, but those also got fired for navigating the document, so you'd press the up key and add a new line!

It ended up being pretty simple to implement, once I finally found the correct way to do it. I'll cover how I did this for BooLangStudio below.

In your `LanguageService`, there's a method you can override called `CreateViewFilter` which sets everything in motion.

Create yourself a class that derives from `ViewFilter`, and then return an instance of it from the overridden `CreateViewFilter` method in your language service.

``` csharp
public class BooViewFilter : ViewFilter
{
  public BooViewFilter(CodeWindowManager mgr, IVsTextView view) : base(mgr, view)
  {}
}

public override ViewFilter CreateViewFilter(CodeWindowManager mgr, IVsTextView newView)
{
  return new BooViewFilter(mgr, newView);
}
```

> <strong>Note:</strong> You need to make sure your project is configured to use Smart Indentation. If your project is complete enough to allow the user to customise this, then you're fine. However, if not you can hard code this value yourself. In your language service there's a `GetLanguagePreferences` method that returns all the preferences for your project. In that method you can set `languagePreferences.IndentStyle = IdentingStyle.Smart`, which is what I've done in BooLangStudio.

You'll kick yourself for how easy this is. Now override the `HandleSmartIndent` method in your derived `ViewFilter`. That's it really, in there you can access the `Source` object and do as you wish with smart indentation.

Taking BooLangStudio as an example, you can see in our [BooViewFilter.cs](http://github.com/jagregory/boolangstudio/tree/443929113ca77ae3c4613691f06f043f9d8f8d77/Source/BooLangService/BooViewFilter.cs) that I delegate the work to a `HandleSmartIndentAction`. This is to make testing easier by having as little dependencies on Visual Studio as possible.

The `Execute` method of our [HandleSmartIndentAction.cs](http://github.com/jagregory/boolangstudio/tree/443929113ca77ae3c4613691f06f043f9d8f8d77/Source/BooLangService/HandleSmartIndentAction.cs) class gets the caret location and passes it to an instance of a [LineIndenter](http://github.com/jagregory/boolangstudio/tree/443929113ca77ae3c4613691f06f043f9d8f8d77/Source/BooLangService/LineIndenter.cs) class, which determines (based on the previous line to the caret) whether the next line should be indented, or outdented.

``` csharp
public bool Execute()
{
  int line, col;

  view.GetCaretPos(out line, out col);

  indenter.SetIndentationForNextLine(line);

  return false;
}
```

``` boo
class MyClass:
  def MethodName(): # indent
    return # outdent
```

So that's how to implement Smart Indentation in your Visual Studio Extensibility project, and a little bit of implementation details of BooLangStudio.
