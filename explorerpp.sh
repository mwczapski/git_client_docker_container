#!/bin/bash

echo $#
echo $0
echo $1

source ./utils/__env_YesNoSuccessFailureContants.sh

[[ ${__DOCKER_COMPOSE_NO_EXT:-NO} == "NO" ]] \
  && {
    echo "fn__DockerGeneric.sh is a pre-requisite for ${0} - sourcing it"
    source ./utils/fn__DockerGeneric.sh
  } \
  || true

readonly __DEVCICD_NET_DC_INTERNAL="devcicd_net"
readonly __DEVCICD_NET="docker_${__DEVCICD_NET_DC_INTERNAL}"

fn__DockerNetworkExists \
  ${__DEVCICD_NET} \
    && STS=${__YES} \
    || STS=${__NO}

echo "STS: ${STS}"

# if [[ $STS -eq ${__NO} ]]; then
#   fn__CreateDockerNetwork \
#     ${__DEVCICD_NET} || {
#       echo "______ Failed to create network ${__DEVCICD_NET}. Script cannot continue."
#       exit
#     }
# fi
