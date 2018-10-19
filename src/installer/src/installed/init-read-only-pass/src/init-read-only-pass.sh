#!/bin/sh

TEMP_DIR=$(mktemp -d) &&
    cleanup() {
	rm --recursive --force ${TEMP_DIR} &&
    } &&
    gunzip --to-stdout ${STORE_DIR}/etc/secrets.tar.gz > ${TEMP_DIR}/secrets.tar &&
    mkdir ${TEMP_DIR}/secrets &&
    tar --extract --file ${TEMP_DIR}/secrets.tar --directory ${TEMP_DIR}/secrets &&
    gpg --import ${TEMP_DIR}/secrets/gpg.secret.key &&
    gpg --import-ownertrust ${TEMP_DIR}/secrets/gpg.owner.trust &&
    gpg2 --import ${TEMP_DIR}/secrets/gpg2.secret.key &&
    gpg2 --import-ownertrust ${TEMP_DIR}/secrets/gpg2.owner.trust &&
    pass init $(gpg --list-keys --with-colon | head --lines 5 | tail --lines 1 | cut --fields 5 --delimiter ":") &&
    pass git init &&
    pass git remote add upstream ${UPSTREAM_URL} &&
    pass git remote fetch origin ${UPSTREAM_BRANCH} &&
    pass git checkout origin/${UPSTREAM_BRANCH} &&
    ln --symbolic --force pre-commit ${HOME}/.password-store/.git/hooks &&
    trust
