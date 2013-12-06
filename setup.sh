
# install necessary packages
echo "Installing Linux packages..."
sudo apt-get install libusb-dev libdbus-1-dev libglib2.0-dev libudev-dev libical-dev libreadline-dev git

# download bluez library
echo "Downloading Bluez Library..."
wget https://www.kernel.org/pub/linux/bluetooth/bluez-5.11.tar.xz
tar -xJf bluez-5.11.tar.xz
rm bluez-5.11.tar.xz
cd bluez-5.11

# install bluez library
echo "Installing Bluez (this could take a while)..."
./configure --disable-systemd
make
sudo make install
cd ..

# get pibeacon scripts
echo "Installng PiBeacon..."
git clone https://github.com/tonyd256/pibeacon-scripts.git
cd pibeacon-scripts
cp run_beacon.sh /etc/network/if-up.d/
ruby beacon.rb
cd ..
echo "Done!"

