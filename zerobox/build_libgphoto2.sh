mkdir /home/pi/libgphoto2_build
cd /home/pi/libgphoto2_build
git clone https://github.com/gphoto/libgphoto2.git
cd libgphoto2

sudo apt-get install -y automake autoconf pkg-config autopoint gettext libtool
sudo apt-get install -y libusb-dev libexif-dev

autoreconf --install --symlink
./configure --prefix=/usr/local

make
make install