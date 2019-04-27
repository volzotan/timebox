rsync -av               \
--exclude="RAW/"        \
--exclude="*.jpg"       \
--exclude="*.log"       \
~/GIT/timebox/zerobox raspberrypi.local:/home/pi

ssh pi 'sudo chmod -R +x /home/pi/zerobox'