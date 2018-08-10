#!/bin/bash

set -e

# Apply a patch if not already applied
function try_apply_patch {
  PATCH_TARGET_DIR=$1
  PATCH_FILE_LOC=$2

  pushd $PATCH_TARGET_DIR >/dev/null
  # Check if the patch has already been applied or not
  set +e
  patch -p1 -N --dry-run --silent < $PATCH_FILE_LOC 2>/dev/null
  if [ $? -eq 0 ]; then
    patch -p1 -N < $PATCH_FILE_LOC
  fi
  set -e
  popd >/dev/null
}

# setup variables
CROSS_COMPILE=armv6-rpi-linux-gnueabi-
TOOLCHAIN=armv6_toolchain.cmake
PROJECT_ROOT=`pwd`
ROS_ARM_ROOT=$PROJECT_ROOT/deps/ros2_armv6

# setup workspace
mkdir -p $ROS_ARM_ROOT/src
pushd $ROS_ARM_ROOT >/dev/null

# Download ROS2 code
if [ ! -f aarch64_toolchainfile.cmake ]; then
  wget https://raw.githubusercontent.com/ros2/ros2/release-latest/ros2.repos
  vcs-import src < ros2.repos
  echo "update cmake file..."
  echo "set(PATH_POCO_LIB \"\${CMAKE_CURRENT_LIST_DIR}/build/poco_vendor/poco_external_project_install/lib/\")" >> ${TOOLCHAIN}
  echo "set(PATH_YAML_LIB \"\${CMAKE_CURRENT_LIST_DIR}/build/libyaml_vendor/libyaml_install/lib/\")" >> ${TOOLCHAIN}
  echo "set(CMAKE_BUILD_RPATH \"\${PATH_POCO_LIB};\${PATH_YAML_LIB}\")" >> ${TOOLCHAIN}
fi

# Ignore select ROS packages
# NB: Currently ignores RCLPY -- the console ros2 applications won't work
#                                without this but the C++ interface is fine
#sed -i \
#  -r \
#  's/<build(.+?py.+?)/<\!\-\-build\1\-\->/' \
#  src/ros2/rosidl_defaults/rosidl_default_generators/package.xml
touch \
  src/ros/resource_retriever/COLCON_IGNORE \
  src/ros2/orocos_kinematics_dynamics/COLCON_IGNORE \
  src/ros2/kdl_parser/COLCON_IGNORE \
  src/ros2/geometry2/COLCON_IGNORE \
  src/ros2/rviz/COLCON_IGNORE \
  src/ros2/robot_state_publisher/COLCON_IGNORE \
  src/ros2/system_tests/COLCON_IGNORE \
  src/ros2/examples/COLCON_IGNORE \
  src/ros2/urdf/COLCON_IGNORE \
  src/ros2/urdfdom/COLCON_IGNORE \
  src/ros2/demos/COLCON_IGNORE \
  src/ros-perception/laser_geometry/COLCON_IGNORE

## Patch ROS packages
try_apply_patch \
  src/ros2/tlsf/tlsf \
  $PROJECT_ROOT/tlsf_CMakeLists.patch
try_apply_patch \
  src/ros2/tlsf/tlsf \
  $PROJECT_ROOT/tlsf_package.patch

# For some reason, libyaml needs to be built first otherwise cmake doesn't
# find it
colcon build \
  --cmake-force-configure \
  --cmake-args \
    --no-warn-unused-cli \
    -DCMAKE_TOOLCHAIN_FILE=`pwd`/${TOOLCHAIN} \
    -DTHIRDPARTY=ON \
    -DBUILD_TESTING:BOOL=OFF \
    -DCMAKE_BUILD_RPATH="`pwd`/build/poco_vendor/poco_external_project_install/lib/;`pwd`/build/libyaml_vendor/libyaml_install/lib/"
