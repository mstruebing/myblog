---
layout: post
title: "Extending the CLI-search"
date: 2016-02-06 20:55:07
description: I have extended the CLI-tool(web-s) with editable config file.
tags: nodejs cli javascript
---

# Hello everybody
<a href="https://github.com/mstruebing/web-s" target="blank">I have written a CLI-tool to search the web with different providers in nodejs.</a>

Now I have extended this so that you have a config file in your home directory called `.web-s.conf`.
This is a simple JSON text file in which your search providers are stored.

You can simply extend this file with own providers.
You should follow the convention like the already implement providers, I didn't have proper error handling at the moment. Just add `%HERE%` at the position where your arguments should go into the searchstring.
So the shortHand is how you can call the provider via the CLI (-shortHand) or you can use its full name (--provider).

Also important is that only one provider with the shortHand default should existing at the moment.

If you meesed up your config simply delete the file `~/.web-s.conf` or use `web-s --generate-config`, this will delete your config and create a new one.

The config file is read by the tool and `web-s --list` will get the providers from the config.

To install the tool you simply do `sudo npm install -g web-s` and it is done.

**If you have any critic, support, feedback you are welcome. :)**

The full code:

{% highlight javascript linenos %}
#!/usr/bin/env node

import open from 'open';
import fs from 'fs';

const CONFIG_FILE = `${process.env.HOME}/.web-s.conf`;

const initConfig = {
  google: {
    url: 'https://www.google.com/search?q=%HERE%',
    shortHand: 'default',
  },
  twitter: {
    url: 'https://twitter.com/search?src=typd&q=%23%HERE%',
    shortHand: 't',
  },
  reddit: {
    url: 'https://www.reddit.com/search?q=%HERE%',
    shortHand: 'r',
  },
  stackoverflow: {
    url: 'http://stackoverflow.com/search?q=%HERE%',
    shortHand: 's',
  },
  leo: {
    url: 'http://dict.leo.org/ende/index_de.html#/search=%HERE%',
    shortHand: 'l',
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
}

/**
 * joins the arguments dependent on the provider and opens the default webbrowser
 * @param  {object} provider
 * @param  {array} args the cli arguments
 * @return {Boolean}
 */
function openBrowser(provider, args) {
  let url = 0;

  if (provider.shortHand === 'default') {
    url = provider.url.replace('%HERE%', args.join(' '));
  } else {
    url = provider.url.replace('%HERE%', args.slice(1).join(' '));
  }

  if (url) {
    open(url);
  }

  return true;
}

/**
 * Parses the arguments and invokes the needed functions
 * @param  {Array} args the arguments
 * @return {void}
 */
function parseArguments(args) {
  switch (args[0]) {
    case '--generate-config': generateNewConfig(); break;
    case '--list': listProviders(''); break;
    case '-h':
    case '--help': printUsage(); break;
    default: detetermineProvider(args);
  }
}


/**
 * checks with provider should be used
 * @param  {Array} args
 * @return {void}
 */
function detetermineProvider(args) {
  let opened = false;
  let defaultProvider = false;

  Object.keys(searchEngines).forEach((provider) => {
    if (`-${searchEngines[provider].shortHand}` === args[0] || `--${provider}` === args[0]) {
      opened = openBrowser(searchEngines[provider], args);
    }
    if (`${searchEngines[provider].shortHand}` === 'default') {
      defaultProvider = provider;
    }
  });

  if (!opened) {
    openBrowser(searchEngines[defaultProvider], args)
  }
}


/**
 * Generates a new config-file
 * @return {void}
 */
function generateNewConfig() {
  if (configExist()) {
    fs.unlinkSync(CONFIG_FILE);
  }

  createInitConfig();
}


/**
 * checks if a config exists
 * @return {Boolean}
 */
function configExist() {
  let fileExist = false
  try {
    fileExist = fs.statSync(CONFIG_FILE).isFile();
  } finally {
    return fileExist;
  }
}


/**
 * creates a sample config
 * @return {void}
 */
function createInitConfig() {
  const config = JSON.stringify(initConfig, null, 2);
  fs.writeFile(CONFIG_FILE, config);
}

/**
 * reads the config file
 * @return {Object}
 */
function readConfig() {
  return JSON.parse(fs.readFileSync(CONFIG_FILE, 'utf8'));
}

let searchEngines;

if (!configExist()) {
  createInitConfig();
  searchEngines = initConfig;
} else {
  searchEngines = readConfig();
}

if (process.argv.length >= 3) {
  parseArguments(process.argv.slice(2));
} else {
  printUsage('No searchstring');
}

{% endhighlight %}
