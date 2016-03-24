---
layout: post
title: Github notifications in large projects
tags: [misc]
---

A favorite twitter complaint from me and some other members of the [dotnet org](https://github.com/orgs/dotnet) is that Github email / notifications are unusable in our projects due to the incredible volume.  Recently I was looking back on some of my tweets and realized they are exactly the kind of feedback I hate getting for my own projects: non-specific and not proposing a realistic solution.  It can often come across as an upset user screaming:

> It's broken, fix it!!!

Today I decided to rectify that and be a better OSS citizen by getting specific and proposing a possible solution.

Before we dig into this though I do want to be explicit that this post is not meant as a Github bashing post.  Github has been the home of my personal projects for the last five years and my professional ones for a little over one year now.  I spend more time on that site than I'd really like to think about.  Overall it's a great experience and enhances my life as a developer.  Notifications are just one aspect that simply doesn't scale up for the larger projects I work on.

### How much is too much?

While that's true we've never really gotten specific with the data and I don't think many people realize just how much noise notifications generate on large projects.

Email is the most visible aspect.  The volume has caused me to create an intricate set of rules for processing.  It essentially dumps emails into three folders:

- Inbox: addressed to me specifically
- Github PR: notification related to pull requests
- Github Other: everything else from Github

Here is the average amount of email I receive in these folders **per day**:

- Inbox: 80
- Github PR: 650
- Github Other: 750

Basically 5% of all emails I receive are actually interesting to read.  The rest is just noise waiting to be deleted.

A quick note on these numbers.  I only have data for a few weeks back due to archiving and I didn't include non-work days in my calculations.

The other aspect here is the notifications UI on Github.  I don't have daily numbers on this because I can't find a reasonable way to look at it.  But overall I have 27,000+ unread notifications so the effect is the same: far too many to process.  
