#!/bin/bash

mplayer -ao alsa:device=hw=1.0 -cache 500 http://127.0.0.1:$1 &

