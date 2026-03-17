#!/bin/bash
######################################################################################
# ROS2
#
# This stack will consist of ROS2 install
#
# To install
#    ./pc_install.sh
######################################################################################

# Update package lists
cd ~
sudo apt update

# Install ROS 2 Jazzy setup scripts
if ! [ -d "ros2_setup_scripts_ubuntu" ]; then
  git clone https://github.com/Tiryoh/ros2_setup_scripts_ubuntu.git
fi
~/ros2_setup_scripts_ubuntu/ros2-jazzy-ros-base-main.sh
source /opt/ros/jazzy/setup.bash

# Create ROS 2 workspace and clone Mini Pupper ROS repository
mkdir -p ~/ros2_ws/src
cd ~/ros2_ws/src
if ! [ -d "mini_pupper_ros" ]; then
  git clone https://github.com/MushfiqueTM/mini_pupper_ros.git -b ros2-jazzy mini_pupper_ros
fi
vcs import < mini_pupper_ros/.minipupper.repos --recursive

# Fix EKF time offset for Gazebo Harmonic sim time compatibility
sed -i 's/transform_time_offset: 0.045/transform_time_offset: 0.0/' ~/ros2_ws/src/champ/champ/champ_base/config/ekf/base_to_footprint.yaml
  
# Disable legacy Gazebo Classic packages (not needed with ros_gz)
for pkg in champ_gazebo champ_description champ_bringup champ_navigation champ_config; do
  touch champ/champ/$pkg/COLCON_IGNORE
done

# Install dependencies and build the ROS 2 packages
cd ~/ros2_ws
rosdep install --from-paths src --ignore-src -r -y
sudo apt install -y ros-jazzy-teleop-twist-keyboard ros-jazzy-teleop-twist-joy
sudo apt install -y ros-jazzy-v4l2-camera ros-jazzy-image-transport-plugins
sudo apt install -y ros-jazzy-rqt*
sudo apt install -y python3-pip

# Gazebo Harmonic packages
sudo apt install -y ros-jazzy-gz-ros2-control
sudo apt install -y ros-jazzy-ros-gz
sudo apt install -y ros-jazzy-ros-gz-sim
sudo apt install -y ros-jazzy-ros-gz-bridge

# New LD Lidar driver dependency
sudo apt install -y libudev-dev

pip3 install simple_pid --break-system-packages
colcon build --symlink-install
