#!/bin/sh
# for Suspend Logout Reboot Halt

ACTION=`kdialog --combobox "Select an Action:" "Suspend" "Reboot" "Shutdown" "LockScreen" --default "Suspend"`

if [ -n "${ACTION}" ];then
  case $ACTION in
  Suspend)
    #kdialog --yesno "Are you sure you want to suspend?" && sudo pm-suspend
    sudo pm-suspend
    #kdesu dbus-send --system --print-reply --dest="org.freedesktop.UPower" \
    #/org/freedesktop/UPower \
    #org.freedesktop.UPower.Suspend
    #dbus-send --system --print-reply --dest=org.freedesktop.Hal \
    #/org/freedesktop/Hal/devices/computer \
    #org.freedesktop.Hal.Device.SystemPowerManagement.Suspend int32:0
    ;;
  Reboot)
    kdialog --yesno "Are you sure you want to reboot?" && atexit.sh && kdesu reboot
    ;;
  Shutdown)
    kdialog --yesno "Are you sure you want to halt?" && atexit.sh && kdesu halt
    ;;
  LockScreen)
    slock
    ;;
  esac
fi
