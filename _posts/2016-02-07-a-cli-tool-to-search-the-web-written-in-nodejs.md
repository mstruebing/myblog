---
layout: post
title: "A CLI-tool to search the web written in nodejs"
date: 2016-02-06 20:55:07
description: I have written a CLI-tool to search the web with different providers in nodejs.
tags: nodejs cli javascript
---

# Hello everybody

[I have written a CLI-tool to search the web with different providers in nodejs.](https://github.com/mstruebing/web-s)

Firstly I must admit that I get the idea from somewhere else: [z](https://github.com/zquestz/s).

I have done this with gulp and babel. Where I used a boilerplate from Airbnb.

I want to share it with you and would ask for feedback.
I would love if you can say me what I can improve on this, what new features I should implement or what is shitty.

Also I think pull requests are welcome although I'm doing it on a learning purpose.

If you have nodejs installed you can simply do a `sudo npm i -g web-s` to install it.
`web-s --help` or `web-s -h` will show you the usage information.

Currently are 4 search engines implemented: google(as default), reddit, stackoverflow and twitter.

If you want other additional search engines let me know.

Eventually I will implement a config file where someone can simply add new providers, but I'm not sure if this is needed.

Of course I want to add tests with mocha and chai shortly, but somehow I didn't manage to develop test driven.

The only dependency is, besides gulp, babel, mocha and chai stuff, open - a library to open the default webbrowser.

[Here is the link to the github repository.](https://github.com/mstruebing/web-s)

The main code is here, nothing special if you didn't want to see it on github.

{% highlight javascript linenos %}
#!/usr/bin/env node

import open from 'open';

const ALL_ARGS = 0;
const ALL_EXCEPT_FIRST_ARG = 1;

const searchEngines = {
  google: {
    url: 'https://www.google.com/search?q=',
    args: ALL_ARGS,
    shortHand: 'default',
  },
  twitter: {
    url: 'https://twitter.com/search?src=typd&q=%23',
    args: ALL_EXCEPT_FIRST_ARG,
    shortHand: 't',
  },
  reddit: {
    url: 'https://www.reddit.com/search?q=',
    args: ALL_EXCEPT_FIRST_ARG,
    shortHand: 'r',
  },
  stackoverflow: {
    url: 'http://stackoverflow.com/search?q=',
    args: ALL_EXCEPT_FIRST_ARG,
    shortHand: 's',
  },
};

/**
 * list all available providers
 * @param  {String} space the space in front of the output
 * @return {void}
 */
function listProviders(space) {
  Object.keys(searchEngines)
    .map(provider => (
        searchEngines[provider].shortHand === 'default'
        ? `${space}${provider} (default)`
        : `${space}${provider}: -${searchEngines[provider].shortHand}/--${provider}`
      ))
    .forEach(line => console.log(line));
}

/**
 * prints the usage and optional an error
 * @param  {string} err the error to print
 * @return {void}
 */
function printUsage(err) {
  if (err) {
    console.error('ERROR:', err);
  }
  console.log('USAGE: web-s [provider] <searchstring>');
  console.log('Available providers:');
  listProviders('  ');

  // return with exit status 1 if an error occured
  if (err) {
    process.exit(1);
  }
}

/**
 * joins the arguments dependent on the provider and opens the default webbrowser
 * @param  {object} provider
 * @param  {array} args the cli arguments
 * @return {void}
 */
function openBrowser(provider, args) {
  let url = 0;

  if (provider.args === ALL_ARGS) {
    url = provider.url + args.join(' ');
  } else if (provider.args === ALL_EXCEPT_FIRST_ARG) {
    url = provider.url + args.slice(1).join(' ');
  }

  if (url) {
    open(url);
  }
}

/**
 * Parses the arguments and invokes the needed functions
 * @param  {Array} args the arguments
 * @return {void}
 */
function parseArguments(args) {
  switch (args[0]) {
    case '-l':
    case '--list': listProviders(''); break;
    case '-h':
    case '--help': printUsage(); break;
    case '-r':
    case '--reddit': openBrowser(searchEngines.reddit, args); break;
    case '-s':
    case '--stackoverflow': openBrowser(searchEngines.stackoverflow, args); break;
    case '-t':
    case '--twitter': openBrowser(searchEngines.twitter, args); break;
    default: openBrowser(searchEngines.google, args);
  }
}

if (process.argv.length >= 3) {
  parseArguments(process.argv.slice(2));
} else {
  printUsage('No searchstring');
}
{% endhighlight %}
