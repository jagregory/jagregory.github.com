---
layout: post
title: Brace Matching and your Language Service
tags:
- .Net
- Boo
- BooLangStudio
- Code
- Hobby Projects
- Visual Studio
- Visual Studio Extensibility
status: publish
type: post
published: true
meta:
  _edit_last: '2'
  aktt_tweeted: '1'
  dsq_thread_id: '644651254'
---
I've been meaning to write up some of my experiences developing for Visual Studio while I've been working on [BooLangStudio](http://www.codeplex.com/BooLangStudio), but I can never seem to find the time; either that, or when I can I'm not confident enough in what I'm doing to put it out here as a valid resource.

I'll start small, here's a quick guide to how I've implemented brace matching using the managed Visual Studio extensibility SDK.

**What exactly is brace matching?** Brace matching is where paired characters are highlighted when one or the other is selected in the editor.

![Brace matching](/images/bracematching-1.png)

There are a couple of things you need to consider when you implement brace matching.

Firstly, there are different types of braces that can be matched (depending on your language). Taking C# as an example, the brace matching works with parentheses (`()`), box brackets (`[]`), braces (`{}`), and chevrons (`<>`). These all need to be paired independently, as to avoid matching an open parenthesis with a closing brace.

Secondly, the matching has to work bi-directionally. The user can place their caret at either side of the bracket pair, and the highlighting should know where both sides are regardless.

## LanguageService implementation

A lot of the legwork of implementing a language in Visual Studio is done in the LanguageService, and brace matching is no exception. You should already have a `ParseSource` method in your LanguageService; this is where we're going to work.

The `ParseSource` method has a `ParseRequest` parameter, which exposes a `Reason` property. When this property is set to `MatchBraces`, that's when we need to do our processing.

``` csharp
public override AuthoringScope ParseSource(ParseRequest request)
{
  if (request.Reason == ParseReason.MatchBraces)
  {
    // match braces here
  }
}
```

What needs to be done is pretty simple: Parse the open document and find the partner to the brace that the caret is on.

In BooLangStudio I've implemented this in the following fashion:

  * Run the document through a `BracketPairFinder`, which creates a list of bracket pairs in the document
  * Get the index of the caret (baring in mind you have to translate between the Request's Line and Column, and an actual string index)
  * Find the pair that the caret is positioned at
  * Get the opposite bracket from the pair
  * Get the Line and Column of the opposite bracket

It's up to you how you implement the above steps, as long as you end up with the opposite bracket to the one you started with. I'll illustrate using the BooLangStudio source.

``` csharp
public override AuthoringScope ParseSource(ParseRequest request)
{
  if (request.Reason == ParseReason.MatchBraces)
  {
    // find all pairs
    var bracketFinder = new BracketPairFinder();
    var bracketPairs = bracketFinder.FindPairs(request.Text);

    // get index of caret from source text
    Source source = languageService.GetSource(request.View);
    int indexOfCaret = source.GetPositionOfLineIndex(request.Line, request.Col);

    // find the partner to the bracket at the caret
    int? partner = bracketPairs.FindPartnerIndex(indexOfCaret);

    if (partner != null)
    {
      // tell Visual Studio about the pair
    }
  }
}
```

> The `Source` class has a helpful `GetPositionOfLineIndex` method, which translates between a Line and Column to a single string index. Very handy!

Once you've got your indices, we need to inform Visual Studio of our findings. You do that by setting the `request.Sink.FoundMatchingBrace` to `true`, then calling the `MatchPair` method on the Sink. You need to pass two `TextSpan` instances to the `MatchPair` method; the first is the left brace, and the second the right.

``` csharp
public override AuthoringScope ParseSource(ParseRequest request)
{
  if (request.Reason == ParseReason.MatchBraces)
  {
    ...

    if (partner != null)
    {
      // tell Visual Studio about the pair
      request.Sink.FoundMatchingBrace = true;

      int nextLine, nextCol;

      source.GetLineIndexOfPosition(partner.Value, out nextLine, out nextCol);

      request.Sink.MatchPair(
        new TextSpan
        {
          iStartLine = request.Line,
          iEndLine = request.Line,
          iStartIndex = request.Col,
          iEndIndex = request.Col
        }, 
        new TextSpan
        {
          iStartLine = nextLine,
          iEndLine = nextLine,
          iStartIndex = nextCol,
          iEndIndex = nextCol + 1
        }, 0);
    }

    return new AuthoringScope(); // replace with your implementation
  }
}
```

> The `Source` class has another helpful method: `GetLineIndexOfPosition` method, which translates back to Line and Column from a single string index.

Finally, just return an empty AuthoringScope, as it isn't used as part of this parse request.

That's it! You should have now successfully implemented brace matching. You may need to tweak the TextSpan indexes depending on your parser implementation, but it shouldn't be far wrong.

## BooLangStudio implementation

If you're interested in seeing how I handle the brace parsing, I may cover that in a future post. However, you can find all the source in my [github BooLangStudio fork](http://github.com/jagregory/boolangstudio/tree/master). Some interesting one's in particular are:

  * [ParseRequestProcessor.HighlightBraces](http://github.com/jagregory/boolangstudio/tree/54d4bcef79d4dbd2ff6cf1fbd9b0a15f325f5c41/Source/BooLangService/ParseRequestProcessor.cs#L133) - Delegated to from the LanguageService.ParseSource method.
  * [BracketPairFinder](http://github.com/jagregory/boolangstudio/tree/54d4bcef79d4dbd2ff6cf1fbd9b0a15f325f5c41/Source/BooLangService/StringParsing/BracketPairFinder.cs) - Class which parses a document to get all the bracket pairs. Uses [ExcludingStringLiteralsStringWalker](http://github.com/jagregory/boolangstudio/tree/54d4bcef79d4dbd2ff6cf1fbd9b0a15f325f5c41/Source/BooLangService/StringParsing/ExcludingStringLiteralsStringWalker.cs).
  * [StringWalker](http://github.com/jagregory/boolangstudio/tree/54d4bcef79d4dbd2ff6cf1fbd9b0a15f325f5c41/Source/BooLangService/StringParsing/StringWalker.cs) - A simple string parser used by the `BracketPairFinder`, which walks over a string maintaining a code-aware state. Basically, it lets you know whether it's currently inside a bracket or string literal. Handy for not matching characters inside strings.