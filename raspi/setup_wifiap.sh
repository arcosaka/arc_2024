#!/bin/bash

. ~/conf.sh

SCRPTVER=24080322.08
WD_NOW=$(pwd)
GIT_RAWURL="https://raw.githubusercontent.com/arcosaka/arc_2024/main/raspi"
PATH_CONF_HOSTAP="/etc/hostapd/hostapd.conf"
PATH_CONF_DHCPCD="/etc/dhcpcd.conf"
PATH_CONF_IFACES="/etc/network/interfaces"
PATH_CONF_DNSMSQ="/etc/dnsmasq.conf"
echo "setup_wifiap.sh <$HOSTNAME> Ver($SCRPTVER)"

echo "*->apt update" \
&& sudo apt update \
&& sudo apt -y upgrade \
&& echo "OK" \
|| exit 1

echo "*->apt install" \
&& sudo apt -y install hostapd dnsmasq \
&& echo "OK" \
|| exit 2

echo "*->stop ap" \
&& sudo systemctl stop hostapd \
&& sudo systemctl stop dnsmasq \
|| exit 3

echo "*->setup hostapd" \
&& test ! -e $PATH_CONF_HOSTAP || sudo mv $PATH_CONF_HOSTAP "$PATH_CONF_HOSTAP.org"  \
&& sudo curl $GIT_RAWURL/hostapd.conf -o $PATH_CONF_HOSTAP \
&& sudo sed -i "s/<WIFI_SSID>/${WIFI_SSID}/" $PATH_CONF_HOSTAP \
&& sudo sed -i "s/<WIFI_PASS>/${WIFI_PASS}/" $PATH_CONF_HOSTAP \
&& sudo systemctl unmask hostapd \
&& sudo systemctl enable hostapd \
&& echo "OK" \
|| exit 4

echo "*->setup dhcpcd" \
&& test ! -e $PATH_CONF_DHCPCD || sudo mv $PATH_CONF_DHCPCD "$PATH_CONF_DHCPCD.org"  \
&& sudo curl $GIT_RAWURL/dhcpcd.conf -o $PATH_CONF_DHCPCD \
&& echo "OK" \
|| exit 5

echo "*->setup interfaces" \
&& test ! -e $PATH_CONF_IFACES || sudo mv $PATH_CONF_IFACES "$PATH_CONF_IFACES.org"  \
&& sudo curl $GIT_RAWURL/interfaces -o $PATH_CONF_IFACES \
&& echo "OK" \
|| exit 6

echo "*->setup dnsmasq" \
&& test ! -e $PATH_CONF_DNSMSQ || sudo mv $PATH_CONF_DNSMSQ "$PATH_CONF_DNSMSQ.org"  \
&& sudo curl $GIT_RAWURL/dnsmasq.conf -o $PATH_CONF_DNSMSQ \
&& sudo systemctl enable dnsmasq \
&& echo "OK" \
|| exit 7

echo "*->start daemon" \
&& sudo systemctl restart networking \
&& sudo systemctl start dnsmasq \
&& sudo systemctl start hostapd \
&& echo "OK" \
|| exit 8

cd $WD_NOW
echo "end setup_wifiap.sh"
