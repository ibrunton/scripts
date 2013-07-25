#!/bin/bash

os=$(awk -F= '{if ($1 == "NAME") {print $2}}' < /etc/os-release)
command=$1

# is there a way to have an associative array in bash?

case $command in
	reboot)
		if [ $os == "Arch Linux" ]
		then
			echo "sudo systemctl reboot"
		elif [ $os == "Slackware" ]
		then
			echo "sudo /sbin/shutdown -h now"
		fi
		;;
	shutdown)
		if [ $os == "Arch Linux" ]
		then
			echo "sudo systemctl poweroff"
		elif [ $os == "Slackware" ]
		then
			echo "sudo /sbin/shutdown -h now"
		fi
		;;
	suspend)
		if [ $os == "Arch Linux" ]
		then
			echo "sudo systemctl suspend"
		elif [ $os == "Slackware" ]
		then
			echo "sudo /usr/sbin/pm-suspend"
		fi
		;;
	*)
		;;
esac
