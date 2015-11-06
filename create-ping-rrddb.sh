#!/bin/bash
#https://calomel.org/rrdtool.html

source settings.sh

${rrdtool} create ping-rrddb-$(gdate --rfc-3339=date).rrd \
    --start 1446710000 \
    --step 1 \
    DS:pkt_loss:GAUGE:3:0:100 \
    DS:rtt:GAUGE:3:0:10000000 \
    RRA:MAX:0.5:1:86400 \

