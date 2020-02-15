rsync -av               \
--exclude="RAW/"        \
--exclude="captures/"   \
--exclude="*.jpg"       \
--exclude="*.log"       \
--exclude="__pycache__" \
~/GIT/timebox/zerobox buildroot:/home/pi

ssh buildroot 'chmod -R +x /home/pi/zerobox'
# ssh pi 'systemctl restart oneshot'