pip3 install -r /home/pi/zerobox/compcam_requirements.txt
pip3 install -r /home/pi/zerobox/timebox_requirements.txt -I 
# pip needs i == ignore, otherwise it will try to 
# re-install spidev which fails because GCC is missing
# (python-spidev is provided by buildroot)

# cp /home/pi/zerobox/oneshot.service /etc/systemd/system/

# i2c required for the Adafruit Bonnet OLED display
grep -qxF 'dtparam=i2c_arm=on' /boot/config.txt || echo 'dtparam=i2c_arm=on' >> /boot/config.txt

# start_x=1 to load the extended GPU firmware required by the PiCamera for trashcam
# but apparently that's not required (actually pi wont boot is start_x=1 is set)
# because buildroot just sneakily replaces and renames the firmware files instead of 
# relying on start_x=1 to use the other set of firmware files
# grep -qxF 'start_x=1' /boot/config.txt || echo 'start_x=1' >> /boot/config.txt

# adjust GPU memory for the Pi Camera
sed -i 's/gpu_mem_512=100/gpu_mem_512=256/g' /boot/config.txt

# remove console=ttyAMA0,115200 from cmdline.txt so UART can be used
# 'enable_uart=1' in config.txt is not required
sed -i 's/console=ttyAMA0,115200//g' /boot/cmdline.txt

chmod -R +x /home/pi/zerobox
# systemctl enable oneshot
# systemctl start oneshot