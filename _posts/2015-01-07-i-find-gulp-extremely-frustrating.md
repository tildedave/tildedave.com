---
layout: post
title: "I Find Gulp.js Extremely Frustrating"
---

This is going to be a post where I complain.  Those of you who have worked with me know that this can a bit of a default state but I try to be a bit more positive on my blog - unfortunately this is not going to be one of those times.

So at the new job we use [Gulp.js](http://gulpjs.com/).  Gulp is a streaming build system which its webpage advertises as "easy to use".  The basic idea behind Gulp is that your build is a set of streams; you describe the source and destinations and the Gulpfile - code over configuration - sets it up so that your assets are quickly generated by operating directly on the streaming data and not writing any temporary files to disk.

For example here's how you would concatenate all your JavaScript files, pipe them through a minifier (here uglify), and write them to a single generated file.

```javascript
var gulp = require('gulp'),
    uglify = require('gulp-uglify');

gulp.task('js', function() {
  return gulp.src('**/*.js')
             .pipe(uglify())
             .pipe(gulp.dest('./dist/js/built.js'));
});
```

It's so easy!  Everything is just streams!

I really appreciate Gulp as a "crazy idea".  _Could we make our build just an asset pipeline?  Would that be a good idea?_  However, Gulp isn't just a "crazy idea" - it is being recommended as a "getting started" tool for new frontend developers and judging from my Twitter and Reddit feeds more and more people are using it.

Looking closer at it I find that Gulp has a number of _default behaviors_ that fail a number of very basic tests of what I want out of a build system.

## What Happens on an Error?

Let's say you make a mistake in setting up your build.  For example maybe you have made the silliest of mistakes and specified the wrong directory.

```javascript
var gulp = require('gulp'),
    concat = require('gulp-concat');

gulp.task('js', function() {
  return gulp.src('css/**/*.js')
             .pipe(concat('vendor.js'))
             .pipe(gulp.dest('./dist/'));
});

```

Does gulp help you here?  **NO**.  It fails silently.  After all you have provided an empty set of files, which generates no stream data, and so the concatenated result of your build is an empty stream.  Working as intended.  It doesn't even generate the vendor.js file.

```
dave@margaret:~/scratch/gulp$ gulp build
[05:27:07] Using gulpfile ~/scratch/gulp/gulpfile.js
[05:27:07] Starting 'build'...
[05:27:07] Finished 'build' after 12 ms
dave@margaret:~/scratch/gulp$ ls -la dist/
total 8
drwxr-xr-x 2 dave dave 4096 Jan  7 05:26 .
drwxr-xr-x 6 dave dave 4096 Jan  7 05:26 ..
dave@margaret:~/scratch/gulp$
```

While this makes sense from its "everything is just a stream" point of view it is _extremely frustating_ to have a command `gulp build` exit with a status code of 0 but it has actually not done the work it is supposed to!  Hope you weren't acting on that gulp exit code to trigger anything that might go live for your users!

## Why is the Build Slow?

Gulp uses some [nifty filesystem magic](https://twitter.com/contrahacks/status/482326482359177217) to make sure that it's not processing too many files that it runs into operating system limits.  That's great but what happens if you have a set of gulp tasks that call out to another command-line utility (e.g. uglify.js)?  Because node.js is single-threaded you can only invoke [one of these at a time](https://github.com/terinjokes/gulp-uglify/issues/72)!  You may have a fancy 4 core MacBook Pro but by default your interface to these command line tools is being filtered through a single-threaded reactor that is controlled through some plugin that isn't even part of the core build system.  Hope every single one of your plugins supports using the parallelism that your build needs!

## Is Your Build Deterministic?

It seems a basic tenet that providing the same inputs to a build system should produce the same outputs.  Is this how gulp works?  No!  Directory order in Gulp is [nondeterministic](https://github.com/sindresorhus/gulp-rev/issues/58)!  Building the same input may produce an output with a completely different hash each time, based on how the gulp `vinyl-fs` wrapper file system responded.

This means that if you make a _server-side only_ change to your website, you should *still* upload new assets to S3 because your `gulp build` command returned a different set of files!

Can you easily roll back to an old developed version on your website?  Well `gulp build` on the reverted code appears to have returned different sha files for our main bundle files ... so I guess it's time to upload new assets.

I don't think this is a crazy demand.  Files being returned in a consistent order is the default behavior of both [Bash](http://serverfault.com/questions/122737/in-bash-are-wildcard-expansions-guaranteed-to-be-in-order) and Node's [`glob` library](https://github.com/isaacs/node-glob/blob/bc6458731a67f8864571a989906bc3d8d6f4dd80/test/readdir-order.js#L1).  Why is this not the default behavior of every build tool?

## Wrapper Libraries Everywhere

Files (on the filesystem!) are the basic building block of software development.  You code in files, you serve files from a web server, your editor uses files for configuration, your operating system uses files to know which services to start up on boot.  There is so much invested in utilities that operate on files and every developer productivity tool that you have has a mode to operate on a file in the filesystem.

Of course when it comes to your gulp build you don't get to use any of these command-line tools, because they may not have a node.js API or that API may not be event stream compatible.  You have to instead use a wrapper library that turns that command-line tool (that works perfectly well on its own) into a _stream_.

As an example, the [`gulp-webpack` plugin](https://github.com/shama/gulp-webpack/blob/849ab893c16bb31f103cb6e8439e0210dc8c6794/index.js) does the work of wrapping the webpack `node.js` API and turning it into a more idiomatic "gulp way" of doing executing.  If you're using this plugin and webpack releases a new command line argument - guess what, it's time to upgrade your plugin too so that you can access that argument in your build!

If you're using gulp, these plugins are _the way_ to get things done.  Almost every problem you have is solved by just adding another plugin - code over configuration.  But what problem are these plugins solving?  It's not to use Webpack, or Closure Compiler, or Uglify - it's to use these off the shelf tools with gulp.  I want my build system to help me use my tools rather than demand that I use other ones!

## Impedence Mismatch on Testing and Server-Side Code

Are your unit tests just a set of streams?  Well, you want to find all test files and then run them through your test runner, but that test runner is probably file based and don't really have an output other than a test report which is only valuable in the case that it fails, and the test report isn't really uploaded to be served to your users statically ... so ... probably no, tests don't really match a set of streams very well.

Is your server-side code a set of streams?  Well, as it's not served to clients through the website so - no, probably not there either.

Because there's not a lot of benefit to thinking about these essential components of your infrastructure as streams, gulp doesn't really give you any help here.  Because of this if you're using gulp for your build, you are either:

* Writing task-based build steps in a system that really isn't made for them
* Using another build system anyways

## Oh, You're Having a Problem?  Install Another Plugin

Of course the answer for each of my problems is to install a gulp plugin!  [gulp-expect-file](https://github.com/kotas/gulp-expect-file) lets you add assertions to your pipes so that you get files that you're expecting and not files that you're not expecting (for example, that your build actually produced a result).  [gulp-natural-sort](https://www.npmjs.com/package/gulp-natural-sort) rearranges your file streams so that files are sorted in a consistent order.  [gulp-plumber](https://www.npmjs.com/package/gulp-plumber) fixes the [default node.js pipe behavior](https://gist.github.com/floatdrop/8269868) to not break the pipe on error so that you can use `gulp watch` without needing to restart gulp all the time after generating a syntax error.

This may be just an useless cry of rage but I don't feel like I should have to install all these off-the-shelf plugins just to get a basic build utility working!  Event streams may be an awesome concept but I don't feel like I should need to deeply understand them just in order to generate an asset build.

## Please, Just Learn and Use Shell Scripts

I think I understand why people like Gulp - frontend builds all kind of look the same if you squint at them.  Build JS, build CSS, concatenate, minify, upload to CDN, all with various options that are project specific.  Because of this it's easy to find something that kind of works online, adapt it to your needs, and slowly add onto it with extra plugins.

So if you're not using Gulp what are you using instead?  Maybe this is the hipster answer but _just use shell scripts_.

* Use command line utilities without relying on wrapper plugins
* Full power of the UNIX command line - yes this isn't "just JavaScript" and it's definitely not code over configuration but these tools have been battle-tested for decades.  The knowledge you gain from putting your build into a shell script will help you be a more effective programmer.
* Full transparency as to what is going on - want to see what's happening?  just read your shell output.  Why is it slow?  Run everything through `time`.  Need to run two things at the same time? [GNU parallel](https://www.gnu.org/software/parallel/).

Rant over - go back to your day!