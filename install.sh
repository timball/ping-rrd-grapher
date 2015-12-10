#!/bin/bash

current_working_dir=$(pwd)

#echo "base_dir=\"$current_working_dir\"" >> etc/zping.conf
mkdir -p bin log rrd zping

#brew install rrdtool findutils

## FIXME don't know why the traceroute hangs ... it's very annoying
#default_route=$(route -n get default | grep -E -o 'gateway: .*' | awk '{print $2}')
#third_hop=$(traceroute -m 5 -n 4.2.2.2 | head -n 3  | tail -n 1  | awk '{print $2'})
#echo "$default_route" >> etc/zping-hosts.conf
#echo "$third_hop" >> etc/zping-hosts.conf

line="* * * * * ${current_working_dir}/bin/zping.sh &> /dev/null"

#crontab -l; echo $line | crontab - 
echo "add the following to your crontab"
echo "$line"
