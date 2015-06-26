---
layout: post
title: 'Docker container out of disk space'
date: 2015-06-26
---

Are programs in your Docker container complaining of no free space?  
Does your host have loads of space?  
And your container does too?

*It could be inode exhaustion!*

## The symptoms

All of a sudden my CI agent (which is in a Docker container) stopped running builds. Everything went <span style="color:red">red</span>. The failures were inconsistent, happening at different points in the build but always failing.

A typical error looked something like this:

    npm ERR! ENOSPC, open /var/lib/go-agent/pipelines/{blah}/node_modules/node-sass/node_modules/...
    npm ERR! nospc This is most likely not a problem with npm itself and is related to insufficient space on your system.

ENOSPC and "Insufficient space on your system" are dead giveaways that something is wrong! So npm thinks there isn't any space on the disk.

I best look into this.

## Diagnosing

I SSH onto the box and have a poke around.

    $ df -h

    Filesystem      Size  Used Avail Use% Mounted on
    /dev/xvda1       99G  9.4G   85G  10% /

`df` tells me there's heaps of space available on the host. This is unsurprising because I've just resized the disk, but it's worth checking.

Next I run the same command in the agent container.

    $ docker exec agent-1 df -h

    Filesystem                   Size  Used Avail Use% Mounted on
    /dev/mapper/docker-202:1-... 9.8G  1.8G  7.5G  20% /

Container says the same thing, of the [10gb Docker allocates a container by default](https://jpetazzo.github.io/2014/01/29/docker-device-mapper-resize/) there's 7.5gb still available.

Nothing is out of disk space.

So what could prevent creating new files and masquerade as lack of free space? [inodes](https://en.wikipedia.org/wiki/Inode) can!

    $ docker exec agent-1 df -i

    Filesystem                   Inodes  IUsed   IFree IUse% Mounted on
    /dev/mapper/docker-202:1-... 655360 655360       0  100% /

Running `df` with the `-i` flag reports on inode usage. Oh no, 100% of inodes within my container are in use. That's not good. Not good at all. *Problem identified*.

## Finding where all our inodes are

An inode can be thought of as a pointer to a file or directory with a bit of data about them. All those file permissions and owners you set on files get stored in the file's inode. Therefore, for every file or directory you have there'll be a corresponding inode. So if we've used all our inodes, we've used all our available files. We have too many files. You can have a lot of files, so running out is a sign of *something bad happening*.

With this in mind, we have to find where all these mysterious files are and why there are so many. I read a [free inode usage](http://stackoverflow.com/questions/653096/howto-free-inode-usage) post on StackOverflow which has some handy commands for answering this question.

I ran this command:

    $ sudo find . -xdev -type f | cut -d "/" -f 2 | sort | uniq -c | sort -n

Which prints out the inode count for all subdirectories of the current directory. It will take a little while, then print out something like this

       89 opt
      101 sbin
      109 bin
      258 lib
      651 etc
      930 root
    23466 usr
    83629 var
    51341 tmp

OH HELLO `tmp` WHY DO YOU HAVE SO MANY INODES?

## Fixing the issue

One `rm -r /tmp` later and `df -i` reports a much more healthy 20% inode usage. Easy when you know what the problem is.

In my case it was a stupid lack of cleaning up some temp files from our builds. An `npm install` which downloads the entire world into `/tmp` on every build. We were averaging 10000 inodes per build. Ouch.

Builds are now <span style="color:green">green</span> again. Pretty anti-climactic; but it's the journey not the destination which counts, right?
