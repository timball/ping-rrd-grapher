#!/bin/bash
#
# INSTALL
# -------
# 1.) Create directory structure
#     <base_dir>
#     <base_dir>\bin
#     <base_dir>\etc
#     <base_dir>\log
#     <base_dir>\rrd
# 2.) Place this file in <base_dir>/bin
# 3.) Create file <base_dir>/etc/zping.conf, fill with hosts to ping, one per
#     line
# 4.) Modify base_dir and graph_dir below, graph images will be placed in
#     graph_dir
# 5.) add cronjob, * * * * * /<base_dir>/bin/zping.sh > /dev/null 2>&1
#
# USAGE
# -----
# Sends 20 pings at .2 second intervals to hosts listed in zping.conf, once per
# minute. Stores number of packets lost and min/avg/max RTTs for each host in
# an RRD. Generates a new 4 hour graph image for each host, showing min/avg/max
# RTTs after each run.
# 
# https://gist.github.com/microlinux/61647231cdae6116e0bd
#

source $1
graph_dir="$base_dir/zping"
log="$base_dir/log/zping.log"

function write_log()
{
    echo "`date '+%m/%d %H:%M:%S'` $1" >> $log
}

if [ -z $1 ] # if called without any arguments, this is the master process, start mass ping
then
    timestamp=`date +"%s"`

    write_log 'starting pings'

    cat $base_dir/etc/zping-hosts.conf | $GNUXARGS -n 1 -I ^ -P 50 $base_dir/bin/zping.sh ^ $timestamp

    retval=$?

    if [ $retval -gt 0 ]
    then
        write_log "mass ping failed retval $retval"
        exit 202
    fi

    write_log 'pings complete'
    write_log 'generating graphs'

    for file in $base_dir/rrd/*.rrd
    do
        host=${file#$base_dir/rrd/}
        host=${host%.rrd}

        $RRDTOOL graph $graph_dir/$host.png \
        -w 785 -h 120 -a PNG \
        --slope-mode \
        --start -14400 --end now \
        --font DEFAULT:8: \
        --title "Ping RTT to $host" \
        --vertical-label "Latency (MS)" \
        --lower-limit 0 \
        --alt-y-grid --rigid \
        DEF:min=$file:min:MAX \
        DEF:avg=$file:avg:MAX \
        DEF:max=$file:max:MAX \
		COMMENT:"Updated `date '+%m/%d %H\:%M'`   " \
        LINE1:min#03bd10:"Min" \
        LINE1:avg#0223ca:"Avg" \
        LINE1:max#e11110:"Max"

        retval=$?

        if [ $retval -gt 0 ]
        then
            write_log "error generating graph for $host retval $retval"
        fi
    done

    write_log 'graph generation complete'

    exit 0
else # if called with arguments this is a worker process, ping a target
    output=$($PING -c 20 -i .2 -W 1 -q $1)
    retval=$?

    if [ $retval -eq 0 ] # at least some pings were returned
    then
        recvd=$(echo $output | grep -o '[0-9]\+ packets received')
        recvd=${recvd% packets received}
        lost=`expr 20 - $recvd`
        stats=(`echo $output | grep -o '[0-9.]\+/[0-9.]\+/[0-9.]\+' | tr '/' ' '`)
        min=${stats[0]}
        avg=${stats[1]}
        max=${stats[2]}
    elif [ $retval -eq 1 ] # no pings were returned
    then
        lost=20
        min='U'
        avg='U'
        max='U'
    elif [ $retval -eq 2 ] # host not found
    then
        write_log "unknown host $1"
        exit $retval
    else # other errors
        write_log "error pinging $1 retval $retval"
        exit $retval
    fi

    if [ ! -f $base_dir/rrd/$1.rrd ] # create rrd if it doesn't exist
    then
        $RRDTOOL create $base_dir/rrd/$1.rrd \
        --step 60 \
        DS:lost:GAUGE:120:0:20 \
        DS:min:GAUGE:120:0:1000 \
        DS:avg:GAUGE:120:0:1000 \
        DS:max:GAUGE:120:0:1000 \
        RRA:MAX:0.5:1:525600

        retval=$?

        if [ $retval -gt 0 ]
        then
            write_log "unable to create rrd for $1 retval $retval"
            exit 200
        fi
    fi

    #echo "/usr/local/bin/rrdtool update $base_dir/rrd/$1.rrd $2:$lost:$min:$avg:$max" 
    $RRDTOOL update $base_dir/rrd/$1.rrd $2:$lost:$min:$avg:$max

    retval=$?

    if [ $retval -gt 0 ]
    then
        write_log "rrd update for $1 failed retval $retval"
        exit 201
    fi
fi
