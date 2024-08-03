#!/bin/bash

SCRPTVER=24080321.24
WD_NOW=$(pwd)
GIT_RAWURL="https://raw.githubusercontent.com/arcosaka/arc_2024/main/raspi"
echo "setup.sh <$(hostname)> Ver($SCRPTVER)"

cd ~/

if [ ! -e ~/conf.sh ]; then
    echo "*->locale setting" \
    && curl $GIT_RAWURL/conf.sh -o ~/conf.sh \
    && chmod 700 ~/*.sh \
    && echo "OK" \
    || exit -1
fi
. ~/conf.sh

echo "*->locale setting"
if [ -e /sys/firmware/devicetree/base/model ]; then
    # Raspberry Pi OS
    osname="raspi"
else
    echo "Undefined OS"
    exit 1
fi

echo $osname

sudo apt update
case $osname in
    "raspi")
        APTINSTALL_JP="task-japanese locales-all";;
    *)
        echo "Undefined OS"
        exit 1
esac

sudo apt -y install $APTINSTALL_JP

sudo localectl set-locale LANG=ja_JP.UTF-8 LANGUAGE="ja_JP:ja"
source /etc/default/locale

sudo timedatectl set-timezone Asia/Tokyo

echo "****************"
echo $LANG
echo "****************"

echo "*->apt update install" \
&& sudo apt -y upgrade \
&& sudo apt -y install \
   git nano avahi-daemon apt-utils bash-completion bind9-host dnsutils fonts-ipaexfont cmake libjpeg-dev gcc g++ git v4l-utils python3 python3-pip screen \
&& echo "OK" \
|| exit 2

echo "*->system reload" \
&& sudo systemctl daemon-reload \
&& echo "OK" \
|| exit 3

echo "*->led config"
case $osname in
    "raspi")
        curl $GIT_RAWURL/pwrled.sh -o ~/pwrled.sh \
        && echo "OK"
        ;;
    *)
        echo "Skip";;
esac

echo "*->git clone mjpg-streamer" \
&& git clone https://github.com/neuralassembly/mjpg-streamer.git \
&& cd ./mjpg-streamer/mjpg-streamer-experimental \
&& make \
&& sudo make install \
&& sudo mkdir /var/log/stream/ \
&& sudo chmod 777 /var/log/stream/ \
&& echo "OK" \
|| exit 4
cd ~/

echo "*->git clone arcosaka_2024" \
&& git clone https://github.com/arcosaka/arc_2024.git \
&& echo "OK" \
|| exit 5

cd $WD_NOW

echo "Please reboot the system."
echo "end setup.sh"
