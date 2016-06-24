#!/bin/bash

# change default password
# expand filesystem
# install zsh / ohmyzsh

# generate keypair and add to reversessh@grinzold

if [ $USER != "pi" ]; then
    echo "NOT RUNNING ON PI (as user pi)"
    exit
fi

echo "INSTALLING DEPENDENCIES"

sudo apt-get install python-pip python-dev gphoto2 libgphoto2-dev dcraw supervisor autossh
pip install gphoto2

# tell supervisor to run autossh at startup
# autossh -R 22322:localhost:22 -N grinzold.de -p 2222 -l reversessh -i /home/pi/.ssh/reversessh.key
cp autossh.conf /etc/supervisor/conf.d
