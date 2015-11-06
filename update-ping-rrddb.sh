#!/bin/bash

# head -n 81  ping.out | tail -9

# if Request timeout then pkt_loss:100
# else rtt is time=(.*) ms

gawk_jam() {
    line=${1}
    #echo $line
	local things=$(echo $line | ${gawk} 'BEGIN {pkt_loss=100; rtt=0.1}
		/Request timeout/ {
			pkt_loss=100
			rtt=0
		}
		/bytes from/ {
			match($10, /time=(.*)/, datartt)
			pkt_loss=0
			rtt=datartt[1]
		}
        END {print pkt_loss ":" rtt}')
    DATA=$things
    #echo $DATA
}

while IFS='' read -r line || [[ -n "$line" ]]; do
    #echo -n "$i "
    gawk_jam "$line"
    time_stmp=$(echo $line | ${gawk} {'printf ("%s %s %s", $1, $2, $3) '})
    epoch=$(${gdate} --date="$time_stmp" -u '+%s')
    #echo $DATA
    #i=$((i + 1))
    #echo  $epoch:$DATA
    ${rrdtool} update ping-rrddb-$(${gdate} --rfc-3339=date).rrd --template pkt_loss:rtt $epoch:$DATA
done < "${1:-/dev/stdin}"

