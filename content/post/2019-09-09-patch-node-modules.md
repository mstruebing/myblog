+++
title = "Using Elm inside create-react-app or: How to properly patch your `node_modules`"
date = 2019-09-09T18:15:29+01:00
publishDate= 2019-09-09T00:00:00+01:00
description = "This article describes how you could use Elm inside a create-react-app and how you could patch your `node_modules` in a proper, reusable way."
draft = false
categories = ["tech"]
tags = ["nodejs", "node", "javascript", "js", "elm", "elmlang","programming", "tutorial"]
keyword = ["nodejs", "node", "javascript", "js", "elm", "elmlang","programming", "tutorial"]
toc = true
images = [
	"/img/patch.png"
]
+++

---

![patch](/img/patch.png/ "patch")

## Introduction

In this Blog-post we will use 
[create-react-app](https://github.com/facebook/create-react-app) to demonstrate 
how you could use [Elm](https://elm-lang.org/) inside and while doing that 
how to patch your `node_modules` in a reusable way by using 
[patch-package](https://www.npmjs.com/package/patch-package).

## Create Application

We will create a react-app with 

{{<  highlight bash >}}
npx create-react-app elm-react-app
{{</  highlight >}} 

This gives us a basic react-app with everything out of the box.
Note that we are using `react-scripts` at version 3.1.1 here, future versions 
might have different line numbers we are using later on.

## Install Elmish-dependencies


Switch into your newly created react-app with `cd elm-react-app`.
We will use [elm](https://www.npmjs.com/package/elm) so that you don't need to 
install Elm globally on your system. We will also use 
[react-elm-components](https://www.npmjs.com/package/react-elm-components) to 
use Elm inside our react components.

{{<  highlight bash >}}
yarn add --dev elm && \
yarn add react-elm-components
{{</  highlight >}}

## Initialize Elm 

We now want to initialize the Elm part of our project. Think of it as a 
`package.json` for Elm. We can do this by running: `./node_modules/.bin/elm init`.
The initializer will ask if you are already familiar with Elm and provides you 
with a link in case you want to read how you can use Elm. Let's assume we 
already know and press `Y`. :)  
This gives us an `elm.json` file which lists our dependencies, source directory,
Elm version and type, which is in this case "application". There is also "package"
if you want to write a library, but that's nothing we want to do right now.
We need to add `elm-stuff` to our `.gitignore` which will contain some build files 
you don't want to touch and should not be in your vcs:

{{<  highlight bash >}}
echo "elm-stuff" >> .gitignore
{{</  highlight >}}

## Add an Elm component

We will add a simple Hello-World as an Elm-component but keep in mind that this 
could be anything like real complex Elm applications.

Let's create an Elm file:

{{<  highlight bash >}}
touch src/Hello.elm
{{</  highlight >}}

Open that file with your editor of choice and add this code:

{{<  highlight elm >}}
-- src/Hello.elm
module Hello exposing (main)

import Html exposing (Html, text)


main : Html msg
main =
    text "Hello!"
{{</  highlight >}}

Now we need to use that component inside our react application. We use our 
prior added dependency `react-elm-components`. Let's add our Elm-component 
right after the logo:

{{<  highlight javascript >}}
// src/App.js
/* imports */
import Elm from 'react-elm-components';
import MyElmComponent from './Hello.elm';

/* other create-react-app-code */
  <header className="App-header">
    <img src={logo} className="App-logo" alt="logo" />
    <Elm src={MyElmComponent.Elm.Hello} />
/* other create-react-app-code */
{{</  highlight >}}

If we now start the server with `yarn start` we can see that our "Hello" is not 
rendered.

## Patching the webpack configuration to load Elm files correctly

That is because the default webpack configuration of create-react-app doesn't 
know how to read Elm files.
We have different options now. We could either:

* Eject our create-react-app with `yarn eject` 
    but that would remove our updating capabilities from create-react-app
* Fork create-react-app and modify the configuration there
    that would allow us to update with rebasing our fork, but in 
    my experience, you will never really update because you are not forced to and 
    you probably forget about it.
* We use a cool package which makes patching `node_modules` very easy

As you've might guess we use the third option. We edit the webpack configuration 
of create-react-app directly inside the `node_modules` for now.
For that open `node_modules/react-scripts/config/webpack.config.js` in your editor 
of choice and jump to line 372. There you can see the different loaders which are 
provided by create-react-app by default. We want to add our Elm loader which we 
at first need to install:

{{<  highlight bash >}}
yarn add --dev elm-webpack-loader
{{</  highlight >}}

You can add the loader directly as the first item in the array:

{{<  highlight js >}}
// node_modules/react-scripts/config/webpack.config.js
// load our elm files with the correct loader
{
  test: /\.elm$/,
  exclude: [/elm-stuff/, /node_modules/],
  use: 'elm-webpack-loader'
}, // trailing comma in case there are other items in the array ;)
{{</  highlight >}}

If you now start your application with `yarn start` you should see the "Hello"
from your Elm component. That is working fine for now, but as soon as we install 
or uninstall a different dependency or a coworker wants to set up the project our 
changes are lost. To make this work we use the `patch-package` tool:

{{<  highlight bash >}}
npx patch-package react-scripts
{{</  highlight >}}

We call `patch-package` with the `node_modules` dependency where we've made 
changes to.

The output of this shows:

{{<  highlight bash >}}
npx patch-package react-scripts
npx: installed 211 in 7.952s
patch-package 6.1.4
• Creating temporary folder
• Installing react-scripts@3.1.1 with yarn
• Diffing your files with clean files
✔ Created file patches/react-scripts+3.1.1.patch
{{</  highlight >}}

At the bottom you can see that `npx` created a file 
`patches/react-scripts+3.1.1.patch`.

If we look at it it is exactly a normal patch file like 
[patch](https://en.wikipedia.org/wiki/Patch_(Unix)) would give us.

{{<  highlight bash >}}
cat patches/react-scripts+3.1.1.patch
{{</  highlight >}}

{{<  highlight diff >}}
diff --git a/node_modules/react-scripts/config/webpack.config.js b/node_modules/react-scripts/config/webpack.config.js
index 12157a3..3d3d2d2 100644
--- a/node_modules/react-scripts/config/webpack.config.js
+++ b/node_modules/react-scripts/config/webpack.config.js
@@ -370,6 +370,12 @@ module.exports = function(webpackEnv) {
           // match the requirements. When no loader matches it will fall
           // back to the "file" loader at the end of the loader list.
           oneOf: [
+            // load our elm files with the correct loader
+            {
+              test: /\.elm$/,
+              exclude: [/elm-stuff/, /node_modules/],
+              use: 'elm-webpack-loader'
+            },
             // "url" loader works like "file" loader except that it embeds assets
             // smaller than specified limit in bytes as data URLs to avoid requests.
             // A missing `test` is equivalent to a match.
{{</  highlight >}}

This file should be added to your version control as you will need it to run your 
project. Now, in order to automate some things we add a `postinstall` script to our 
`package.json`:

{{<  highlight json >}}
{
  /* ... */
  "scripts": {
    "start": "react-scripts start",
    "build": "react-scripts build",
    "test": "react-scripts test",
    "eject": "react-scripts eject",
    "postinstall": "patch-package"
  },
  /* ... */
}
{{</  highlight >}}

This will automatically call `patch-package` when we install a dependency.
Of course we need to add the `patch-package` dependency at first to our project:

{{<  highlight bash >}}
yarn add --dev patch-package
{{</  highlight >}}

As we are using yarn we need to use the 
[postinstall-postinstall](https://www.npmjs.com/package/postinstall-postinstall) 
package because yarn only runs the `postinstall` hook after a `yarn add` or 
`yarn install` but not after a `yarn remove`.

{{<  highlight bash >}}
yarn add --dev postinstall-postinstall
{{</  highlight >}}

Now, if you run `yarn start` you should still see the "Hello" from our Elm 
component. If you now remove the `node_modules` and reinstall them you should 
still be able to see it because `patch-package` takes care of patching our 
`node_modules`.

{{<  highlight bash >}}
rm -rf node_modules && \
yarn install && \
yarn start
{{</  highlight >}}

## Closing

That's all and I think that this is a good way to patch your `node_modules` if 
you really have to. Of course, if it would make sense for the upstream package 
to have this change it would be better way to fork and make a pull request and 
use your fork until the pull request is merged and released. But sometimes it 
doesn't make sense to have it upstream, like in this example, it wouldn't make 
sense for create-react-app to have an Elm loader configured.

You can see the full example on 
[GitHub](https://github.com/mstruebing/create-react-app-with-elm)
