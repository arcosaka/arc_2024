#!/bin/bash

echo none > /sys/class/leds/PWR/trigger

while true; do
  echo 1 > /sys/class/leds/PWR/brightness
  sleep 1s
  echo 0 > /sys/class/leds/PWR/brightness
  sleep 9s
done
