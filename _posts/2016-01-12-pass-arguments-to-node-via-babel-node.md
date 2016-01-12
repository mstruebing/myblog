---
layout: post
title: "Pass arguments to node via babel-node"
date: 2015-12-20 00:23:07
description: I came across a problem that arguments given to node via babel-node prefixed with -- are not passed
tags: me
---

# Hello everybody

I came across a problem that arguments given to node via babel-node prefixed with `--` are not passed

I'm building a nodejs app with babel-node to use import for example.
I have a package.json with the following script:
`"start": "babel-node index.js"`

It was working well until I want to pass an argument with the `--` prefix.
Namely: `--delete` - `npm start --delete`
When I used delete the arguments were passed.
`npm start delete`

A workaround for this without touching the current toolchain is only to pass arguments which are prefixed with `--`
via `npm start -- --argument`.
Then `--argument` is passed to node.
