#!/bin/sh

${GNUPG}/bin/gpg --help &&
    TEMP_DIR=$(mktemp -d) &&
    cleanup() {
	rm --recursive --force ${TEMP_DIR}
    } &&
    trap cleanup EXIT &&
    read -s -p "SYMMETRIC PASSWORD? " SYMMETRIC_PASSWORD &&
    #    echo "${SYMMETRIC_PASSWORD}" | gpg --batch --passphrase-fd 0 --output ${TEMP_DIR}/secrets.tar ${1} &&
    true
