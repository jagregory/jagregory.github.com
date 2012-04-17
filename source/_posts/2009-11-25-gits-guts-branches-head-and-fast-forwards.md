---
layout: post
title: ! 'Git''s guts: Branches, HEAD, and fast-forwards'
tags:
- Git
status: publish
type: post
published: true
meta:
  aktt_notify_twitter: 'no'
  _edit_last: '2'
---
<blockquote>Cross posted to <a href="http://www.lostechies.com/blogs/jagregory/archive/2009/11/25/git-s-guts-branches-head-and-fast-forwards.aspx">Los Techies</a></blockquote>

<p>Lets get some learning done. There are a few questions that keep cropping up when I introduce people to Git, so I thought I'd post some answers as a mini-series of blog posts. I'll cover some fundamentals, while trying not to retread too much ground that the fantastic <a href="http://book.git-scm.com">Git community book</a> already covers so well. Instead I'm going to talk about things that should help you understand what you and Git are doing day-to-day.</p>

<h3>What's a branch?</h3>

<p>I know what you're thinking. <em>"C'mon, we know what a branch is"</em>. A branch is a copy of a source tree, that's maintained separately from it's parent; that's what we perceive a branch to be, and that's how we're used to dealing with them. Sometimes they're physical copies (VSS and TFS), other times they're lightweight copies (SVN), but they're copies non-the-less. Or are they?</p>

<p>Lets look at it a different way. <em>The Git way</em>.</p>

<p>Git works a little differently than most other version control systems. It doesn't store changes using <a href="http://en.wikipedia.org/wiki/Delta_encoding">delta encoding</a>, where complete files are built up by stacking differences contained in each commit. Instead, in Git each commit stores a snapshot of how the repository looked when the commit occurred; a commit also contains a bit of meta-data, author, date, but more importantly a reference to the parent of the commit (the previous commit, usually).</p>

<p>That's a bit weird, I know, but bare with me.</p>

<p>So what is a branch? Nothing more than a pointer to a commit (with a name). There's nothing physical about it, nothing is created, moved, copied, nothing. A branch contains no history, and has no idea of what it consists of beyond the reference to a single commit.</p>

<p>Given a stack of commits:</p>

![Figure 1](/images/GitGuts1_Figure1.png)

<p>The branch references the newest commit. If you were to make another commit in this branch, the branch's reference would be updated to point at the new commit.</p>

![Figure 2](/images/GitGuts2_Figure2.png)

<p>The history is built up by recursing over the commits through each's parent.</p>

<h3>What's HEAD?</h3>

<p>Now that you know what a branch is, this one is easy. <code>HEAD</code> is a reference to the latest commit in the branch you're in.</p>

<p>Given these two branches:</p>

![Figure 3](/images/GitGuts1_Figure3.png)

<p>If you had master checked out, <code>HEAD</code> would reference <code>e34fa33</code>, the exact same commit that the master branch itself references. If you had feature checked out, <code>HEAD</code> would reference <code>dde3e1</code>. With that in mind, as both <code>HEAD</code> and a branch is just a reference to a commit, it is sometimes said that <code>HEAD</code> points to the current branch you're on; while this is not strictly true, in most circumstances it's close enough.</p>

<h3>What's a fast-forward?</h3>

<p>A fast-forward is what Git does when you merge or rebase against a branch that is simply ahead the one you have checked-out.</p>

<p>Given the following branch setup:</p>
    
![Figure 4](/images/GitGuts1_Figure4.png)

<p>You've got both branches referencing the same commit. They've both got exactly the same history. Now commit something to feature.</p>

![Figure 5](/images/GitGuts1_Figure5.png)

<p>The <code>master</code> branch is still referencing <code>7ddac6c</code>, while <code>feature</code> has advanced by two commits. The <code>feature</code> branch can now be considered ahead of <code>master</code>.</p>

<p>It's now quite easy to see what'll happen when Git does a fast-forward. It simply updates the <code>master</code> branch to reference the same commit that <code>feature</code> does. No changes are made to the repository itself, as the commits from <code>feature</code> already contain all the necessary changes.</p>

<p>Your repository history would now look like this:</p>

![Figure 6](/images/GitGuts1_Figure6.png)

<h3>When doesn't a fast-forward happen?</h3>

<p>Fast-forwards don't happen in situations where changes have been made in the original branch and the new branch.</p>

![Figure 7](/images/GitGuts1_Figure7.png)

<p>If you were to merge or rebase <code>feature</code> onto <code>master</code>, Git would be unable to do a fast-forward because the trees have both diverged. Considering Git commits are immutable, there's no way for Git to get the commits from <code>feature</code> into <code>master</code> without changing their parent references.</p>

<p>For more info on all this object malarky, I'd recommend reading the <a href="http://book.git-scm.com">Git community book</a>.</p>
