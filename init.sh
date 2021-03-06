#!/bin/sh

#
# Script options (exit script on command fail).
#
set -e

CURL_OPTIONS_DEFAULT=
SIGNAL_DEFAULT="SIGHUP"
INOTIFY_EVENTS_DEFAULT="create,delete,modify,move"
INOTIFY_OPTONS_DEFAULT='--monitor --exclude=/*.sw[px]$'
ACTION_DEFAULT="kill"
DOCKER_ENGINE_API_VERSION_DEFAULT="docker"

#
# Display settings on standard out.
#
echo "inotify settings"
echo "================"
echo
echo "  Container:                  ${CONTAINER}"
echo "  Volumes:                    ${VOLUMES}"
echo "  Curl_Options:               ${CURL_OPTIONS:=${CURL_OPTIONS_DEFAULT}}"
echo "  Action:                     ${ACTION:=${ACTION_DEFAULT}}"
echo "  Action_Params:              ${ACTION_PARAMS}"
echo "  Signal:                     ${SIGNAL:=${SIGNAL_DEFAULT}}"
echo "  Inotify_Events:             ${INOTIFY_EVENTS:=${INOTIFY_EVENTS_DEFAULT}}"
echo "  Inotify_Options:            ${INOTIFY_OPTONS:=${INOTIFY_OPTONS_DEFAULT}}"
echo "  Docker_Engine_API_VERSION:  ${DOCKER_ENGINE_API_VERSION:=${DOCKER_ENGINE_API_VERSION_DEFAULT}}"
echo

#
# Inotify part.
#
echo "[Starting inotifywait...]"
inotifywait -e ${INOTIFY_EVENTS} ${INOTIFY_OPTONS} "${VOLUMES}" | \
    while read -r notifies;
    do
    	echo "$notifies"
        if [ "$ACTION" = "kill" ]; then
            echo "notify received, sent signal ${SIGNAL} to container ${CONTAINER}"
            curl ${CURL_OPTIONS} -X POST --unix-socket /var/run/docker.sock http:/${DOCKER_ENGINE_API_VERSION}/containers/${CONTAINER}/kill?signal=${SIGNAL} > /proc/1/fd/1 2>/proc/1/fd/2
        else
            echo "notify received, execute the ${ACTION} for container ${CONTAINER}"
            curl ${CURL_OPTIONS} -X POST --unix-socket /var/run/docker.sock http:/${DOCKER_ENGINE_API_VERSION}/containers/${CONTAINER}/${ACTION}?${ACTION_PARAMS} > /proc/1/fd/1 2>/proc/1/fd/2
        fi
    done
