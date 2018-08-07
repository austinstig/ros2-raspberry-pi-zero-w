# ros2-raspberry-pi-zero-w
These are my personal notes for getting the Robotic Operating System 2 Bouncy Release running on a Raspberry Pi Zero W. I had help from many sources and this repo and associated scripts serve to consolidate my approach. This guide generally follows the ROS2 wiki for cross compiling to ARM.

The host computer I am using for these instructions is running Ubuntu 18.04 Bionic Beaver. I followed the default installation guidelines for the desktop edition running the default Gnome 3 desktop. My first step is to run the host setup script. Once the host is setup it will call the cross-compilation build. Once this is complete the next phase is to call the image_setup.sh script. This script prepares an image for an SD card which can be configured from a chroot environment. The OS to be used on the rpi0w is Arch. The image_setup.sh is called by:
`sudo ./image_setup.sh 8G /path/to/result/of/build/deps/`

Once the image_setup.sh script is complete, note the loop device its using. You will need to pass it as a path to the teardown script. Chroot into the image by:
`sudo chroot /mnt /usr/bin/bash`

Then navigate to the /tmp directory in the chroot environment. Then call the setup-chroot.sh scrip with the SSID and PSWD to your wireless internet (WPA-PSK). That way you will have wireless access on initial boot. The username will be "pi" and the password "secret".

You can also link the ROS2 libraries by going to /opt/ros2. Then issue the command to find and copy all the shared objects to /lib.
cp `find . -name "*.so"` /lib

Once the chroot is setup then you will need to exit it and then perform sudo ./teardown.sh on the host; with the loop device address passed as its argument.
