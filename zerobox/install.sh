# Useful commands:
# 
# systemd-analyze
# systemd-analyze blame
# systemd-analyze plot

output=$( df -k . )
output=$( cut -f1 $output )
echo output

if [ $USER != "pi" ]; then
    echo "NOT RUNNING ON PI (as user pi). ABORT"
    exit -1
fi

exit 0

# enable SSH
# either by raspi-config or by placing a file named 'ssh', without any extension, onto the boot partition of the SD card.
touch /boot/ssh

# increase boot speed:
# 1) cancel kernel output
#    append quiet first line
#    --> About 1-3 seconds gain.

echo "quiet" >> /boot/cmdline.txt

# 2) disable userspace services

sudo systemctl disable dhcpcd.service
sudo systemctl disable keyboard-setup.service
sudo systemctl disable alsa-restore.service          # doesn’t seem to work
sudo systemctl disable triggerhappy.service

# TODO: https://wiki.archlinux.org/index.php/dhcpcd#Speed_up_DHCP_by_disabling_ARP_probing

# expand filesystem (should be done automatically on first boot by now)
# echo "Expand the filesystem. raspi-config will be opened."
# read -p "Press enter to proceed."
# sudo raspi-config

# install basic stuff

sudo apt-get update
sudo apt-get install rsync zsh picocom

# zerobox dependencies

sudo apt-get install python3 python3-numpy dcraw python3-pip
pip install gexiv2

# python3-numpy needs to be compiled on the pi and takes about 2 hours. 
# The python2 version comes with precompiled binaries. 

sudo apt-get install exiv2 gir1.2-gexiv2-0.10
# sudo apt-get install libexiv2-dev (?)
sudo apt-get install python3-gi
sudo pip3 install pyserial

exit 0

# oh-my-zsh
sh -c "$(wget https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)“ 

# compile gphoto2 in the newest version, the debian version is lacking some functionality (AF control)

default raspbian jessie lite:

gphoto2         2.5.4          gcc, popt(m), exif, cdk, aa, jpeg, readline
libgphoto2      2.5.4          all camlibs, gcc, ltdl, EXIF
libgphoto2_port 0.10.0         gcc, ltdl, no USB, serial without locking

needed ~ 2.5.11

compilation time:
libgphoto2 40min
gphoto2 5min
# set up the zerobox crontab (unclear if really necessary)

crontab -e
@reboot python /home/pi/zerobox/zerobox.py &

    enable the cron service
sudo systemctl enable cron.service
sudo systemctl start cron.service
# set permissions (unclear if really necessary)

chmod 777 /home/pi/RAW
chmod 777 /home/pi/zerobox
# disable console on ttyAMA0

important article about the UART on pi3/pi zero w:
https://www.raspberrypi.org/documentation/configuration/uart.md

remove from /boot/cmdline.txt the entry console=serial0,115200
