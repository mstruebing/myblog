+++
title = "Why I like wc"
date = 2017-01-13T06:36:06+02:00
publishDate= 2017-01-13T06:36:06+02:00
description = ""
categories = ["tech"]
tags = ["why-i-like", "unix", "linux", "programming"]
keywords = ["why-i-like", "unix", "linux", "programming"]
toc = false
+++

Wc is a small handy tool which I use often.
I'm calling it word-count in my head.(Today I learned by looking wc up on Wikipedia: it is actually called word count)
It is part of the [GNU coreutils](https://www.gnu.org/software/coreutils/coreutils.html) it should be on nearly any system.

What can you do with wc? With wc you can simply count lines, words or characters of a file or string, and thats it. Nothing more or less.

`wc -c` will give you the number of characters.    
`wc -w` will give you the number of words.     
`wc -l` will give you the number of lines.     

**c** - characters, **w** - words, **l** - lines.

The needed parameters are really intuitive.

Examples:

`wc -c <FILE>` will give you the character count in that file and puts the filename aside  
`cat <FILE> | wc -c` will give you only the character count

This is exactly the same for the other parameters.

`wc -w <FILE>` will give you the word count in that file and puts the filename aside  
`cat <FILE> | wc -w` will give you only the word count
Sample:

`wc -l <FILE>` will give you the line count in that file and puts the filename aside  
`cat <FILE> | wc -l` will give you only the line count

If you just call `wc` it will mix them up.
You get three numbers and the filename:

{{<  highlight bash >}}
$ wc .zshrc
 112  463 3628 .zshrc
{{< /highlight >}}

The first is the line count, the second is the word count and the last is the character count.

Wc isn't anything special, it just does one thing well like the most unix tools.

What I sometimes do for example is to check of many lines of code I have written in a project for example to get the LOC of all java files:

{{<  highlight bash >}}
$ wc -l **/*.java
  109 main/java/homework/mstruebing/app/App.java
   81 main/java/homework/mstruebing/app/domain/model/Config.java
   75 main/java/homework/mstruebing/app/domain/model/Password.java
   49 main/java/homework/mstruebing/app/domain/model/PasswordList.java
   47 main/java/homework/mstruebing/app/domain/model/User.java
  130 main/java/homework/mstruebing/app/domain/repository/ConfigRepository.java
   10 main/java/homework/mstruebing/app/domain/repository/PasswordListRepository.java
   10 main/java/homework/mstruebing/app/domain/repository/PasswordRepository.java
   11 main/java/homework/mstruebing/app/domain/repository/RepositoryInterface.java
   74 main/java/homework/mstruebing/app/domain/repository/Repository.java
   21 main/java/homework/mstruebing/app/domain/repository/UserRepository.java
   74 main/java/homework/mstruebing/app/service/ConfigService.java
   94 main/java/homework/mstruebing/app/service/DatabaseService.java
   86 main/java/homework/mstruebing/app/service/EncryptionService.java
   38 test/java/homework/mstruebing/app/AppTest.java
   62 test/java/homework/mstruebing/app/EncryptionServiceTest.java
  971 total
{{< /highlight >}}

But what it is also really handy for is to analyze log files.
Lastly I had to make tons of API calls which sometimes returned an error.
I created a log file which was simply like `starting api call x of xx` and if an error occurred I logged `ERROR: <MEANINGFULL-ERROR-MESSAGE>`
That gives me the possibility to grep for `ERROR` for example to know how many API calls had failed.

{{<  highlight bash >}}
cat <LOGFILE> | grep ERROR | wc -l
{{< /highlight >}}

And I could also grep for specific error messages and count them because of the specific error message I logged after the error.

So that's it, I think there is nothing more to say about wc.


Additional information:
[Man page of wc](https://linux.die.net/man/1/wc)

The full help text:

{{<  highlight bash >}}
$ wc --help
Usage: wc [OPTION]... [FILE]...
  or:  wc [OPTION]... --files0-from=F
Print newline, word, and byte counts for each FILE, and a total line if
more than one FILE is specified.  A word is a non-zero-length sequence of
characters delimited by white space.

With no FILE, or when FILE is -, read standard input.

The options below may be used to select which counts are printed, always in
the following order: newline, word, character, byte, maximum line length.
  -c, --bytes            print the byte counts
  -m, --chars            print the character counts
  -l, --lines            print the newline counts
      --files0-from=F    read input from the files specified by
                           NUL-terminated names in file F;
                           If F is - then read names from standard input
  -L, --max-line-length  print the maximum display width
  -w, --words            print the word counts
      --help     display this help and exit
      --version  output version information and exit

GNU coreutils online help: <http://www.gnu.org/software/coreutils/>
Full documentation at: <http://www.gnu.org/software/coreutils/wc>
or available locally via: info '(coreutils) wc invocation'
{{< /highlight >}}
