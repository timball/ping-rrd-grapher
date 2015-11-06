# ping-rrd-grapher
ping a host for a while then create an rrd graph from it. couldn't find a good example of this so i canibalized one.

### Description 
use this tool to ping a single host and then use rrdtool to graph the results.

### Dependencies
Depends on a pile of utilities but prime among them is rrdtool. 

    * moreutils
    * rrdtool

Usage:
    
    1. `vi settings.sh` and edit `PING_HOST` to suit your needs.
    2. create rrd db: `./create-ping-rrddb.sh`
    3. ping things: `./do-ping.sh`
    4. wait (the longer the better but will only graph 24h worth of stuff) 
    5. graph things: `./graph-ping-rrddb.sh`

### Inspiration
[https://calomel.org/rrdtool.html](https://calomel.org/rrdtool.html)

### Bugs
many. send a PR

--timball
