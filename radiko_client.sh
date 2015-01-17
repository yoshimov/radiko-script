#!/bin/bash
#
# apt-get install mplayer
# apt-get install rtmpdump swftools libxml2-utils

PORT=8080
CH=$1

. /home/nomura/radiko_server.sh $CH $PORT

mplayer -ao alsa:device=hw=1.0 -cache 500 http://127.0.0.1:$PORT &

sleep 3600

pkill mplayer
pkill rtmpgw

