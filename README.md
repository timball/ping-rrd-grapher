# ping-rrd-grapher
ping a host for a while then create an rrd graph from it. couldn't find a good example of this so i canibalized one.

### Description 
use this tool to ping a single host and then use rrdtool to graph the results.

### Dependencies
Depends on a pile of utilities but prime among them is rrdtool. 

    * moreutils
    * rrdtool
    * OSX ... haven't done the things to make this many unix friendly just dealt w/ brew and sadness

Usage:
    
    1. `./install.sh` and edit add the output line to your crontab to suit your needs.
    2. hold on to your butts and optionally edit the etc/zping-hosts.conf
    3. wait (the longer the better but will only graph 24h worth of stuff) 
    5. images will be in the zpings/ directory

### Inspiration
[https://calomel.org/rrdtool.html](https://calomel.org/rrdtool.html)

### Bugs
many. send a PR

--timball
