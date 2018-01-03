#!/bin/bash

if [ $# -ne 1 ]; then
	echo "ERROR: Wrong arguments! Must specify ssh server!"
	exit 1
fi

server=$1

free_port=0

read lower_port upper_port < /proc/sys/net/ipv4/ip_local_port_range
while :; do
    for (( port = lower_port ; port <= upper_port ; port++ )); do
		ss -lpn | grep ":$port"
		if [ $? -ne 0 ]; then
			echo "free port: $port"
			free_port=$port
			break 2
		fi
    done
done

if [ $free_port -eq 0 ]; then
	echo "Cannot find free port"
	exit 1
fi

ssh -D $free_port -N $server &
pid=$!

echo "ssh runs as process $pid"

chromium-browser --temp-profile --proxy-server="socks5://127.0.0.1:$free_port"

echo "Ending SSH tunnel"
kill $pid
if [ $? -eq 0 ]; then
	echo "OK!"
else
	echo "Failed!"
fi
