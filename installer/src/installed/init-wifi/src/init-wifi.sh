#!/bin/sh

TEMP_DIR=$(mktemp -d) &&
    cleanup(){
	rm --recursive --force ${TEMP_DIR} &&
	    true
    } &&
    trap cleanup EXIT &&
    gunzip --to-stdout ${STORE_DIR}/etc/secrets.tar.gz > ${TEMP_DIR}/secrets.tar &&
    mkdir ${TEMP_DIR}/secrets &&
    tar --extract --file ${TEMP_DIR}/secrets.tar --directory ${TEMP_DIR}/secrets &&
    ls -1 ${TEMP_DIR}/secrets | while read FILE
    do
	source ${TEMP_DIR}/secrets/${FILE} &&
	    /run/wrappers/bin/sudo nmcli device wifi connect "${SSID}" password "${PASSWORD}" &&
	    true
    done &&
    true
