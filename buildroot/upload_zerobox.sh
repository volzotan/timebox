#/bin/sh

# rsync -av               \
# --exclude="RAW/"        \
# --exclude="captures_1"  \
# --exclude="captures_2"  \
# --exclude="captures_3"  \
# --exclude="*.jpg"       \
# --exclude="*.log"       \
# --exclude="__pycache__" \
# ~/GIT/timebox/zerobox buildroot:/home/pi


rsync -av                           \
--include="/*"                      \
--include="trashcam.py"             \
--include="devices.py"              \
--include="requirements.txt"        \
--include="buildroot_install.sh"    \
--exclude="*"                       \
~/GIT/timebox/zerobox buildroot:/home/pi