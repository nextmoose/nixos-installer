#!/bin/sh

TEMPDIR=$(mktemp -d) &&
    cleanup() {
	echo ${TEMPDIR} &&
	    bash &&
	    rm --recursive --force ${TEMPDIR}
    } &&
    trap cleanup EXIT &&
    read -s -p "SYMMETRIC PASSWORD? " SYMMETRIC_PASSWORD &&
    echo "${SYMMETRIC_PASSWORD}" | gpg --batch --passphrase-fd 0 --output ${TEMPDIR}/secrets.tar ${STORE_DIR}/secrets.tar.gz &&
    true
