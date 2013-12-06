#!/bin/sh

# install necessary packages
echo "\nInstalling Linux packages...\n"
sudo apt-get install libusb-dev libdbus-1-dev libglib2.0-dev libudev-dev libical-dev libreadline-dev git

# download bluez library
echo "\nDownloading Bluez Library...\n"
wget https://www.kernel.org/pub/linux/bluetooth/bluez-5.11.tar.xz
tar -xJf bluez-5.11.tar.xz
rm bluez-5.11.tar.xz
cd bluez-5.11

# install bluez library
echo "\nInstalling Bluez (this could take a while)...\n"
./configure --disable-systemd
make
sudo make install
cd ..

# get pibeacon scripts
echo "\nInstallng PiBeacon...\n"
git clone https://github.com/tonyd256/pibeacon-scripts.git
cd pibeacon-scripts
sudo cp run_beacon.sh /etc/network/if-up.d/
ruby pibeacon.rb
cd ..
echo "Done!"

