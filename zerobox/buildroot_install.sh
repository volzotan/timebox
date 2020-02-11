pip3 install -r /home/pi/zerobox/requirements.txt

# cp /home/pi/zerobox/oneshot.service /etc/systemd/system/

# i2c required for the Adafruit Bonnet OLED display
grep -qxF 'dtparam=i2c_arm=on' /boot/config.txt || echo 'dtparam=i2c_arm=on' >> /boot/config.txt

# start_x=1 to load the extended GPU firmware required by the PiCamera for trashcam
# but apparently that's not required (actually pi wont boot is start_x=1 is set)
# because buildroot just sneakily replaces and renames the firmware files instead of 
# relying on start_x=1 to use the other set of firmware files
# grep -qxF 'start_x=1' /boot/config.txt || echo 'start_x=1' >> /boot/config.txt

chmod -R +x /home/pi/zerobox
# systemctl enable oneshot
# systemctl start oneshot