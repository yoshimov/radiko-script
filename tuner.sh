#!/bin/bash
#
# apt-get install mplayer
# apt-get install rtmpdump swftools libxml2-utils

PORT=8080
CH=$1
DIR=$(dirname $0)

. ${DIR}/radiko_server.sh $CH $PORT
. ${DIR}/radiko_client.sh $PORT

