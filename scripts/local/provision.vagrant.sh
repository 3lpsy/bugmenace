#!/bin/sh -eux

# set a default HOME_DIR environment variable if not set
HOME_DIR="${HOME_DIR:-/root}";

VAGRANT_INSECURE_KEY="ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ== vagrant insecure public key"

echo "Provisioning: Vagrant - Making Home Directory"
sudo mkdir -p $HOME_DIR/.ssh;

echo "Provisioning: Vagrant - Adding insecure key"
echo "${VAGRANT_INSECURE_KEY}" | sudo tee $HOME_DIR/.ssh/authorized_keys

echo "Provisioning: Vagrant - Changing Permissions"
sudo chmod 600 $HOME_DIR/.ssh/authorized_keys

# chown -R $SSH_USER:$SSH_USER $SSH_USER_HOME/.ssh

# chown -R vagrant $HOME_DIR/.ssh;
# chmod -R go-rwsx $HOME_DIR/.ssh;

echo "Provisioning: Vagrant - Creating Vagrant User"

sudo useradd -m -s /bin/bash -u 1000 vagrant;

echo "Provisioning: Vagrant - Changing Vagrant Group ID"
sudo groupmod -g 1001 vagrant;

echo "Provisioning: Vagrant - Setting insecure password for vagrant user"
echo 'vagrant:vagrant' | chpasswd;

echo "Provisioning: Vagrant - Copying root ssh directory for vagrant user"
sudo cp -R /root/.ssh /home/vagrant/.ssh;
sudo chown -R vagrant:vagrant /home/vagrant/.ssh;
echo "Provisioning: Vagrant - Copying root profile for vagrant user"
sudo cp /root/.profile /home/vagrant/;
sudo chown -R vagrant:vagrant /home/vagrant/.profile;

echo "Provisioning: Vagrant - Making /mnt/host Directory"
sudo mkdir /mnt/host
sudo chown vagrant:vagrant /mnt/host
sudo usermod -aG sudo vagrant;

echo "vagrant ALL=(ALL) NOPASSWD:ALL" | sudo tee -a /etc/sudoers;

echo "Provisioning: Vagrant - Disabling ssh password use"
# Disable password based SSH for all users now that we have a key in place
if $(grep -q '^PasswordAuthentication yes' /etc/ssh/sshd_config)
then
    sed -i -e 's/PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config
else
    echo 'PasswordAuthentication no' >> /etc/ssh/sshd_config
fi

echo "Disabling ssh password use complete";
