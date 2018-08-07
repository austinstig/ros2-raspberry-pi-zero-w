#!/bin/bash

echo "Setting Up Host!"

echo "setting up the supported locale..."
echo "following instructions: https://github.com/ros2/ros2/wiki/Linux-Development-Setup"

sudo locale-gen en_US en_US.UTF-8
sudo update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
export LANG=en_US.UTF-8

echo "setting up the ROS2 sources repositiories for ubuntu..."
sudo apt update && sudo apt install curl
curl http://repo.ros2.org/repos.key | sudo apt-key add -
sudo sh -c 'echo "deb [arch=amd64,arm64] http://repo.ros2.org/ubuntu/main `lsb_release -cs` main" > /etc/apt/sources.list.d/ros2-latest.list'
export ROS_DISTRO=bouncy
sudo apt update

# This is for Pi Zero W so go bare bones!
sudo apt install ros-$ROS_DISTRO-ros-base

echo "install development tools..."
sudo apt update && sudo apt install -y \
  build-essential \
  cmake \
  git \
  python3-colcon-common-extensions \
  python3-pip \
  python-rosdep \
  python3-vcstool \
  wget

# install some pip packages needed for testing
sudo -H python3 -m pip install -U \
  argcomplete \
  flake8 \
  flake8-blind-except \
  flake8-builtins \
  flake8-class-newline \
  flake8-comprehensions \
  flake8-deprecated \
  flake8-docstrings \
  flake8-import-order \
  flake8-quotes \
  pytest-repeat \
  pytest-rerunfailures

# install Fast-RTPS dependencies
sudo apt install --no-install-recommends -y \
  libasio-dev \
  libtinyxml2-dev


echo "Install the cross compiler..."
sudo apt install g++-aarch64-linux-gnu gcc-aarch64-linux-gnu

echo "Running the cross compilation for ROS2.."
sudo ./build_ros2.bash




