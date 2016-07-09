#!/bin/bash

echo "\nUPLOAD\n"

SOURCE="."
DESTINATION="."

if [ $USER == "pi" ]; then
    echo "RUNNING ON PI (as user pi)"
    exit
fi

if [ $USER == "volzotan" ]; then
    echo "running on CORODIAK"
    SOURCE="/Users/volzotan/GIT/timebox"
    DESTINATION="grinzold:/root/"
fi

if [ $USER == "root" ]; then
    echo "running on GRINZOLD"
    SOURCE="/root/timebox"
    DESTINATION="timebox:/home/pi/"
fi

rsync -arv --exclude 'timebox/box/RAWS' $SOURCE $DESTINATION