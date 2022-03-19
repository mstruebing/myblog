+++
title = "The Power of the XDG Base Directory Specification"
date = 2019-12-06T18:15:29+01:00
publishDate= 2019-12-06T00:00:00+01:00
description = "This article is about the XDG Base Directory Specification and why it is useful"
draft = false
categories = ["tech"]
tags = ["xdg", "standards"]
keyword = []
toc = true
images = [
	"/img/freedesktop.png"
]
+++

---

![freedesktop org](/img/freedesktop.png "freedesktop org")

## XDG Base Directory Specification

I'm writing this article because I have the feeling that not many people knows
about this convention even if it exists for years and can lead to a very clear
directory structure and file paths instead of a cluttered home directory with
thousands of files.

## The issue?

Everyone knows that feeling, you type an `ls -la` in your home directory,
or something similar which lists also hidden files and you get back a **huge**
list of files where you have no idea what it is, where it came from and what it
does. The problem is that most programs simply use your home directory as a
data storage for any kind of data. That leads to exactly this problem, no one
has an overview of their home directory anymore. When I run `ls -la | wc -l`
I get 109 files and/or directories and I even clean it up regularly.

## XDG Base Directory Specification to the rescue

The XDG Base Directory Specification is a widely used specification which
specifies where your files should be located depending on their usage published
by the freedesktop.org-organization.

But what is freedesktop.org?

freedesktop.org, formerly known as X Desktop Group (XDG), is an organization
which has many open source projects including the X Window System, Wayland or
systemd.

## What does the specification say?

They published a specification which mainly consists of three important points:

- Write user-specific data in `$XDG_DATA_HOME`
- Write configuration files in `$XDG_CONFIG_HOME`
- Write cache files in `$XDG_CACHE_HOME`

If these environment variables are not set, the specification says it should go
in these directories:

- `$XDG_DATA_HOME` should be `$HOME/.local/share`
- `$XDG_CONFIG_HOME` should be `$HOME/.config`
- `$XDG_CACHE_HOME` should be `$HOME/.cache`

They are also writing about other things like `$XDG_RUNTIME_DIR` which is used
for communication and synchronization, `$XDG_CONFIG_DIRS` which is used to
indicate where configuration files should be searched and `$XDG_DATA_DIRS` which
is used to search for data files.

But for me, the main points are the three from above.

What you will do is you will read the environment variable, if it is present use
this directory or use the fallback, create a directory with your program name in
it, it should be relatively unique to not clash with programs of the same name.
Save data there.

1. Read environment variable or use fallback
2. Create a directory with your program name in this directory
3. Place your caching/data/configuration files there.

As this is very common among Unix systems and also partly adapted in
Windows (at least as far as I know) you really should consider using it.
This has the advantage that if you search for configuration files for program x you will
look either in your custom set `$XDG_CONFIG_HOME/x` or in `$HOME/.config/x`,
because you know it will be there. Similarly, you will know where data files
(sound files, datasets, save points, ...) or caching files will be located.

So, if you will ever write a tool which needs some configuration files, caching
files or data files remember this specification, look it up again and implement
a proper way to handling these cases rather than cluttering the `$HOME` of your
users. If don't want to do it yourself you could also use a library for that,
there is a library for every major programming language out there.

The full specification can be read here:
https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html
