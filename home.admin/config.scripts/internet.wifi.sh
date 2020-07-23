#!/bin/bash

# command info
if [ $# -eq 0 ] || [ "$1" = "-h" ] || [ "$1" = "-help" ]; then
 echo "# handle the wifi"
 echo "# internet.wifi.sh status"
 echo "# internet.wifi.sh on SSID PASSWORD"
 echo "# internet.wifi.sh off"
 exit 1
fi

wifiIsSet=$(sudo cat /etc/wpa_supplicant/wpa_supplicant.conf 2>/dev/null| grep -c "network=")
wifiLocalIP=$(ip addr | grep 'state UP' -A2 | egrep -v 'docker0' | egrep -i '([wlan][0-9]$)' | tail -n1 | awk '{print $2}' | cut -f1 -d'/')
connected=0
if [ ${#wifiLocalIP} -gt 0 ]; then
  connected=1
fi

if [ "$1" == "status" ]; then

  echo "activated=${wifiIsSet}"
  echo "connected=${connected}"
  echo "localip='${wifiLocalIP}'"
  exit 0

elif [ "$1" == "on" ]; then

  ssid="$2"
  password="$3"

  if [ ${#ssid} -eq 0 ]; then
    echo "err='no ssid given'"
  fi

  if [ ${#password} -eq 0 ]; then
    echo "err='no password given'"
  fi

  wifiConfig='country=US\nctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev\nupdate_config=1\nnetwork={\n ssid="${ssid}"\n scan_ssid=1\n psk="${password}"\n key_mgmt=WPA-PSK\n}'
  echo "${wifiConfig}" > "/home/admin/wpa_supplicant.conf"
  sudo mv /home/admin/wpa_supplicant.conf /boot/wpa_supplicant.conf
  sudo chown root:root /boot/wpa_supplicant.conf
  sudo chmod 755 /boot/wpa_supplicant.conf

  echo "# OK - reboot needed to activate new WIFI settings"
  exit 0

elif [ "$2" == "off" ]; then

  wifiConfig='country=US\nctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev\nupdate_config=1'
  echo "${wifiConfig}" > "/home/admin/wpa_supplicant.conf"
  sudo mv /home/admin/wpa_supplicant.conf /etc/wpa_supplicant/wpa_supplicant.conf
  sudo chown root:root /etc/wpa_supplicant/wpa_supplicant.conf
  sudo chmod 600 /etc/wpa_supplicant/wpa_supplicant.conf

  sudo service networking restart
  echo "# OK - WIFI should now be off"
  exit 0

else
  echo "err='parameter not known - run with -help'"
fi
