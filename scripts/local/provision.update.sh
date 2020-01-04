#!/bin/bash

set -e

export DEBIAN_FRONTEND=noninteractive;

function waitforfile() {
    target="$1";
    while [ ! -f "$1" ]; do
        echo "[!] There was an error. Please log in and fix it"
        echo "[!] Once fixed, run: touch $target"
        sleep 5s;
    done
}

echo "Provisioning: Updating - Starting"

echo "Provisioning: Updating - Updating repo"
sudo apt-get update;
sudo apt-get update;

echo "Provisioning: Updating - Upgrading packages"
sudo apt-get -y upgrade || waitforfile "/tmp/continuewithprovision"


#arch="`uname -r | sed 's/^.*[0-9]\{1,\}\.[0-9]\{1,\}\.[0-9]\{1,\}\(-[0-9]\{1,2\}\)-//'`"
# echo "Installing linux image";
# apt-get -y upgrade linux-image-$arch;

# echo "Installing linux headers";
# apt-get -y install linux-headers-`uname -r`;

# rm -rf /etc/udev/rules.d/70-persistent-net.rules || true
# udevadm trigger --subsystem-match=net --action=add || true;

echo "Provisioning: Updating - Installing build-essential and wget"
sudo apt-get -y install build-essential wget curl || waitforfile "/tmp/continuewithprovision2"



# echo "Doing a bunch of stuff to remove old things"
# apt-get autoremove || echo "Error on autoremove"
# apt-get --purge remove || echo "Error on purge --remove"
# apt-get autoclean || echo "Error on autoclean"
# apt-get -f install || echo "Error on apt-get -f install "
# dpkg-reconfigure -a || echo "Error on dpkg-reconfigure -a"

# dpkg --list | grep 'linux-image' | awk '{ print $2 }' | sort -V | sed -n '/'"$(uname -r | sed "s/\([0-9.-]*\)-\([^0-9]\+\)/\1/")"'/q;p' | xargs apt-get -y purge || echo "Error Removin old kernel images";
# dpkg --list | grep 'linux-headers' | awk '{ print $2 }' | sort -V | sed -n '/'"$(uname -r | sed "s/\([0-9.-]*\)-\([^0-9]\+\)/\1/")"'/q;p' | xargs apt-get -y purge || echo "Error Removin old kernel headers";

echo "Provisioning: Updating - Updating packages"
sudo apt-get update;

# echo "Performing full dist upgrade";
# apt-get -y dist-upgrade || echo "Fail on first dist-upgrade attempt";
# echo "If it failed, doing some other stuff";
# dpkg --configure -a || echo "Error on dpkg --configure -"
# update-initramfs -u || echo "Error on update-initramfs -u"
# apt-get -y upgrade || echo "Error on apt-get -y upgrade"

# echo "Removing plymouth and plymouth-label";
# apt-get purge plymouth plymouth-label
# apt autoremove -y
# apt-get update;

echo "Provisioning: Updating - Updating initramfs"
sudo update-initramfs -u || echo "[!] Error on update-initramfs -u"

function trydistupgradeagaint() {
    echo "Provisioning: Updating - Trying bootleg dist upgrade workaround"
    printf "\n\n\n" | apt-get dist-upgrade -y || waitforfile "/tmp/continuewithprovision3"
}

echo "Provisioning: Updating - Performing full dist upgrade for real"
sudo apt-get -y dist-upgrade || trydistupgradeagaint


# swap on lvm slows boot
sudo sed -e 's/^RESUME=/#RESUME=/g' -i /etc/initramfs-tools/conf.d/resume
echo "RESUME=/dev/mapper/bugmenace--0--vg-swap" | sudo tee -a /etc/initramfs-tools/conf.d/resume
sudo update-initramfs -u || echo "[!] Error on update-initramfs -u"

# echo "Installing plymouth and plymouth-label";
# apt-get install -y plymouth plymouth-label || echo "Failed to install plymouth label" 

echo "Provisioning: Updating - Complete"
