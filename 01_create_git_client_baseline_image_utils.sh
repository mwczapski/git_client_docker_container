#!/bin/bash
# #############################################
# The MIT License (MIT)
#
# Copyright © 2020 Michael Czapski
# #############################################

declare -ur _01_create_git_client_baseline_image_utils


# common environment variable values and utility functions
#
[[ ${__env_GlobalConstants} ]] || source ./utils/__env_GlobalConstants.sh

[[ ${fn__UtilityGeneric} ]] || source ./utils/fn__UtilityGeneric.sh
[[ ${__env_gitserverConstants} ]] || source ./utils/__env_gitserverConstants.sh
[[ ${__env_gitClientConstants} ]] || source ./utils/__env_gitClientConstants.sh
[[ ${fn__WSLPathToDOSandWSDPaths} ]] || source ./utils/fn__WSLPathToDOSandWSDPaths.sh

## ############################################################
## functions specific to 01_create_git_client_baseline_image.sh
## ############################################################

function fn__SetEnvironmentVariables() {
  local -r lUsage='
  Usage:
    fn__SetEnvironmentVariables \
      ${__DEBMIN_HOME} \
      ${__DEBMIN_SOURCE_IMAGE_NAME} \
      ${__GIT_CLIENT_SHELL_GLOBAL_PROFILE} \
      ${__GIT_CLIENT_IMAGE_NAME} \ 
  '
  [[ $# -lt  4 || "${0^^}" == "HELP" ]] && {
    echo -e "${__INSUFFICIENT_ARGS}\n${lUsage}"
    return ${__FAILED}
  }

  local -r pDebminHome=${1?"${lUsage}"}
  local -r pDebminSourceImageName=${2?"${lUsage}"}
  local -r pGitClientShellGlobalProfile=${3?"${lUsage}"}
  local -r pGitClientImageName=${4?"${lUsage}"}

  # set environment
  #
  __DEBMIN_HOME=${pDebminHome%%/_commonUtils} # strip _commonUtils
  declare -g __DEBMIN_HOME_DOS=$(fn__WSLPathToRealDosPath ${__DEBMIN_HOME})
  declare -g __DEBMIN_HOME_WSD=$(fn__WSLPathToWSDPath ${__DEBMIN_HOME})
  declare -g __DEBMIN_SOURCE_IMAGE_NAME=${pDebminSourceImageName}
  declare -g __TZ_PATH=Australia/Sydney
  declare -g __TZ_NAME=Australia/Sydney
  declare -g __ENV="${pGitClientShellGlobalProfile}"

  declare -g __DOCKERFILE_PATH=${__DEBMIN_HOME}/Dockerfile.${pGitClientImageName}

  ## toggles 
  declare -g __REMOVE_CONTAINER_ON_STOP=${__YES} # container started using this image is not supposed to be used for work
  declare -g __NEEDS_REBUILDING=${__NO}  # set to ${__YES} if image does not exist or Dockerfile changed

  return ${__SUCCESS}
}


function fn__Create_docker_entry_point_file() {
    declare lUsage='
  Usage: 
      fn__Create_docker_entry_point_file \
        ${__DEBMIN_HOME}      - Full path to the directory to which to write the file.
        ${__GIT_CLIENT_SHELL} - Full path to guest shell binary, for example /bin/bash or /bin/ash or /bin/sh.
  Returns:
    __DONE / __SUCCESS
    __FAILED'

  [[ $# -lt  2 || "${0^^}" == "HELP" ]] && {
    echo -e "${__INSUFFICIENT_ARGS}\n${lUsage}"
    return ${__FAILED}
  }

   local pTargetDirectory=${1?"${lUsage}"}
   local pGuestShell=${2?"${lUsage}"}

  cat <<-EOF > ${pTargetDirectory}/docker-entrypoint.sh
#!/bin/bash
set -e

# prevent container from exiting after successfull startup
# exec /bin/bash -c 'while true; do sleep 100000; done'
exec ${pGuestShell} \$@
EOF
  chmod +x ${pTargetDirectory}/docker-entrypoint.sh
aa=1  
}


function fn__CreateDockerfile() {
  declare -r lUsage='
  Usage:
    fn__CreateDockerfile
      ${__DOCKERFILE_PATH}
      ${__DEBMIN_SOURCE_IMAGE_NAME}
      ${__GIT_CLIENT_USERNAME}
      ${__GIT_CLIENT_SHELL}
      ${__GIT_CLIENT_SHELL_PROFILE}
      ${__GIT_CLIENT_SHELL_GLOBAL_PROFILE}
      ${__GIT_CLIENT_GUEST_HOME}
      ${__GITSERVER_REPOS_ROOT} 
      ${__TZ_PATH}
      ${__TZ_NAME}
    returns ${__NEEDS_REBUILDING}
  '
  [[ $# -lt  10|| "${0^^}" == "HELP" ]] && {
    echo -e "${__INSUFFICIENT_ARGS}\n${lUsage}"
    return ${__FAILED}
  }

  local -r pDckerfilePath=${1?"${lUsage}"}
  local -r pSourceImageName=${2?"${lUsage}"}
  local -r pClientUsernane=${3?"${lUsage}"}
  local -r pClientShell=${4?"${lUsage}"}
  local -r pClientShellProfile=${5?"${lUsage}"}
  local -r pClientShellGlobalProfile=${6?"${lUsage}"}
  local -r pCleitnGuestHome=${7?"${lUsage}"}
  local -r pGitserverReposRoot=${8?"${lUsage}"}
  local -r pTZPath=${9?"${lUsage}"}
  local -r pTZName=${10?"${lUsage}"}

  # create Dockerfile
  local __NEEDS_REBUILDING=${__NO}
  local STS=${__SUCCESS}

  local -r TS=$(date '+%Y%m%d_%H%M%S')

  [[ -e ${pDckerfilePath} ]] && cp ${pDckerfilePath} ${pDckerfilePath}_${TS}
    
  cat <<-EOF > ${pDckerfilePath}
FROM ${pSourceImageName}

## Dockerfile Version: ${TS}
##
# the environment variables below will be used in creating the image
# and will be available to the containers created from the image ...
#
ENV DEBMIN_USERNAME=${pClientUsernane} \\
    DEBMIN_SHELL=${pClientShell} \\
    DEBMIN_SHELL_PROFILE=${pClientShellProfile} \\
    DEBMIN_GUEST_HOME=${pCleitnGuestHome} \\
    GITSERVER_REPOS_ROOT=${pGitserverReposRoot} \\
    TZ_PATH=${pTZPath} \\
    TZ_NAME=${pTZName}  \\
    ENV=${pClientShellGlobalProfile}  \\
    DEBIAN_FRONTEND=noninteractive

COPY ./docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

# install necessary / usefull extra packages
# the following are needed to download, builld and install git from sources
# wget, unzip, build-essential, libssl-dev, libcurl4-openssl-dev, libexpat1-dev, gettex
#
RUN export DEBIAN_FRONTEND=noninteractive && \\
  apt-get update && \\
  apt-get upgrade -y && \\
  apt-get -y install apt-utils && \\
  apt-get -y install \\
    tzdata \\
    net-tools \\
    iputils-ping \\
    openssh-client \\
    nano \\
    less \\
    git && \\
\\
    git --version && \\
\\
# set timezone - I live in Sydney - change as you see fit in the env variables above
    cp -v /usr/share/zoneinfo/\${TZ_PATH} /etc/localtime && \\
    echo "\${TZ_NAME}" > /etc/timezone && \\
    echo \$(date) && \\
\\
# create non-root user 
    addgroup developers && \\
    useradd -G developers -m \${DEBMIN_USERNAME} -s \${DEBMIN_SHELL} -p \${DEBMIN_USERNAME} && \\
\\
# configure ssh client directory
    mkdir -pv \${DEBMIN_GUEST_HOME}/.ssh && \\
    chown -Rv \${DEBMIN_USERNAME}:\${DEBMIN_USERNAME} \${DEBMIN_GUEST_HOME}/.ssh
EOF

  if [[ -e ${pDckerfilePath}_${TS} ]]; then

    fn__FileSameButForDate \
      ${pDckerfilePath}  \
      ${pDckerfilePath}_${TS} \
        && STS=${__THE_SAME} \
        || STS=${__DIFFERENT}

    if [[ ${STS} -eq ${__DIFFERENT} ]]; then
      __NEEDS_REBUILDING=${__YES}
    else 
      rm -f ${pDckerfilePath}_${TS}
    fi
  fi
  return ${__NEEDS_REBUILDING}

}
