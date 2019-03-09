
if [ $USER != "pi" ]; then
    echo "NOT RUNNING ON PI (as user pi). ABORT"
    exit -1
fi

# filesystem
# is already done on first boot, so nothing to do 

# enable SSH
touch /boot/ssh

# increase boot speed:
# 1) cancel kernel output
#    append quiet first line
#    --> About 1-3 seconds gain.

# TODO: do only if quiet has not been added yet
echo "quiet" >> /boot/cmdline.txt

# 2) disable userspace services

sudo systemctl disable dhcpcd.service
sudo systemctl disable keyboard-setup.service
sudo systemctl disable alsa-restore.service          # doesn’t seem to work
sudo systemctl disable triggerhappy.service

# install basic stuff

sudo apt-get update
sudo apt-get install rsync zsh picocom

sudo wget https://raw.githubusercontent.com/gnachman/iTerm2/master/tests/imgcat
sudo mv imgcat /usr/local/bin/imgcat
sudo chmod +x /usr/local/bin/imgcat

# zerobox dependencies

sudo apt-get install -y python3 python3-numpy dcraw python3-pip
pip install gexiv2

sudo apt-get install -y exiv2 gir1.2-gexiv2-0.10
sudo apt-get install -y python3-gi
sudo pip3 install pyserial

sudo apt-get install -y python3-dev libjpeg-dev
sudo apt-get install -y libopenjp2-7
sudo apt-get install -y python3-yaml
pip3 install luma.oled
pip3 install luma.emulator

# set up the systemd services
cp zerobox.service /etc/systemd/system/zerobox.service
chmod +x /home/pi/zerobox/zerobox.py
sudo systemctl enable zerobox

# oh-my-zsh
# wget https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O ohmyzsh.sh
# sh ohmyzsh.sh

# TODO: 
#   enable i2c / SPI
#   install libgphoto2