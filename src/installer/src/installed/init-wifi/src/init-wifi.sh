#!/bin/sh

source ${STORE_DIR}/etc/wifi.env &&
    nmcli device wifi connect "${SSID}" password "${PASSWORD}" &&
    true
