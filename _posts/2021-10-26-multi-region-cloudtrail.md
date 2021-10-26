---
layout: post
title: Multi-region CloudTrail with logs in another AWS Account
date: 2021-10-26
published: true
---

I had one [CloudTrail](https://aws.amazon.com/cloudtrail/). Then I had many CloudTrails. Now I have
only one once again, but a better configured one.

In this post I walk through my experience of migrating from a less-than-ideal hand-rolled
multi-region CloudTrail setup to an single multi-region CloudTrail with a sprinkling of extra
security by using a separate AWS account to store the logs.

<!-- more -->

## What is CloudTrail?

Before we get started, what actually is CloudTrail and why would I want to use it?

**What is it?** The tag line on the [CloudTrail landing page](https://aws.amazon.com/cloudtrail/) is
the official word, but informally CloudTrail collects logs of all the management activity on your
AWS account and dumps it into an S3 bucket for you to look at later (hopefully never).

Below is a truncated example of a single CloudTrail event, from CloudTrail itself querying my
bucket.

You can see the `eventType`, an AWS API call, the `eventName` with the actual call `GetBucketAcl`,
the `userIdentity` of `cloudtrail.amazonaws.com` and the `resources` it accessed.

```json
{  
  "eventVersion": "1.08",  
  "userIdentity": {  
    "type": "AWSService",  
    "invokedBy": "cloudtrail.amazonaws.com"  
  },  
  "eventTime": "2021-10-26T00:49:57Z",  
  "eventSource": "s3.amazonaws.com",  
  "eventName": "GetBucketAcl",  
  "awsRegion": "ap-southeast-2",  
  "eventType": "AwsApiCall",  
  "eventCategory": "Management"  
  [...]
  "resources": [{  
    "accountId": "...",  
    "type": "AWS::S3::Bucket",  
    "ARN": "arn:aws:s3:::mybucketname"  
  }]
}
```

**Why would you use it?** Auditing activity on your AWS account. If ever you have a security
incident or are just curious "who deleted that S3 bucket?" then CloudTrail is what you need enabled
to find that out. Without CloudTrail enabled it's going to be considerably more difficult for you to
investigate issues. As a bonus, CloudTrail is free for management logging, you just pay for the
storage of events in S3.

When asked what the one thing everyone should do right now to improve their security posture, [Corey
Quinn
said](https://aws.amazon.com/blogs/security/definitely-not-an-aws-security-profile-corey-quinn-a-cloud-economist-who-doesnt-work-here/):

> Easy. Log into the console of your organization’s master account and enable [AWS CloudTrail](https://aws.amazon.com/cloudtrail/)
> for all regions and all accounts in your organization. Direct that trail to a locked-down S3
> bucket in a completely separate, highly restricted account, and you’ve got a forensic log of all
> management options across your estate.
> 
> Worst case, you’ll thank me later. Best case, you’ll never need it.

## The state of my CloudTrail

I did have CloudTrail enabled, so not a bad starting point; however, the setup did leave a few
things to desire, especially as it'd grown over the past few years.

In the beginning I had one CloudTrail for the one region in use. The trail logged into an S3 bucket
in the same AWS account.

As my AWS footprint expanded to another couple more regions, I replicated that same setup (instead
of switching to a [multi-region
trail](https://aws.amazon.com/about-aws/whats-new/2015/12/turn-on-cloudtrail-across-all-regions-and-support-for-multiple-trails/),
which I was oblivious to) to each additional region. Later, I pushed it to all regions for peace of
mind. That left me with twenty trails and twenty S3 buckets, all in the same AWS account. Definitely
not ideal.

![](/images/too-many-cloudtrails.png)

What I wanted to do was to consolidate everything down to a single multi-region CloudTrail and a
single S3 bucket. For added security, I also wanted to put the S3 bucket in a separate AWS account.
In my original setup, anyone who compromises credentials on the main account may also be able to
remove any record of their activity if they could gain access to the CloudTrail S3 bucket. In the
new setup, the severely locked down secondary AWS account would at least make it much more difficult
for someone to hide their tracks.

## Setting up a multi-region CloudTrail with an S3 bucket in another account

To have your S3 bucket in another AWS account you're going to need another AWS account! I suggest
you make a completely new account for this, the only thing this account will have in is an S3 bucket
for your CloudTrail logs, by using a new account you reduce the risk of someone else wandering in
for other reasons.

Once you've made the account, follow the usual security practices and [lock down the root
account](https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html#lock-away-credentials).

If the account is within an Organisation, pay close attention to the cross-account role if there is
one. This role, usually called `OrganizationAccountAccessRole`, allows admin access to the new
account from your main AWS account. Make sure nobody can assume that role who shouldn't be able to,
otherwise they'll be able to jump into the new account and tamper with your S3 bucket (defeating the
point of having a separate account).

Now in your newly locked down account, create an S3 bucket for your CloudTrail logs. Lock that thing
down too, no public access, nobody has write access. You'll need to [setup a policy to your bucket
to allow CloudTrail write
access](https://docs.aws.amazon.com/awscloudtrail/latest/userguide/cloudtrail-set-bucket-policy-for-multiple-accounts.html)
across accounts.

Whilst you're at it, you might want to setup a [lifecycle
policy](https://docs.aws.amazon.com/AmazonS3/latest/userguide/object-lifecycle-mgmt.html) on your
new bucket to transition older logs to cold storage to save you a little bit of money.

Now back over in your main AWS account create (or update) your CloudTrail and point it at the new S3
bucket in the other account, turn on the multi-region feature on the trail, and then save it and
you're done.

At this point you have a CloudTrail which monitors all your regions (and automatically expands to
new regions as they become available) and sends logs to an S3 bucket in a separate locked-down AWS
account.

If you're like me though, you also have twenty existing buckets which have been accumulating logs
for years that you'd like to keep...

## Consolidating up my historical trails

As I mentioned at the start, I'd ended up with twenty CloudTrails each with their own bucket. Those
buckets had been accumulating logs for five years and, as I'm obligated to keep logs around for
seven years, I didn't want to lose these logs as part of my consolidation.

This is easy, right? "Just move the files from one bucket to the new one!"

Not so fast. I've just locked down the CloudTrail S3 bucket so nobody can write to it apart from
CloudTrail, and also the bucket is now in a different AWS account and cross-account copying is a
little trickier.

Fortunately, this ["How can I copy S3 objects from another AWS
account?"](https://aws.amazon.com/premiumsupport/knowledge-center/copy-s3-objects-account/) FAQ was
covered most of what I needed.

Firstly, I needed to punch a hole in my shiny new security policy by granting write access to my AWS
user so I could copy the files. Watch out for the `"s3:x-amz-acl": "bucket-owner-full-control"`
requirement. I revoked this access as soon as the copying was complete.

Secondly, configure [Object
Ownership](https://docs.aws.amazon.com/AmazonS3/latest/userguide/about-object-ownership.html) on the
central S3 bucket so the new AWS account owns the files that are copied to it.

Then repeatedly for each region, run `aws s3 sync --storage-class GLACIER --acl
bucket-owner-full-control s3://original-cloudtrail-bucket s3://new-cloudtrail-bucket` to copy the
files over. Thanks to the way CloudTrail logs to the bucket, I didn't need to do any path
manipulation, it all can copy into the single bucket without any changes. Again, watch out for the
ACL setting for the bucket ownership, and optionally set the storage class for the files whilst
you're copying.

_Lots of time passes._ Turns out copying files that have been collected over five years from twenty
different regions takes a lot of time.

Finally when that's all done, delete those old buckets and any other CloudTrails and patch up any
security holes you created. Nice, twenty trails and buckets down to just one.

## Conclusion

One CloudTrail better than none, but also better than many. Multi-region (and multi-account)
CloudTrails are great and pushing your logs off to another AWS account can help reduce your security
risk by reducing the blast radius of compromised credentials.
