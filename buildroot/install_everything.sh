
echo "\n---"
echo "setting current time and date on the pi"
sh set_date.sh

echo "\n---"
echo "uploading zerobox files"
sh upload_zerobox.sh

echo "\n---"
echo "download pip packages"
ssh buildroot 'sh /home/pi/zerobox/buildroot_install.sh'

echo "resize partitions and reboot"
scp resize_fs.sh buildroot:/root
ssh buildroot 'sh /root/resize_fs.sh'

echo "sleep 15s"
sleep 15

echo "finishing resizing partitions"
ssh buildroot 'resize2fs /dev/mmcblk0p2'