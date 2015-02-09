#!/bin/bash

channel=$1
sec=$2
if [ -n "$3" ]; then
  file="$3/"
fi
file="${file}${channel}-$(date +%Y%m%d%H%M).flv"

case $channel in
  am1)
	path="NetRadio_R1_flash@63346"
	rtmpurl="rtmpe://netradio-r1-flash.nhk.jp"
	;;
  am2)
	path="NetRadio_R2_flash@63342"
	rtmpurl="rtmpe://netradio-r2-flash.nhk.jp"
	;;
  fm)
	path="NetRadio_FM_flash@63343"
	rtmpurl="rtmpe://netradio-fm-flash.nhk.jp"
	;;
esac

rtmpdump --rtmp "$rtmpurl" \
         --playpath $path \
         --app "live" \
         --swfVfy http://www3.nhk.or.jp/netradio/files/swf/rtmpe.swf \
         --live \
         -stop $sec \
         -o $file

