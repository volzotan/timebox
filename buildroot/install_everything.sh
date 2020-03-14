
# create /boot dir so fstab can mount the boot partition
ssh buildroot 'mkdir /boot'
ssh buildroot 'mkdir /media/external_storage'

echo "resize partitions and reboot"
scp resize_fs.sh buildroot:/root
ssh buildroot 'sh /root/resize_fs.sh'

echo "sleep 20s"
sleep 20

echo "finishing resizing partitions"
ssh buildroot 'resize2fs /dev/mmcblk0p2'

echo "\n---"
echo "setting current time and date on the pi"
sh set_date.sh

echo "\n---"
echo "uploading zerobox files"
sh upload_zerobox.sh

echo "\n---"
echo "deleting files"
sh buildroot_clean.sh

# install script need to access /boot/config.txt and cmdline.txt 
# so boot partition needs to be mounted for this

echo "\n---"
echo "download pip packages"
ssh buildroot 'sh /home/pi/zerobox/buildroot_install.sh'

echo "DONE! reboot..."
ssh buildroot 'reboot'