#!/bin/sh

export LD_LIBRARY_PATH="/usr/lib32/mjpg-streamer/"

mjpg_streamer                                                           \
-i "input_uvc.so -r 1280x720 -d /dev/video0 -f 30"                      \
-o "output_http.so -p 8080 -w /usr/local/share/mjpg-streamer/www"

# mjpg_streamer -i "input_uvc.so -r 1280x720 -d /dev/video0 -f 30" -o "output_http.so -p 8080 -w /usr/local/share/mjpg-streamer/www"