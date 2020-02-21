rsync -av               \
--exclude="RAW/"        \
--exclude="captures_1/" \
--exclude="captures_2/" \
--exclude="captures_3/" \
--exclude="*.jpg"       \
--exclude="*.log"       \
--exclude="__pycache__" \
--delete                \
~/GIT/timebox/zerobox buildroot:/home/pi

ssh buildroot 'chmod -R +x /home/pi/zerobox'
# ssh pi 'systemctl restart oneshot'