+++
title = "Dont Fear the Makefile"
date = 2018-02-12T18:15:29+01:00
publishDate= 2018-02-16T00:00:00+01:00
description = "A simple Makefile tutorial describing the basics and todays possible usage"
draft = false
categories = ["tech"]
tags = ["unix", "linux", "programming", "tutorial", "build-tools"]
keywords = ["unix", "linux", "programming", "tutorial", "build-tools"]
toc = true
images = [
	"/img/gnu.png"
] # overrides the site-wide open graph image
+++

---

![GNU Logo](/img/gnu.png "GNU Logo")


## Introduction

I'm writing this because I have the feeling that many developers underestimate 
the power of Makefiles and they are simply not aware of this nice and handy tool
which is installed on nearly every Unix-like machine.
To be honest, who have never executed a `make install` or something similar?
Most tutorials I've found out there are bloated with stuff, more complex than 
they would have to and you have to read pages after pages to get the basics. 

----

## IMPORTANT

Please use tabs when following these examples as make will complain when used 
with spaces as indentation.

---

## Targets 

A Makefile exists of targets. These targets are the ones you execute.
When you execute `make install` you trigger the `install` target of the Makefile,
when you run `make build` you trigger the `build` target.

A target can be as simply defined as:

{{<  highlight make >}}
# this is the target
install:
	# this will be executed when make install is called
	echo Hello World
{{< /highlight >}}

`install` is the target in this case and `echo Hello World` will be executed 
when you trigger this target.

These targets can also execute multiple commands like this:

{{<  highlight make >}}
# target
install:
	# will be executed first
	echo hello 
	# will be executed second
	echo World
{{< /highlight >}}

If one of the commands is false the Makefile will stop the execution:

{{<  highlight make >}}
# target
install:
	# will be executed first
	echo Hello 
	# will break here
	false
	# will not be executed
	echo World
{{< /highlight >}}

This will output:

{{<  highlight bash >}}
$ make install
# will be executed first
echo hello
hello
# will break here
false
make: *** [Makefile:6: install] Error 1
{{< /highlight >}}

You can see that in line 6 the error occurred.

---

## Dependents

So, but what is the cool thing about these targets? They remember when you have
executed them at last and only do this stuff again when the file is newer than
the last time you have called it. 
But for that, your target has to be a file.
Create a file `myfile.sh` and add a basic 

{{<  highlight bash >}}
#!/usr/bin/env bash 

echo Hello World
{{< /highlight >}}

Then create a `Makefile`:

{{<  highlight make >}}
# mytarget depends on myfile.sh
mytarget: myfile.sh
	# copy myfile.s to mytarget
	cp -f myfile.sh mytarget
{{< /highlight >}}

If everything is done correctly 
you will get this output when running `make mytarget`: 
`cp -f myfile.sh mytarget`. If you run it a second time you will see:
`make: 'mytarget' is up to date.`. You can try this as many times as you want.
If you now change the target, a simple `touch myfile` is enough since this 
updates the last touched timestamp from the file, it will redo the copying.

But you can of course not only depend on files, 
you can also depend on other targets. Watch this:

{{<  highlight make >}}
target2:
	cp myfile.sh target2
	echo Hello 

# target1 depends on target2
target1: target2
	echo World
{{< /highlight >}}

`target1` depends on `target2`, therefore `target2` is executed first.
What if `target1` depends on our former friend `myfile.sh`?

Check this out:

{{<  highlight make >}}
target2: myfile.sh
	cp myfile.sh target2

# target1 depends on target2
target1: target2
	echo World
{{< /highlight >}}

At the first run you get this as output as expected:

{{<  highlight bash >}}
$ make target1
cp myfile.sh target2
echo Hello
Hello
echo World
World
{{< /highlight >}}

But at the second run you only get this:

{{<  highlight bash >}}
$ make target1
echo World
World
{{< /highlight >}}

`target2` is already up to date so make doesn't have to rebuild this target.
When you touch `myfile.sh` or remove the `target2`-file you will get the output
of the former run. `target1` is no file, so sadly this `target` will be rebuild 
every time.

A target doesn't necessarily need to have a body. It could also only be dependent 
on other targets.
This would be valid:

{{<  highlight make >}}
target2: myfile.sh
	cp myfile.sh target2
target1: target2
{{< /highlight >}}

And runs the `cp` command when `make target1` is called.
Of course, this is most useful when one target is dependent on more than one
targets. For example:

{{<  highlight make >}}
all: lint test build

build: someFile
	buildCommand

test: someFile
	testCommand

lint: someFile
	someLintCommadn
{{< /highlight >}}

Now with `make all` everything is executed.
Or when you only want to execute build when the tests are passing:


{{<  highlight make >}}
all: lint test build

build: test someFile 
	buildCommand

test: someFile
	testCommand

lint: someFile
	someLintCommadn
{{< /highlight >}}

If one command returns `false` - or you simply write `false` the make process 
will be aborted there.

But, what if the target name is a folder?
Let's see, create a folder called dist: `mkdir dist`

{{<  highlight make >}}
dist: myfile.sh
	cp myfile.sh dist/myfile.sh
{{< /highlight >}}

Now run `make dist` and you will get what output?
If you have read this article carefully you should know whats going on.

{{<  highlight bash >}}
$ make dist
make: 'dist' is up to date.
{{< /highlight >}}
 
The `dist`-folder was created after the file `myfile.sh` was last touched. 
So make thinks `dist` was built after the last change of `myfile.sh` and should
be up to date. A simple `touch myfile.sh` is helping again. 

---

## PHONY

To rebuild a target every time it is called independent of last changes you
could add the special `.PHONY` keyword to that target.

{{<  highlight make >}}
.PHONY: dist
dist: myfile.sh
	cp myfile.sh dist/myfile.sh
{{< /highlight >}}

Now every time you run `make dist` it is redoing what it is told.

--- 

## Wildcards

There is a handy thing called wildcard. I think it does what everyone would
expect. For that create a bunch of `sh` files: `touch {1,2,3,4,5}.sh`

Adjust your makefile to this:

{{<  highlight make >}}
target: $(wildcard ./*.sh)
	touch target
{{< /highlight >}}

And after the first run, nothing is done, except you touch one of the shell 
scripts regardless which one.

---

## Variables

You could set variables inside the Makefile and use them.
For example:

{{<  highlight make >}}
ENTRY_FILE = Main.hs

test: $(ENTRY_FILE)
	testCommand

build: $(ENTRY_FILE)
	buildCommand

....
{{< /highlight >}}

Now you only need to change the `ENTRY_FILE` definition if the name of your
entry file should change. I think you can imagine many scenarios where this
could be useful.
Variables can be accessed with surround `$()`.

Of course, this can also be arrays. For this create two files: 
`touch file1 file2` and try this:

{{<  highlight make >}}
MY_FILES = file1 file2

myTarget: $(MY_FILES)
	echo should rebuild
	touch myTarget
{{< /highlight >}}

After the second turn, it doesn't rebuild. But touch one of both files and 
It will rebuild.

The Wildcard would be working as a variable too:

{{<  highlight make >}}
MY_FILES = $(wildcard ./*.sh)

myTarget: $(MY_FILES)
	echo should rebuild
	touch myTarget
{{< /highlight >}}

---

## Loops

Loops are also possible.
For example, if you have a bunch of binaries and want to compress them after 
building from `mybinaryX` to `mybinaryX.tar.gz`:

{{<  highlight make >}}
BINARIES = mybinary1 mybinary2 mybinary3

compress-all-binaries: build-all-binaries
	for f in $(BINARIES); do	  \
		tar czf $$f.tar.gz $$f;	\
	done
	@rm $(BINARIES)
{{< /highlight >}}


---

## Shell

You could even run shell commands or scripts from inside the Makefile.
For example something like this:

{{<  highlight make >}}
PROGNAME = Today
LOWER_PROGNAME = $(shell echo $(PROGNAME) | tr A-Z a-z)
{{< /highlight >}}

---

## Exports/$PATH

It's also possible to export variables, this is especially useful for something 
like the `$PATH`-variable. When you run JavaScript with npm-dependencies for 
example all dependencies which have a binary would be sym-linked into 
`./node_modules/.bin/` and you could do this:

{{<  highlight make >}}
# Add node_modules binaries to $PATH
export PATH := ./node_modules/.bin:$(PATH)
{{< /highlight >}}

Then you didn't have to put the full path before such a command, you could
simply call it like you would within an npm-script.

---

## if and else

What is also a really cool feature which I've learned last week is that you 
could natively use if and else statements in Makefiles.

For example, could I test if my Makefile was called with a specific 
environment variable like this:

{{<  highlight make >}}
# @ tells make to not print the command itself to stdout
# only the commands output
called-with-version:
ifeq ($(VERSION),)
	@echo No version information given.
	@echo Please run this command like this:
	@echo VERSION=1.0.0 make release
	@false
else
	@echo do some other stuff
endif
{{< /highlight >}}

This means if the variable `$(VERSION)`, which would be passed via an environment 
variable is empty execute the first block else the second.

There is also `ifneq` which means if not equal.

---

## Misc

- You need `tabs` as indentation in a Makefile else wise it will complain 
- If you put an `@` before any command the command itself will not be passed to
`stdout` but you will receive the output of this command.
- With the `-j` parameter you could run make with parallel execution
- The complete documentation can be found here: 
[Link](https://www.gnu.org/software/make/manual/html_node/index.html "GNU Make Documentation")

---

## Real-life Makefiles

Here are some real Makefiles I've written myself.
Some examples are taken from there but I think this can give you some 
inspiration how to use them in real projects.
They are sorted from simpler to more complex ones 
but that might change over time.

- [Today.hs Makefile](https://github.com/mstruebing/today.hs/blob/master/Makefile "Today.hs Makefile")
- [TLDR Makefile](https://github.com/mstruebing/tldr/blob/master/Makefile "TLDR Makefile")
- [Neos-UI Makefile](https://github.com/neos/neos-ui/blob/master/Makefile "Neos-UI Makefile")

