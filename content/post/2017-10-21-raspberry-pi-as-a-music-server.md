+++
title = "Raspberry Pi as a Music Server"
date = 2017-10-31T14:37:20+02:00
publishDate= 2017-10-31T14:37:20+02:00
description = "How I set up my Raspberry Pi as a simple music server"
draft = false
categories = ["tech"]
keywords = ["raspberry", "rpi", "music", "server", "mopidy", "mopify"]
tags = ["raspberry", "rpi", "music", "server", "mopidy", "mopify"]
toc = true
images = [
    "/img/mopidy/mopidy_mopify_connected.png"
] # overrides the site-wide open graph image
+++

--- 

## Introduction

I've finally managed to get a Raspberry Pi. I've already thought a long time of buying one,
but because of missing ideas what to do with it I didn't buy one.
A school project came by which served the perfect reason to finally buy one (hint: self made monitoring camera)
and now I'm lucky to have one.

---

## Mopidy and stuff

So what is running on my RPI now?
Currently there is a raspian installed and except the whole music-server-software nothing special.
I run [mopidy](https://www.mopidy.com/) with [mopidy-spotify](https://github.com/mopidy/mopidy-spotify), [mopidy-spotify-tunigo](https://github.com/trygveaa/mopidy-spotify-tunigo) and [mopidy-mopify](https://github.com/dirkgroenen/mopidy-mopify).

So what are all these things?
Mopidy is a mpd server which simply stands for music player daemon.
On there website is written: 

> Mopidy is an extensible music server written in Python.

And thats it, no more no less. Without anything else mopidy can play music from your disk.
Mopidy-spotify is the bridge between mopidy and spotify which enables you to play all kind of things 
from spotify. You can play and manage your play lists, favourite artists, songs, albums and search for all these things.
Mopidy-spotify-tunigo is to enable the browse feature of spotify, like genres, browse featured play lists or new releases.
Mopidy-mopify is just a web front end to interact with mopidy in the style of spotify. This way I can control mopidy via a browser from every device on my network.
There are tons of other web front ends out there for mopidy you can have a look [here](https://docs.mopidy.com/en/latest/ext/web/).
It is also possible to connect via a CLI-client. I often just use [ncmpcpp](https://github.com/arybczak/ncmpcpp) which is a very wide used terminal music player.
Ncmpcpp simply stands for [ncurses](https://en.wikipedia.org/wiki/Ncurses) music player written in C++. 
There is also [ncmpc](https://github.com/MusicPlayerDaemon/ncmpc) which is not so feature rich.

---
## Hands on

So what do we have to do to get this all to work?

Surprisingly not much. I've installed it two times - because the first time I've fucked up - and the second time took me only one hour, including the installation of the operating system.

I assume that raspian is already set up correctly.

What we have to do to install mopidy:

{{<  highlight bash >}}
# add the gpg key of the archive
wget -q -O - https://apt.mopidy.com/mopidy.gpg | sudo apt-key add -
# add the repository to your package sources
sudo wget -q -O /etc/apt/sources.list.d/mopidy.list https://apt.mopidy.com/jessie.list
# update your package sources
sudo apt-get update
# install mopidy
sudo apt-get install mopidy
{{< /highlight >}}

Now we should set some configuration on `/etc/mopidy/mopidy.conf`.
There should be a default configuration file already in place.
Either add oder adjust these lines under http like this:

{{<  highlight bash >}}
[http]
enabled = true
hostname = 0.0.0.0
port = 6680
{{< /highlight >}}
<sub>/etc/mopidy/mopidy</sub>

This tells mopidy to enable the http extension. `0.0.0.0` tells mopidy to accept connections from every hostname/ip and the port is self describing.

Now we need the local ip address of the Raspberry Pi.
To get it simply type `ifconfig` in your terminal on your Raspberry Pi.

The output should be something like this:

{{<  highlight bash "linenos=inline,hl_lines=2 20" >}}
eth0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 192.168.2.115  netmask 255.255.255.0  broadcast 192.168.2.255
        inet6 fe80::e1f5:a318:5a1:faae  prefixlen 64  scopeid 0x20<link>
        ether b8:27:eb:f5:35:39  txqueuelen 1000  (Ethernet)
        RX packets 122946  bytes 108989790 (103.9 MiB)
        RX errors 0  dropped 6  overruns 0  frame 0
        TX packets 69604  bytes 45306826 (43.2 MiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

lo: flags=73<UP,LOOPBACK,RUNNING>  mtu 65536
        inet 127.0.0.1  netmask 255.0.0.0
        inet6 ::1  prefixlen 128  scopeid 0x10<host>
        loop  txqueuelen 1  (Local Loopback)
        RX packets 101  bytes 10202 (9.9 KiB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 101  bytes 10202 (9.9 KiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

wlan0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 192.168.2.112  netmask 255.255.255.0  broadcast 192.168.2.255
        inet6 fe80::8e77:ec92:7756:4074  prefixlen 64  scopeid 0x20<link>
        ether b8:27:eb:a0:60:6c  txqueuelen 1000  (Ethernet)
        RX packets 9013  bytes 724165 (707.1 KiB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 1539  bytes 133713 (130.5 KiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
{{< /highlight >}}
<sub>ifconfig</sub>

In line two, after inet, you see it's ip. If you connect via wireless lan it would be in line 29.

If you now type `sudo service mopidy start` into your terminal and head to `192.168.2.115:6680` in this case. I will use this ip address in the rest of this article. 
Just exchange it for you ip. 

You should already be able to see this:

<a href="/img/mopidy/mopidy_clean.png" target="_blank"><img class="lazyload" data-src="/img/mopidy/mopidy_clean_780px.png" alt="mopidy http screen" title="mopidy"></a>

--- 

At next we want to install `mopidy-spotify` 

{{<  highlight bash >}}
sudo apt-get install mopidy-spotify
{{< /highlight >}}

We need to adjust our mopdiy configuration again.
Just add these lines at the end ofthe file.

{{<  highlight bash >}}
[spotify]
enabled = true
username = <your spotify username>
password = <your spotify password>
client_id = <your client id>
client_secret = <your client secret>
{{< /highlight >}}
<sub>/etc/mopidy/mopidy</sub>

The client id and secret is easily obtainable via  [this link](https://www.mopidy.com/authenticate/#spotify). Click on login with spotify and after you logged in the data appears in the text field. 
If you want to configure more like the amount of search results for example have look at the [readme](https://github.com/mopidy/mopidy-spotify#configuration) of the mopidy-spotify.

---

Now we want to install `spotify-tunigo`:

{{<  highlight bash >}}
sudo apt-get install mopidy-spotify-tunigo
{{< /highlight >}}

The configuration is rather simple:

{{<  highlight bash >}}
[spotify_tunigo]
enabled = true
{{< /highlight >}}
<sub>/etc/mopidy/mopidy</sub>

---

Now all we need is `mopify`:

We need `pip` for that - the python package manager-  but fortunately raspian has it already installed.

{{<  highlight bash >}}
sudo pip install Mopidy-Mopify
{{< /highlight >}}

If it's not already installed on your system you can install it on an ubuntu like system with:

{{<  highlight bash >}}
sudo apt-get install python-pip
{{< /highlight >}}


Again a really simple configuration:

{{<  highlight bash >}}
[mopify]
enabled = true
debug = false
{{< /highlight >}}
<sub>/etc/mopidy/mopidy</sub>

And everything should be set up correctly.

Now restart mopidy as a service: `sudo service mopidy restart`.

Open your browser again at `192.168.2.115:6680/mopidy`.

<a href="/img/mopidy/mopidy_mopify_clean.png" target="_blank"><img class="lazyload" data-src="/img/mopidy/mopidy_mopify_clean_780px.png" alt="mopidy http screen with mopify" title="mopidy with mopify"></a>

We can see that `mopify` is set up correctly. Click on it and see:

<a href="/img/mopidy/mopidy_mopify_unconnected.png" target="_blank"><img class="lazyload" data-src="/img/mopidy/mopidy_mopify_unconnected_780px.png" alt="mopidy http screen with mopify unconnected" title="mopidy with mopify unconnected"></a>

Go to `services` in the navigation and enable the sync service by simply clicking on it.
When you hover over it you can go to settings and enable synchronization of your spotify credentials as well.
Next enable the spotify service, maybe you have to log in again.

And that's it. If you now go to `192.168.2.115:668/mopify` you should see some cool stuff like this:

<a href="/img/mopidy/mopidy_mopify_connected.png" target="_blank"><img class="lazyload" data-src="/img/mopidy/mopidy_mopify_connected_780px.png" alt="mopidy http screen with mopify connected" title="mopidy with mopify connected"></a>

---

__If you didn't see the welcome screen to load playlists and in the bottom left corner that spotify is disconnected you just need to reload if your sync settings are set up correctly__ 
 
---

If you want to connect via ncmpcpp to your Raspberry Pi you just need to run: `ncmpcpp --host 192.168.2.115 --port 6680` or set some config values for ncmpcpp.

---

Now to test your sound simply put speakers or headphones in the 3.5mm audio output.
Then type: `aplay /usr/share/alsa/speaker-test/sample_map.csv` If you can hear something everything is fine,
if not try to run `sudo raspi-config` go to advanced options, audio and force the output through the headphone jack.

If this is working your should be able to simply play sound through mopify. :)

---

## Control

You can control this little thing with a browser. 
Even with a mobile phone it is quite good usable.
But of course there are other methods too.

You can install `mpc` on your Raspberry Pi with `sudo apt-get install mpc`
And make a key binding - depending on your desktop environment / window manager - to run `ssh pi 'mpc next|prev|toggle|play|pause'`.

I have three scripts for toggle, next and prev which are triggering different players/tools regarding what is currently running.
You can see them here:

[toggle](https://github.com/mstruebing/dotfiles/blob/master/bin/play-toggle.sh)  
[next](https://github.com/mstruebing/dotfiles/blob/master/bin/play-next.sh)  
[prev](https://github.com/mstruebing/dotfiles/blob/master/bin/play-prev.sh)

You could set up a reverse proxy to only need to enter a specific URL without ip:port or add this ip to your `/etc/hosts` file with a hostname and only need to write hostname:ip.
But that's up to you.

---

## Resources

This whole setup doesn't need much system resources.
This is a screenshot of `htop` while playing music, so not even in idle mode.

<a href="/img/mopidy/rpi_system_monitor.png" target="_blank"><img class="lazyload" data-src="/img/mopidy/rpi_system_monitor.png" alt="htop while playing music" title="htop"></a>

I've never noticed the ram usage to be more than 115MB and processor usage and load average were always not noticeable.
So if you are running anything else on your Raspberry Pi and are in doubt that will it use to much performance I think this is not the case.

---

## Automation

To not need to update manually I simply added a little cronjob which runs updates every night at 1 AM, pauses music if playing and restarts the mopidy server.

{{<  highlight bash >}}
0 1 * * * apt-get update && apt-get upgrade -y && apt-get dist-upgrade -y && apt-get autoremove && apt-get autoclean
0 1 * * * mpc pause && service mopidy restart
{{< /highlight >}}

---

## Drawbacks

Of course there are some drawbacks everywhere and this is no exception.
The most important drawback is that you can't play playlists.
You can play artists, tracks, added tracks from your library(which would be one playlist), radio stations but simply no fucking playlists.
This is an issue in `libspotify` currently as far as I know and not an issue with mopidy or mopify.
Before I had playlists for artists and some mixed ones. Now I simply follow the artists and play them from there.

Also the sound is not very nice from the Raspberry Pi's headphone jack. You will notice quiet disturbing noises. 
To end this I simply bought a cheap external USB sound card which I plugged in, put the speaker in it and it worked out of the box.
You can get one for 5 to 20 Euros, for example [this one](https://www.amazon.com/Sabrent-External-Adapter-Windows-AU-MMSA/dp/B00IRVQ0F8/).

---

## PICS

<a href="/img/mopidy/rpi.jpg" target="_blank"><img class="lazyload" data-src="/img/mopidy/rpi_780px.jpg" alt="my raspberry pi" title="my raspberry pi"></a>


__Thats all, have a niec day.__
