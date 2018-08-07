#!/bin/bash
IMAGENAME="arch-rpi-$1.img"
OS_URL="https://os.archlinuxarm.org/os"
OS_NAME="ArchLinuxARM-rpi-latest.tar.gz"

echo "setting up image..."
fallocate -l $1 ${IMAGENAME}
LO_DEVICE="$(sudo losetup --find --show ${IMAGENAME})"
PARTITION_1="${LO_DEVICE}p1"
PARTITION_2="${LO_DEVICE}p2"

echo "format the loop device: ${LO_DEVICE}..."
parted --script ${LO_DEVICE} mklabel msdos
parted --script ${LO_DEVICE} mkpart primary fat32 0% 100M
parted --script ${LO_DEVICE} mkpart primary ext4 100M 100%
mkfs.vfat -F32 ${PARTITION_1}
mkfs.ext4 -F ${PARTITION_2}

echo "mount the partitions..."
mount ${PARTITION_2} /mnt
mkdir /mnt/boot
mount ${PARTITION_1} /mnt/boot

echo "get the arch OS image..."
if [ -f ${OS_NAME} ]; then
	echo "OS downlaod already done..."
else
	echo "downloading: ${OS_NAME}..."
	wget ${OS_URL}/${OS_NAME}
fi

echo "unzip the os image..."
tar -xpf ${OS_NAME} -C /mnt > /dev/null 2>&1

echo "setup chroot environment..."
mount -t proc none /mnt/proc
mount -t sysfs none /mnt/sys
mount -o bind /dev /mnt/dev
mount -t devpts none /mnt/dev/pts

mv /mnt/etc/resolv.conf /mnt/etc/resolv.conf.bk
cp /etc/resolv.conf /mnt/etc/resolv.conf
cp /usr/bin/qemu-arm-static /mnt/usr/bin
cp ./setup-chroot.sh /mnt/tmp/setup-chroot.sh
cp &2 /mnt/opt/ros2/

echo "you should now be able to chroot: 'sudo chroot /mnt /usr/bin/bash'"
echo "it operates on the loop device: ${LO_DEVICE}"

	


