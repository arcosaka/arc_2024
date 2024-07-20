#!/bin/bash

SCRPTVER=24071417.17
WD_NOW=$(pwd)
GIT_RAWURL="http://"
echo "setup.sh <$(hostname)> Ver($SCRPTVER)"

cd ~/

if [ ! -e ~/conf.sh ]; then
    echo "*->locale setting" \
    && curl $GIT_BASEURL/conf.sh -o ~/conf.sh \
    && chmod 700 ~/*.sh \
    && nano ~/conf.sh \
    && echo "OK" \
    || exit -1
fi
. /root/conf.sh

echo "*->locale setting"
if [ -e /sys/firmware/devicetree/base/model ]; then
    # Raspberry Pi OS
    osname="raspi"
else
    echo "Undefined OS"
    exit 1
fi

echo $osname

apt update
case $osname in
    "raspi"|"debian")
        APTINSTALL_JP="task-japanese locales-all";;
    *)
        echo "Undefined OS"
        exit 1
esac

apt -y install $APTINSTALL_JP

localectl set-locale LANG=ja_JP.UTF-8 LANGUAGE="ja_JP:ja"
source /etc/default/locale

timedatectl set-timezone Asia/Tokyo

echo "****************"
echo $LANG
echo "****************"

echo "*->apt update install" \
&& apt -y upgrade \
&& apt -y install nano avahi-daemon apt-utils bash-completion bind9-host dnsutils \
&& echo "OK"

echo "*->system reload" \
&& systemctl daemon-reload \
&& echo "OK"

echo "*->led config"
case $osname in
    "raspi")
        curl $GIT_BASEURL/pwrled.sh -o ~/pwrled.sh \
        && echo "OK"
        ;;
    *)
        echo "Skip";;
esac

echo "Reboot the system to reflect the settings."
echo "end setup.sh"
