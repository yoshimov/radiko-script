#!/bin/bash

pushd $(dirname $0)
mplayer -ao alsa:device=hw=1.0 -cache 500 http://localhost:$1 &
popd

