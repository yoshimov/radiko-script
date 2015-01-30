#!/bin/bash

pushd $(dirname $0)

echo "started: $(date)"

#playerurl=http://radiko.jp/player/swf/player_3.0.0.01.swf
playerurl=http://radiko.jp/player/swf/player_4.0.0.00.swf
playerfile=./player.swf
keyfile=./authkey.png

if [ $# -eq 1 ]; then
  channel=$1
else
  echo "usage : $0 channel_name [duraton sec]"
  exit 1
fi

echo "get player..."

#
# get player
#
if [ ! -f $playerfile ]; then
  wget -q -O $playerfile $playerurl

  if [ $? -ne 0 ]; then
    echo "failed get player"
    exit 1
  fi
fi

echo "get keydata"

#
# get keydata (need swftool)
#
if [ ! -f $keyfile ]; then
  swfextract -b 14 $playerfile -o $keyfile

  if [ ! -f $keyfile ]; then
    echo "failed get keydata"
    exit 1
  fi
fi

if [ -f auth1_fms ]; then
  rm -f auth1_fms
fi

echo "access auth1_fms"

#
# access auth1_fms
#
wget -q \
     --header="pragma: no-cache" \
     --header="X-Radiko-App: pc_1" \
     --header="X-Radiko-App-Version: 2.0.1" \
     --header="X-Radiko-User: test-stream" \
     --header="X-Radiko-Device: pc" \
     --post-data='\r\n' \
     --no-check-certificate \
     --save-headers \
     https://radiko.jp/v2/api/auth1_fms

if [ $? -ne 0 ]; then
  echo "failed auth1 process"
  exit 1
fi

echo "get partial key"

#
# get partial key
#
authtoken=`perl -ne 'print $1 if(/x-radiko-authtoken: ([\w-]+)/i)' auth1_fms`
offset=`perl -ne 'print $1 if(/x-radiko-keyoffset: (\d+)/i)' auth1_fms`
length=`perl -ne 'print $1 if(/x-radiko-keylength: (\d+)/i)' auth1_fms`

partialkey=`dd if=$keyfile bs=1 skip=${offset} count=${length} 2> /dev/null | openssl enc -e -base64`

echo "authtoken: ${authtoken} \noffset: ${offset} length: ${length} \npartialkey: $partialkey"

rm -f auth1_fms

if [ -f auth2_fms ]; then
  rm -f auth2_fms
fi

echo "access auth2_fms"

#
# access auth2_fms
#
wget -q \
     --header="pragma: no-cache" \
     --header="X-Radiko-App: pc_1" \
     --header="X-Radiko-App-Version: 2.0.1" \
     --header="X-Radiko-User: test-stream" \
     --header="X-Radiko-Device: pc" \
     --header="X-Radiko-Authtoken: ${authtoken}" \
     --header="X-Radiko-Partialkey: ${partialkey}" \
     --post-data='\r\n' \
     --no-check-certificate \
     https://radiko.jp/v2/api/auth2_fms

if [ $? -ne 0 -o ! -f auth2_fms ]; then
  echo "failed auth2 process"
  exit 1
fi

echo "authentication success"

areaid=`perl -ne 'print $1 if(/^([^,]+),/i)' auth2_fms`
echo "areaid: $areaid"

rm -f auth2_fms

echo "get stream-url"

#
# get stream-url
#

wget -O ${channel}.xml -q "http://radiko.jp/v2/station/stream/${channel}.xml"

stream_url=`echo "cat /url/item[1]/text()" | xmllint --shell ${channel}.xml | tail -2 | head -1`
url_parts=(`echo ${stream_url} | perl -pe 's!^(.*)://(.*?)/(.*)/(.*?)$/!$1://$2 $3 $4!'`)

echo ${channel}.xml
# rm -f ${channel}.xml

echo -r ${url_parts[0]}
echo --app ${url_parts[1]}
echo --playpath ${url_parts[2]}
echo -W $playerurl
echo -C $authtoken

if [ -n "$2" ]; then
  echo "stop timer: $2"
  . tuner_stop.sh $2 &
fi

#
# rtmpgw
#
rtmpdump --rtmp "${url_parts[0]}" --app "${url_parts[1]}" --playpath "${url_parts[2]}" --swfVfy "$playerurl" --conn S:"" --conn S:"" --conn S:"" --conn "S:$authtoken" --live --quiet | mplayer -ao alsa:device=hw=1.0 -cache 500 -

popd

