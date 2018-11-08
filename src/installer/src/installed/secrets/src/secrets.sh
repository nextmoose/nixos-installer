#!/bin/sh

TEMP_DIR=$(mktemp -d) &&
    cleanup() {
	rm --recursive --force ${TEMP_DIR} &&
	    true
    } &&
    trap cleanup EXIT &&
    tar --create --file ${TEMP_DIR}/secrets.tar --directory ${STORE_DIR}/etc/secrets . &&
    gzip --to-stdout ${TEMP_DIR}/secrets.tar > ${TEMP_DIR}/secrets.tar.gz &&
    gpg --batch --passphrase-fd 0 --output ${TEMP_DIR}/secrets.tar.gz.gpg ${TEMP_DIR}/secrets.tar.gz &&
    true
