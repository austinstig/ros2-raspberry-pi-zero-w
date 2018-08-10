# ROS2 for Raspberry Pi Zero W
These are my personal notes for installing the Robotic Operating System 2 Bouncy Release into Arch Linux ARM OS running on a Raspberry Pi Zero W. I had help from [@pokitoz](https://github.com/pokitoz) and [@WilliamLNelson](https://github.com/WilliamLNelson), and the [ROS2 for Arm](https://github.com/ros2-for-arm/ros2/wiki/ROS2-on-arm-architecture) instructions.

Instead of the aarch64 crosscompiler I used [crosstool-ng](https://crosstool-ng.github.io/) to generate a cross-compiler for my hardware. Specifically I modified the armv6-rpi-linux-gnueabi toolchain to be 1) static and 2) not build and install locales. I encountered [this](https://github.com/crosstool-ng/crosstool-ng/issues/735) issue and applied the fix. Once the cross-compiler was built I modified the ROS2-for-arm cmake file to use it.

## Host Setup
I used an Ubuntu 18.04 virtual machine as the host to build ROS2 on. Using the procedure of configure-host.sh, I configured my host as a build machine for ROS2 Bouncy.

## ROS2 Build
Once my host was setup, I built the ROS2 codebase using the crosscompile toolchain. My procedure is documented in the configure-ros2.sh script.

## Arch Image
Then I built the Arch Linux ARM Operating System for the Raspberry Pi by setting up an image to flash to an SD card. I used the configure-host.sh script passing it two arguments: 1) an argument for image size; and 2) an argument to the ROS2 install directory.
`$./configure-image.sh 8G /path/to/ros2/install`

## Setup Using Chroot
Next I mounted the image that was created into chroot jail. This allowed me to configure SSH and WiFi for headless login on first boot. I access chroot by `$sudo chroot /mnt /usr/bin/bash` and use the qemu emulator. The Arch Image configuration already copies the configuration script to the chroot /tmp folder. It accepts the SSID and Password of a WPA WiFi device as arguments.
```bash
cd /tmp
./configure-chroot.sh SSID PASSWORD
# setup the ROS2
cd /opt/ros2
source setup.bash
```

## Teardown
Once the chroot is exited the teardown script should be executed to umount the image and detach the loop device. The loop device used is saved in loopdevice.txt.
`$sudo ./teardown /dev/loopX`


## First Login
Write the image to a micro SD card and then insert the card into the Pi. It should auto-connect to the wifi and you can ssh to it using its IP address given by DHCP on the router. The username is "pi" the password is "secret".

# ISSUES
2018-08-30 - rclpy is not importing module paths correctly
