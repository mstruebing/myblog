+++
title = "Execute multiple commands on files with find"
date = 2016-11-04T06:36:06+02:00
publishDate= 2016-11-04T06:36:06+02:00
description = ""
categories = ["tech"]
tags = ["linux", "unix", "tutorial", "programming"]
keywords = ["linux", "unix", "tutorial", "programming"]
toc = false
+++

## Hello everybody

In this post I will show you how you can execute multiple commands on files via find.

Firstly how to use find:

{{<  highlight bash >}}
find -type f -iname "*.extension"
{{< /highlight >}}
This will find all files under the working dir with the given extension. Of course you can use other things like filesize, user who owns that file etc. But for that example I will using this.

For example if we have multiple .txt files in subdirectories we didn't want to execute the command on every file.
So if we want to print all the contents from this files we can simply write:
{{<  highlight bash >}}
find . -type f -iname "*.txt" -exec cat {}\;
{{< /highlight >}}

But what if we want to execute multiple commands on that files at once?

There are two methods, one is to execute the second one only if the first one is true, the second one is to execute both regardless if the first one was successful.

Execute both commands regardless of the first command:
{{<  highlight bash >}}
find . -name "*.txt" -exec cp {} . \; -exec mv {} {}.bak \;
{{< /highlight >}}
This will copy all files to the current directory and suffix the old ones with original filename to .bak.

I'm not good at thinking of examples so this time we will unzip files to the current directory and delete the zip only if the unzip was successful.

So this would be the command:
{{<  highlight bash >}}
find . -name "*.zip" \( -exec unzip {} -d . \; -o -exec true \; \) -exec rm {} \;
{{< /highlight >}}

Thanks four your patience, see you next time. ;)

### Update: 
You are also able to pipe your commands.
{{<  highlight bash >}}
find . -iname \*.c -exec sh -c "cat '{}' | less" \;
{{< /highlight >}}

And of course you can use a script to do what you want:
{{<  highlight bash >}}
find . -iname \*.c -exec xyz.sh {} \;
{{< /highlight >}}

Disadvantages of that is that you will spawn a new shell for each file, if you have a huge amount of files this will cause a performance loss.
