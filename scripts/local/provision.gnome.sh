#!/bin/bash

# xfce4 doesn't work well with spice (guest tools in libvirt), use gnome for now
# need to make sure lightdm is not there

set -e;

export DEBIAN_FRONTEND=noninteractive;

echo "Updating package repositories";
sudo apt-get update

echo "Setting gdm3 as default display manager pre-answer"
echo "/usr/sbin/gdm3" | sudo tee /etc/X11/default-display-manager
sudo systemctl disable lightdm || echo "Issue with: systemctl disable lightdm";

echo "Purging lightdm just in case"
sudo DEBIAN_FRONTEND=noninteractive apt-get purge -y lightdm || echo "Issue with: apt-get purge -y lightdm ";
sudo DEBIAN_FRONTEND=noninteractive apt-get purge -y lightdm || echo "Issue with: apt-get purge -y lightdm ";

echo "Purging gdm3 just in case"
sudo DEBIAN_FRONTEND=noninteractive apt-get purge -y gdm3 || echo "Issue with: apt-get purge -y gdm3";

echo "Setting gdm3 as default display manager pre-answer"
echo "/usr/sbin/gdm3" | sudo tee /etc/X11/default-display-manager

echo "Installing gdm3"
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y gdm3;

echo "Installing gnome";
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y gnome-core kali-defaults kali-root-login desktop-base xinit;

echo "Purging lightdm just in case 2"
sudo DEBIAN_FRONTEND=noninteractive apt-get purge -y lightdm || echo "Issue with: apt-get purge -y lightdm ";
sudo DEBIAN_FRONTEND=noninteractive apt-get purge -y lightdm || echo "Issue with: apt-get purge -y lightdm ";

echo "Setting gdm3 as default display manager pre-answer 2"
echo "/usr/sbin/gdm3" | sudo tee /etc/X11/default-display-manager

echo "Setting up: gnome";
sudo gsettings set org.gnome.desktop.screensaver idle-activation-enabled false || echo 'Failed Gnome Setting: org.gnome.desktop.screensaver idle-activation-enabled false';

sudo gsettings set org.gnome.desktop.screensaver lock-enabled false || echo 'Failed Gnome Setting: org.gnome.desktop.screensaver lock-enabled false';

sudo gsettings set org.gnome.desktop.screensaver lock-delay 0 || echo 'Failed Gnome Setting: org.gnome.desktop.screensaver lock-delay 0';

sudo gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'nothing' || echo 'Failed Gnome Setting: org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type "nothing"';

sudo gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-type 'nothing' || echo 'Failed Gnome Setting: org.gnome.settings-daemon.plugins.power sleep-inactive-battery-type "nothing"';

sudo gsettings set org.gnome.settings-daemon.plugins.power idle-dim false || echo 'Failed Gnome Setting: org.gnome.settings-daemon.plugins.power idle-dim false ';

sudo gsettings set org.gnome.desktop.session idle-delay 0 || echo 'Failed Gnome Setting: org.gnome.desktop.session idle-delay 0';

sudo gsettings set org.gnome.desktop.screensaver lock-enabled true || echo 'Failed Gnome Setting: org.gnome.desktop.screensaver lock-enabled true';

sudo apt-get install -y gnome-shell-extension-dashtodock || echo "Issue with: apt-get install -y gnome-shell-extension-dashtodock"

sudo gsettings set org.gnome.shell.extensions.dash-to-dock dash-max-icon-size 48 || echo "Failed Gnome Setting: org.gnome.shell.extensions.dash-to-dock dash-max-icon-size 48"

sudo systemctl enable gdm3;
sudo systemctl start gdm3;
