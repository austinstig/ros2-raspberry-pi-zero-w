#!/bin/bash
echo "setting up OS in chroot..."
pacman-key --init
pacman-key --populate archlinuxarm
pacman -Syu --noconfirm vim bash-completion openssh python wget python-yaml python-setuptools git cmake asio tinyxml tinyxml2 eigen libxaw glu qt5-base opencv sudo wpa_supplicant wpa_actiond ifplugd crda dialog avahi nss-mdns base-devel python-pip

echo "configure the internet..."
echo rpi0w > /etc/hostname
sed -i "s/alarm/pi/g" /etc/passwd /etc/group /etc/shadow
mv /home/alarm "/home/pi"
echo -e "secret\nsecret" | passwd "pi"
echo '%wheel ALL=(ALL) ALL' >> /etc/sudoers.d/wheel
ln -sf /usr/lib/systemd/system/netctl-auto@.service /etc/systemd/system/multi-user.target.wants/netctl-auto@wlan0.service
ln -sf /usr/lib/systemd/system/netctl-ifplugd@.service /etc/systemd/system/multi-user.target.wants/netctl-ifplugd@eth0.service
echo -e "Description='router'\nInterface=wlan0\nConnection=wireless\nSecurity=wpa\nESSID=\"$1\"\nIP=dhcp\nKey=\"$2\"\n" > /etc/netctl/wlan0-router
echo -e "\nPermitRootLogin yes\nPasswordAuthentication yes\n" > /etc/ssh/sshd_config
/usr/bin/ssh-keygen -A
/usr/bin/sshd -f /etc/ssh/sshd_config
ln -sf /usr/lib/systemd/system/sshd.service /etc/systemd/system/multi-user.target.wants/sshd.service
rmdir /var/empty
mkdir /var/empty

echo "setup zero-conf networking..."
sed -i '/^hosts: /s/files dns/files mdns dns/' /etc/nsswitch.conf
ln -sf /usr/lib/systemd/system/avahi-daemon.service /etc/systemd/system/multi-user.target.wants/avahi-daemon.service


pip install colcon-common-extensions 

echo "chroot OS configured!"

