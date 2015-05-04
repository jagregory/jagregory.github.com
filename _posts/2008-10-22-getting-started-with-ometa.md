---
layout: post
title: Getting started with OMeta#
tags:
- .Net
- Code
- Git
- OMeta
- SharpDiff
status: publish
type: post
published: true
meta:
  _edit_last: '2'
  aktt_tweeted: '1'
  dsq_thread_id: '644651346'
---
> **Notice:** I'm a novice at OMeta, and as such, you shouldn't take my advice as best-practice. This is based on my exploratory findings.

String parsing is hard. I don't think anyone will deny that. You can parse it by hand, you can use regular expressions, you can walk it character by character. With [SharpDiff](/writings/sharpdiff-diff-parsing-in-net/), I needed to parse some serious text, it was in an expected format, but there are numerous rules surrounding it. I did not fancy parsing it by hand, or with regular expressions.

I considered writing a parser for it, but dismissed that after my dealings with [ANTLR](http://www.antlr.org) in [BooLangStudio](http://www.codeplex.com/BooLangStudio). It's not so much that ANTLR is bad, it's just long winded; it's completely [visitor](http://en.wikipedia.org/wiki/Visitor_pattern)tastic.

Anyway, after 10 minutes down the path of parsing it myself, I cracked and decided to look into alternatives to ANTLR. I came across [OMeta#](http://www.codeplex.com/ometasharp) and (with a reassuring nudge by Jeffery Olson) I went with it.

## So what is OMeta#?

At it's heart, [OMeta](http://www.cs.ucla.edu/~awarth/ometa/) is just a really great string parser, and OMeta# is a .Net implementation of it. Combine that with a fairly decent definition language and codegen'd parser creation, and you're onto a winner.

It allows you to write a syntax grammar and parse content with it, without having to worry about lexing, tokenizing and all that jazz. You only need to learn one language, OMeta.

While working on SharpDiff, I took a detour and implemented another very simple Git diff format. It's a stat/metrics diff that just tells you which files have changed, and how many additions and removals have occurred in each. A pretty straight forward diff crying out to be used as an example.

## A basic OMeta-based parser

Git has a diff format called stat (and it's counter-part numstat, that we'll be using). It produces output like so:

```
1    0    myFile.txt
3    1    anotherFile.txt
```

> If you're following along at home, you'll need to create yourself a new git repository. In there place a couple of text files, add some content to them and commit them. Then make some changes to those files, but don't commit that. Now you can execute `git --numstat` to get the above output.

The Git documentation is a wonderful thing, and it provides us with a nice outline of the numstat output.

```
1    2    README
3    1    arch/{i386 => x86}/Makefile
```

That is, from left to right:

  * the number of added lines;
  * a tab;
  * the number of deleted lines;
  * a tab;
  * pathname (possibly with rename/copy information);
  * a newline.

Before we get to the meat, there's a couple of things we need to do. Firstly, (at the time of writing) there are no binaries available for OMeta#, so you'll have to download the source and compile yourself. Once you've done that, you need to reference the `OMetaSharp.dll` and `OMetaSharp.OMetaCS.dll`.

Due to OMeta codegening our parser, it really needs to be built separately to our main project. If we don't do that, we could get ourselves in a mess when we write an invalid grammar and generate some uncompiling code from it.

I won't go over how to do this, but basically wrap the following code in a separate console app, changing the paths to point to where your code actually lives.

``` csharp
public void RebuildGitNumstatParser()
{
  var contents = File.ReadAllText(@"..\..\..\SharpDiff\Parsers\GitNumstatParser.ometacs");
  var result = Grammars.ParseGrammarThenOptimizeThenTranslate
    <OMetaParser, OMetaOptimizer, OMetaTranslator>
    (contents,
     p => p.Grammar,
     o => o.OptimizeGrammar,
     t => t.Trans);

  File.WriteAllText(@"..\..\..\SharpDiff\Parsers\GitNumstatParser.cs", result);
}
```

That just gets OMeta to compile our grammar, then spit out a C# file.

One more thing, then we can get going. For this generation to work, we really need to give it a grammar and parser to begin with. So we'll create an empty grammar and parser.

``` ocaml
using OMetaSharp;
 
ometa GitNumstatParser : Parser {
}
```

``` csharp
public class GitNumstatParser : Parser
{
}
```

Now we can begin! One of the wonderful things about OMeta# is that it can be test driven very easily, which really surprised me.

So lets create our first test!

``` csharp
[Test]
public void ParsesNumber()
{
    var result = Parse<int>("1", x => x.Number);

    Assert.That(result, Is.EqualTo(1));
}
```

In this test, we pass the Parse function a generic type parameter (int) which is our expected return type, then a string and an expression. The string is our input content, and the expression is the grammar rule to use for parsing.

I'm also using a shortcut method for parsing, which you can see below:

``` csharp
protected T Parse<T>(string text, Func<GitNumstatParser, Rule<char>> ruleFetcher)
{
    return Grammars.ParseWith(text, ruleFetcher).As<T>();
}
```

When you run this test, it should pass. We didn't do anything, I hear you say. That's because we didn't have to in this case. OMeta# comes with a few predefined rules that you can sometimes take advantage of (or override to give different meaning in your grammar). In this case, we've used the Number rule, which parses a string and returns an integer from it.

Onto the next test.

``` csharp
[Test]
public void ParsesAdditionsAndSubtractionValues()
{
    var result = Parse<FileStats>("3\t8\tmyFile.txt\r\n", x => x.Number);

    Assert.That(result.Additions, Is.EqualTo(3));
    Assert.That(result.Subtractions, Is.EqualTo(8));
}
```

We need a class to represent our file statistics, I've created one called FileStats.

``` csharp
public class FileStats
{
  public FileStats(int additions, int subtractions)
  {
    Additions = additions;
    Subtractions = subtractions;
  }

  public int Additions { get; private set; }
  public int Subtractions { get; private set; }
}
```

When you run this test, it will fail (and at the time of writing, fail with a nasty unhelpful OMeta exception). This is because we're still trying to use the Number rule, so we need to create our FileStats rule.

Open up your ometacs file and follow along.

``` ocaml
using SharpDiff.FileStructure.Numstat;
using OMetaSharp;

ometa GitNumstatParser : Parser {
  FileStats = Number:adds '\t' Number:subs
    -> { new FileStats(adds.As<int>(), subs.As<int>()) }
}
```

Right, that's a bit of an overload, so lets go through it.

The line is made up from three parts:

  * Rule name
  * Pattern to match
  * Code to produce

For this line, we're creating a rule called <code>FileStats</code>, which matches the <code>Number:adds '\t' Number:subs</code> pattern, and produces the code <code>new FileStats(adds.As<int>(), subs.As<int>())</code>.

Lets examine what the pattern is doing. Firstly, we're using the Number rule that we used in our first test. The colon denotes an assignment to a variable, so we're getting the match from the Number rule and putting that in an <code>adds</code> variable. We then match a single tab character ('\t'), and then another Number. Whitespace is ignored in the OMeta grammar, which means you can structure the file pretty much however you like.

Our pattern gives us two variables, adds and subs, we need to do something with them. The <code>-></code> operator designates the next curly brace surrounded region to be your desired C# code output. For this rule, we're creating a new instance of our FileStats class, and passing our two variables into the constructor (converting them to ints at the same time).

At this point, run your side executable that recreates the generated parser. You should now be able to alter your test to use the FileStats rule instead of Number, and have it pass.

So what can we parse now? We're able to get the additions and subtractions from a line such as <code>1    4    myFile.txt</code>.

We still need to be able to get the filename back though, so onto our next test.

``` csharp
[Test]
public void ParsesFilename()
{
  var result = Parse<string>("anotherFile.txt", x => x.Filename);

  Assert.That(result, Is.EqualTo("anotherFile.txt"));
}
```

This test won't compile until we create our Filename rule, so off to the ometacs with us!

``` ocaml
using SharpDiff.FileStructure.Numstat;
using OMetaSharp;

ometa GitNumstatParser : Parser {
  FileStats = Number:adds '\t' Number:subs
    -> { new FileStats(adds.As<int>(), subs.As<int>()) },
  Filename = LetterOrDigit+:name '.' LetterOrDigit+:ext
    -> { name.As<string>() + "." + ext.As<string>() }
}
```

We've now got an extra rule at the end of the file, Filename. I can't stress this enough, <strong>watch your commas</strong>; OMeta#s errors are poor, and something like that can trip you up.

Our new rule looks complex, but is pretty simple. It uses the built-in LetterOrDigit rule, which matches a single letter or digit. We suffix that call with a <code>+</code> which (like regex) matches one or more instances; that match is then stored in a <code>name</code> variable. Following that is a single full-stop. Finally, another LetterOrDigit+, which matches our extension. We then concatenate those strings in our C# output.

Again, recompile your parser. Now your test should pass. It simply matches any filename with an extension (room for improvement here!).

Now we can bring the two together, so we can parse a whole line. Next test!

``` csharp
[Test]
public void ParsesFullFileLine()
{
  var result = Parse<FileStats>("3\t8\tmyFile.txt\r\n", x => x.FileStats);

  Assert.That(result.Additions, Is.EqualTo(3));
  Assert.That(result.Subtractions, Is.EqualTo(8));
  Assert.That(result.Filename, Is.EqualTo("myFile.txt"));
}
```

We need to update our FileStats class so it supports the filename.

``` csharp
public class FileStats
{
  public FileStats(int additions, int subtractions, string filename)
  {
    Additions = additions;
    Subtractions = subtractions;
    Filename = filename;
  }

  public int Additions { get; private set; }
  public int Subtractions { get; private set; }
  public string Filename { get; private set; }
}
```

Our grammar file is going to undergo a bit of refactoring too. We're covered by tests, so why shouldn't we? Our <code>FileStats</code> rule doesn't really describe the whole line it should be matching. Really what we should have is a <code>LineStats</code> (that's what our FileStats currently is) that just matches the numbers, then a FileStats that matches the numbers <strong>and</strong> the filename.

``` ocaml
ometa GitNumstatParser : Parser {
  FileStats = LineStats:lines '\t' Filename:name NewLine
    -> { new FileStats(
      lines[0].As<int>(),
      lines[1].As<int>(),
      name.As<string>()) },
  LineStats = Number:adds '\t' Number:subs
    -> { adds, subs },
  Filename = LetterOrDigit+:name '.' LetterOrDigit+:ext
    -> { name.As<string>() + "." + ext.As<string>() },
  NewLine = '\r' '\n'
}
```

So what we've done here is redo our FileStats rule as LineStats, which instead of creating an instance of the FileStats class, just returns an array of it's two matches <code>{ adds, subs }</code>; this encapsulates that particular bit of behavior. Next we've created our new FileStats rule, which calls our LineStats rule and captures the matches. It then matches a single tab, and the filename using our Filename rule, followed by a NewLine; these are then combined and pushed into the constructor for our FileStats class. We've defined NewLine at the end, and it simply matches the \r\n characters.

Rebuilding and running that test should now give success. We're now able to completely parse a diff line. Only one thing left to do, parse multiple lines together.

``` csharp
[Test]
public void CanParseMultipleLines()
{
  var result = ParseList<FileStats>(
    "3\t8\tfile.txt\r\n" +
    "5\t1\tanotherFile.txt\r\n", x => x.FullFile);

  Assert.That(result.Count, Is.EqualTo(2));
  Assert.That(result[0].Filename, Is.EqualTo("file.txt"));
  Assert.That(result[0].Additions, Is.EqualTo(3));
  Assert.That(result[0].Subtractions, Is.EqualTo(8));
  Assert.That(result[1].Filename, Is.EqualTo("anotherFile.txt"));
  Assert.That(result[1].Additions, Is.EqualTo(5));
  Assert.That(result[1].Subtractions, Is.EqualTo(1));
}
```

Our final test is a bit longer than the others, but it's simple. We pass in some multiline input, and then assert that we have two FileStat objects, and that they're correctly formed.

For this test we're using another helper method, which returns a list of rule matches.

``` csharp
protected IList<T> ParseList<T>(string text, Func<GitNumstatParser, Rule<char>> ruleFetcher)
{
  return new List<T>(Grammars.ParseWith(text, ruleFetcher).ToIEnumerable<T>());
}
```

Again, this test will fail because we haven't defined the FullFile rule. So again to the ometacs file.

``` ocaml
FullFile = FileStats+:files -> { files },
```

All we do this time is add this rule to the top, which uses the <code>+</code> operator to match multiple FileStats rules. They're then returned as they are so we can convert them to an enumerable.

That's it, recompile and run, you should now be parsing full diff outputs with ease!

As you can see OMeta# is pretty easy, and it's very easy to test drive. There are a few quirks to doing it that way (such as having to create the compiled grammar before your test will run), but it's a lot smoother than I expected. The grammars are quite simple too, and there are some shortcuts you can take which help make things easier. The SharpDiff grammar currently stands at just 49 lines, and it's capable of parsing 90% of the standard git output, not bad!

I'll just introduce you to another little bit of syntax that can make things simpler. Our Filename rule matches filenames with extensions, but it doesn't match filenames without! That could be a problem; however, instead of creating a new rule for this, you can create multiple patterns for a rule. Each pattern will get evaluated if the one before it fails.

So we can update our Filename rule to the following, which tries to match a filename with an extension, and if it can't do that, it then tries without an extension.

``` ocaml
Filename = LetterOrDigit+:name '.' LetterOrDigit+:ext
  -> { name.As<string>() + "." + ext.As<string>() }
         | LetterOrDigit+:name
  -> { name.As<string>() },
```
