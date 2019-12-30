#!/bin/sh -eux

# Delete obsolete networking
echo "Cleaning up";

sudo apt-get -y purge ppp pppconfig pppoeconf || true;
sudo apt-get -y autoremove;
sudo apt-get -y clean;

echo "Clean up complete";


