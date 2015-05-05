---
layout: post
title: Empty NHibernate logs and poor performance
tags:
- .Net
- Logging
- NHibernate
- Performance
- Work
status: publish
type: post
published: true
meta:
  _edit_last: '2'
  aktt_tweeted: '1'
  dsq_thread_id: '644650968'
---
We had an issue recently where NHibernate was performing very poorly on our production server, but not on our developer machines or our test server. I investigated the issue and narrowed it down to two symptoms.

**Symptom 1:** Very poor performance. I'm talking 10+ seconds per page load, with no more than 5 queries being executed by NHibernate.

**Symptom 2:** Empty log files. None of our log files had any data in on the live server, but they did on our other systems.

I decided to investigate the second symptom first, as it may be causing the first (ends up it was).

<!-- more -->

Firstly, I noticed that our logging was set to `DEBUG`. Must've been a leftover from when we first deployed NHibernate, very sloppy, I know. So I reset that to `WARN`, but it had no effect.

When files aren't being written to, you should always check the directory permissions. Low and behold, it was a permissions problem. Our test server had different users allowed to write to the Logs directory than our production server. I granted the same users access, `NETWORK SERVICE` and `IUSR_MACHINENAME` in our case.

After I recycled the IIS worker processes, we were flying again. We're back to having < 1sec page loads.

This is pure speculation, but what I believe was happening is this: Logging was set to `DEBUG`, so it was logging *a lot*. With each log call, the logger was failing to get write access to the files and throwing an exception, that exception would probably have propagated a bit too. The combination of the sheer amount of data being written to the log, and an exception per log call, were responsible for the severe slowdown.

So in short: Always make sure NHibernate has write access to its own log directory!
