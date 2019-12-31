rsync -av               \
--exclude="RAW/"        \
--exclude="*.jpg"       \
--exclude="*.log"       \
--exclude="__pycache__" \
~/GIT/timebox/zerobox buildroot:/home/pi