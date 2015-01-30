#!/bin/bash

if [ -n "$1" ]; then
  sleep $1
fi

pkill mplayer
pkill rtmpdump
pkill rtmpgw

