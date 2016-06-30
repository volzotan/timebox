#!/bin/bash

# change default password
# expand filesystem
# set timezone
# install zsh / ohmyzsh

# generate keypair and add to reversessh@grinzold

ASSETS_DIR="assets"

if [ $USER != "pi" ]; then
    echo "NOT RUNNING ON PI (as user pi)"
    exit
fi

echo "INSTALLING DEPENDENCIES"

sudo apt-get install python-pip python-dev gphoto2 libgphoto2-dev dcraw supervisor autossh
pip install gphoto2

# tell supervisor to run autossh at startup
cp $ASSETS_DIR/autossh.conf /etc/supervisor/conf.d

# disable sleep mode for the realtek wifi dongle
echo "options 8192cu rtw_power_mgnt=0 rtw_enusbss=0" | sudo tee /etc/modprobe.d/8192cu.conf

# overwrite MOTD
# TODO

# temperature sensor, load kernel modules
sudo cp $ASSETS_DIR/bootconfig.txt /boot/config.txt

# eduroam access
sudo cp $ASSETS_DIR/wpa_supplicant.conf /etc/wpa_supplicant/wpa_supplicant.conf