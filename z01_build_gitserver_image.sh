#!/bin/bash

DOCKER_NO_EXT="docker"
DOCKER_EXE="docker.exe"

readonly DEBMIN_HOME=/mnt/d/gitserver

mkdir -pv ${DEBMIN_HOME}
cd ${DEBMIN_HOME}/docker

# required for network
#
source ${DEBMIN_HOME}/docker/__env_devcicd_net.sh

# required by build command
#
readonly DEBMIN_USERNAME=gitserver
readonly DEBMIN_SHELL=/bin/bash
readonly DEBMIN_IMAGE_VERSION=1.0.0
readonly DEBMIN_IMAGE_NAME=gitserver
readonly DEBMIN_CONTAINER_NAME=${DEBMIN_USERNAME}
readonly DEBMIN_SET_STATIC_IP="--ip=${GITSERVER_STATIC_SERVER_IP}"
readonly DEBMIN_ADDHOSTS="--add-host=${DEBMIN_USERNAME}:${GITSERVER_STATIC_SERVER_IP}"

# create custom development network for all developers
#
${DOCKER_EXE} network create --attachable ${__DEVCICD_NET} --subnet ${__DEVCICD_SUBNET_ADDRESS} --gateway ${__DEVCICD_SUBNET_GATEWAY} 2>/dev/null|| true

${DOCKER_EXE} build \
  --tag ${DEBMIN_IMAGE_NAME}:${DEBMIN_IMAGE_VERSION} \
  --file ./Dockerfile.${DEBMIN_CONTAINER_NAME} \
  --network=${__DEVCICD_NET} \
  ${DEBMIN_ADDHOSTS} \
  --force-rm . \
    | tee ./${DEBMIN_IMAGE_NAME}_${DEBMIN_IMAGE_VERSION}_image_build.log
