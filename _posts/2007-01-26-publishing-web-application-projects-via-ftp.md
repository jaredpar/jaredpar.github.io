---
layout: post
---
Web Application projects are a new project type in Visual Studio 2005 SP1.  It almost all of the niceties of the web projects with the semantics of being contained within a class library project.  I like the feel of them and do all of my web app development in them now.  

I just ran into a small problem publishing them.  After banging my head on the wall for an hour I thought to post the solution in case anyone else ran into the problem.

One of the data files I'm using is rather large so I opted to publlish via FTP for speed purpose.  After uploading the app I couldn't view any of my pages.  The error page kept telling me there was an error becaus the page "/Application.Master" was not present on the system.  These apps all ran fine on my local system.

As you can guess, it's not to easy to turn up useful information searching the web when your key words are "master page file parse error".

The problem is that because I only ever published this application via FTP, front page extensions were never engaged and hence the project was not created as far as the ASP.Net system was concerned on the server.  Instead it was just another directory.  I did a mini publish via HTTP and my app immediately started working.

