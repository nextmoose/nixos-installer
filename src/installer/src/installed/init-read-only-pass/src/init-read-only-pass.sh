#!/bin/sh

TEMP_DIR=$(mktemp -d) &&
    cleanup() {
	rm --recursive --force ${TEMP_DIR} &&
	    true
    } &&
    trap cleanup EXIT &&
    while [ "${#}" -gt 0 ]
    do
	case "${1}" in
	    --upstream-url)
		UPSTREAM_URL="${2}" &&
		    shift 2
		;;
	    --upstream-branch)
		UPSTREAM_BRANCH="${2}" &&
		    shift 2
		;;
	    *)
		echo Unsupported Option &&
		    echo ${1} &&
		    echo ${0} &&
		    echo ${@} &&
		    exit 65
		;;
	esac
    done &&
    if [ -z "${UPSTREAM_URL}" ]
    then
	echo Undefined UPSTREAM_URL &&
	    exit 66
    elif [ -z "${UPSTREAM_BRANCH}" ]
    then
	echo Undefined UPSTREAM_URL &&
	    exit 66
    fi &&
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
    pass git remote set-url --push upstream no_push
    pass git fetch upstream ${UPSTREAM_BRANCH} &&
    pass git checkout upstream/${UPSTREAM_BRANCH} &&
    ln --symbolic --force $(which pre-commit) ${HOME}/.password-store/.git/hooks &&
    ln --symbolic --force $(which pre-push) ${HOME}/.password-store/.git/hooks &&
    true
