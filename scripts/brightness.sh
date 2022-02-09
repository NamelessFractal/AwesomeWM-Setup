#!/bin/bash

args=$@

if [ $# -ne 1 ]; then
	echo "Expected 1 argument."
	exit 1
else
	newBrightness=$((${args[0]} + $(cat /sys/class/backlight/intel_backlight/brightness)))
	if [ $newBrightness -lt 0 ]; then
		newBrightness="0"
	elif [ $newBrightness -gt $(cat /sys/class/backlight/intel_backlight/max_brightness) ]; then
		newBrightness=$(cat /sys/class/backlight/intel_backlight/max_brightness)
	fi
	echo $(( $newBrightness * 100 / $(cat /sys/class/backlight/intel_backlight/max_brightness)))
	echo $newBrightness >> /sys/class/backlight/intel_backlight/brightness
	exit 0
fi


