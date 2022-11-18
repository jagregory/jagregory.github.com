---
layout: post
title: Improving my dev loop with visual regression testing
date: 2022-11-18
published: true
---

When the pandemic hit we (at my social enterprise side-hustle) quickly built a
video calling web app for medical students to able to continue their
"face-to-face" practice exercises, which later grew to allow actual exam
scenarios for those students, and also then started supporting rehabilitation
for people with traumatic brain injuries.

It’s been quite a journey and I’ve learned a lot along the way. Recently, I’ve
been trying to improve the dev loop for making visual changes to a delicate part
of the system.

<!-- more -->

The video calling feature was built _quickly_, adding to an existing ed tech
platform we already had. During the early pandemic, when work was getting a bit
thin for my employer, I took a some time off and built the video calling in a
few weeks. It was a rush to say the least.

The underlying core services are solid (tying together Twilio APIs with AWS
Lambda), but the UI has been delicate ever since I built it. A bad combination
of a rush on my part, relatively nascent browser tech, and cross-browser/device
compatibility issues.

Recently, I made some small changes that ended up breaking a small part of the
call experience for a subset of users.

Fortunately, the issue was minor (not being able to see your own video in the
corner of the screen) but it finally kicked me into try to do something to
improve the reliability of this area which hasn’t really benefitted from the
traditional test pyramid.

## Step 1 - Refactor the calling UI to work isolated in Storybook

This was a couple of big changes:

1. Pulling queries up the stack to make it easier to mock behaviour in stories,
   all data fetching ended up outside the core calling UI.
2. make it possible to fake cameras, microphones, and screen sharing states. The
   combination of these two things meant I could create Storybook stories for
   scenarios like “only one person has joined the call”, “two people in the
   call, one person has their camera off”, “one person screen sharing, another
   person with a portrait camera” etc...

With the Storybook stories I could now eyeball these common variations easily
enough, which gave me a much quicker feedback loop than actually initiating a
video call.

## Step 2 - Visual regression tests against the Storybook stories

Using [percy.io](https://percy.io/), I now take a screenshot of each of those
stories, in several browsers, at several resolutions and orientations, and then
diff them against previous snapshots.

I haven’t hooked this into CI (and I’m undecided if I will) but it’s been very
useful as a form of regression testing for when I’m iterating over some purely
visual (e.g. CSS) changes.

I now make the change in Chrome and test it manually in a few stories, but then
kick off the percy.io tests and see what it tells me. Much easier than manually
comparing across different browsers and devices.

It's still not perfect, but it's a big improvement.

Now I just need to finish the simple task of making my calling UI a pleasant
experience for my users. 😅

> Cross-posted from Mastodon: https://aus.social/@jagregory/109366550345741717 
