#!/bin/bash
source loopdevice.txt
echo "cleanup chroot..."
rm /mnt/etc/resolv.conf
mv /mnt/etc/resolv.conf.bk /mnt/etc/resolv.conf
rm /mnt/usr/bin/qemu-arm-static
umount -l /mnt/dev
umount -l /mnt/devpts
umount /mnt/proc
umount /mnt/sys
umount /mnt/boot
umount /mnt
umount -l ${LO_DEVICE}p1
umount -l ${LO_DEVICE}p2
losetup --detach ${LO_DEVICE}
echo "teardown complete..."
