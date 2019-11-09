
if [ $USER != "pi" ]; then
    echo "NOT RUNNING ON PI (as user pi). ABORT"
    exit -1
fi

# disable userspace services

# sudo systemctl disable dhcpcd.service
sudo systemctl disable keyboard-setup.service
sudo systemctl disable alsa-restore.service          # doesn’t seem to work
sudo systemctl disable triggerhappy.service

# install basic stuff

sudo apt-get update --allow-releaseinfo-change
sudo apt-get upgrade -y
sudo apt-get install -y git rsync zsh picocom

sudo wget https://raw.githubusercontent.com/gnachman/iTerm2/master/tests/imgcat
sudo mv imgcat /usr/local/bin/imgcat
sudo chmod +x /usr/local/bin/imgcat

# zerobox dependencies

sudo apt-get install -y python3 
sudo apt-get install -y python3-dev
sudo apt-get install -y libjpeg-dev
sudo apt-get install -y libopenjp2-7
sudo apt-get install -y libtiff5
sudo apt-get install -y libgphoto2-dev # build manually via build_libgphoto2.sh ?
sudo apt-get install -y gphoto2
sudo apt-get install -y python3-smbus
sudo apt-get install -y python3-yaml
sudo apt-get install -y python3-numpy
sudo apt-get install -y python3-pip
sudo apt-get install -y dcraw
sudo apt-get install -y exiv2
sudo apt-get install -y gir1.2-gexiv2-0.10
sudo apt-get install -y python3-gi
sudo pip3 install pyserial
sudo pip3 install psutil
sudo pip3 install rpyc
sudo pip3 install gphoto2

# only available with pip2?
# sudo pip3 install gexiv2

# pygame dependencies
# sudo apt-get install -y libsdl1.2-dev
sudo apt-get install -y python3-pygame
sudo pip3 install luma.oled
sudo pip3 install luma.emulator

# ykush
sudo pip3 install hidapi
sudo cp /home/pi/zerobox/udev/50-ykush.rules /etc/udev/rules.d/

# create symlink for the zerobox CLI
sudo ln -s /home/pi/zerobox/cli.py /usr/local/bin/zerobox 

# set up the systemd services
sudo cp /home/pi/zerobox/*.service /etc/systemd/system/
sudo chmod -R +x /home/pi/zerobox
sudo systemctl enable zerobox
sudo systemctl enable zerobox_gui
sudo systemctl start zerobox
sudo systemctl start zerobox_gui

# fstab USB Stick mounting
sudo mkdir /media/external_storage
# UUID=8A0F-14F3 /media/external_storage/ vfat utf8,uid=pi,gid=pi,noatime 0 0
# UUID=8A0F-14F3 /media/external_storage/ vfat users,sync,noatime,noauto,x-systemd.automount 0 0

# oh-my-zsh
# wget https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O ohmyzsh.sh && sh ohmyzsh.sh
# sh -c "$(wget https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"
# chsh -s /bin/zsh

# TODO: 
#   enable i2c / SPI