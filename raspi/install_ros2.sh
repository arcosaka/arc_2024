#!/bin/bash

. ~/conf.sh

SCRPTVER=24073020.54
WD_NOW=$(pwd)
echo "install_ros2.sh <$HOSTNAME> Ver($SCRPTVER)"


echo "*->apt update" \
&& sudo apt update \
&& sudo apt -y upgrade \
&& echo "OK" \
|| exit 1

if [ ! -f /etc/apt/sources.list.d/ros2.list ]; then
    echo "*->apt install" \
    && sudo apt -y install software-properties-common curl gnupg2 lsb-release \
    && sudo curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $VERSION_CODENAME) main" | sudo tee /etc/apt/sources.list.d/ros2.list > /dev/null \
    && echo "OK" \
    || exit 2
fi

echo "*->dev-tool install" \
&& sudo apt update \
&& sudo apt -y install \
    python3-flake8-blind-except python3-flake8-class-newline python3-flake8-deprecated python3-mypy python3-pip python3-pytest python3-pytest-cov python3-pytest-mock python3-pytest-repeat python3-pytest-rerunfailures python3-pytest-runner python3-pytest-timeout ros-dev-tools \
&& echo "OK" \
|| exit 3

echo "*->ros build" \
&& mkdir -p ~/ros2_jazzy/src \
&& cd ~/ros2_jazzy \
&& vcs import --input https://raw.githubusercontent.com/ros2/ros2/jazzy/ros2.repos src \
&& sudo apt upgrade \
&& test -e "/etc/ros/rosdep/sources.list.d/20-default.list" || sudo rosdep init \
&& rosdep update \
&& rosdep install --from-paths src --ignore-src -y --skip-keys "fastcdr rti-connext-dds-6.0.1 urdfdom_headers" \
&& cd ~/ros2_jazzy \
&& colcon build --symlink-install --parallel-workers 2 \
&& echo "OK" \
|| exit 4

cd $WD_NOW
echo "end install_ros2.sh"
