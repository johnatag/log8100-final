#!/bin/bash
set -eux -o pipefail

sudo apt-get clean -y
sudo apt-get autoclean -y
sudo apt-get -y update
sudo apt-get -y install git net-tools procps fail2ban logwatch --no-install-recommends

cd /tmp || exit 1

git clone https://github.com/johnatag/hardening.git

cd ./hardening || exit 1

sed -i.bak "s/CHANGEME='.*/CHANGEME='$(date +%s)'/" ./ubuntu.cfg
sed -i.bak "s/VERBOSE='.*/VERBOSE='Y'/" ./ubuntu.cfg
sed -i.bak "s/KEEP_SNAPD='.*/KEEP_SNAPD='N'/" ./ubuntu.cfg

# Don't run aide by default
sed -i "s/ f_aide/# f_aide/g" ubuntu.sh

chmod a+x ./ubuntu.sh
sudo bash ./ubuntu.sh

cd /tmp || exit 1

rm -rvf ./hardening

# Disable snapd
sudo snap remove $(snap list | awk '!/^Name|^core/ {print $1}') && sudo apt remove --purge -y snapd
sudo systemctl disable snapd.service
sudo systemctl disable snapd.socket
sudo systemctl disable snapd.seeded.service
sudo systemctl mask snapd.service
rm -rf ~/snap
sudo rm -rf /snap
sudo rm -rf /var/snap
sudo rm -rf /var/lib/snapd