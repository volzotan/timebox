pip3 install -r /home/pi/zerobox/requirements.txt

# cp /home/pi/zerobox/oneshot.service /etc/systemd/system/

grep -qxF 'dtparam=i2c_arm=on' /boot/config.txt || echo 'dtparam=i2c_arm=on' >> /boot/config.txt

chmod -R +x /home/pi/zerobox
# systemctl enable oneshot
# systemctl start oneshot