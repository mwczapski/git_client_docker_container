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

:<<-'------------Function_Usage_Note-------------------------------'
  Usage: 
    fn__SetEnvironmentVariables \
      "${__SCRIPTS_DIRECTORY_NAME}" \
      "${__GITSERVER_IMAGE_NAME}"  \
      "${__GITSERVER_SHELL_GLOBAL_PROFILE}"  \
      "__DEBMIN_HOME"  \
      "__DEBMIN_HOME_DOS"  \
      "__DEBMIN_HOME_WSD" \
      "rDebminSourceImageName"  \
      "__TZ_PATH"  \
      "__TZ_NAME"  \
      "__ENV"  \
      "__DOCKERFILE_PATH"  \
      "__REMOVE_CONTAINER_ON_STOP"  \
      "__NEEDS_REBUILDING"  \
  Returns:
    ${__SUCCESS}
    ${__FAILED} and error string on stdout
  Expects in environment:
    Constants from __env_GlobalConstants
------------Function_Usage_Note-------------------------------
function fn__SetEnvironmentVariables() {
  local -r lUsage='
  Usage: 
    fn__SetEnvironmentVariables \
      "${__SCRIPTS_DIRECTORY_NAME}" \
      "${__GITSERVER_IMAGE_NAME}"  \
      "${__GITSERVER_SHELL_GLOBAL_PROFILE}"  \
      "__DEBMIN_HOME"  \
      "__DEBMIN_HOME_DOS"  \
      "__DEBMIN_HOME_WSD" \
      "__DOCKERFILE_PATH"  \
      "__REMOVE_CONTAINER_ON_STOP"  \
      "__NEEDS_REBUILDING"  \
    '
  # this picks up missing arguments
  #
  [[ $# -lt 9 || "${0^^}" == "HELP" ]] && {
    echo -e "${__INSUFFICIENT_ARGS}\n${lUsage}"
    return ${__FAILED}
  }

  test -z ${1} 2>/dev/null && { echo "1st Argument value, '${1}', is invalid"; return ${__FAILED} ; }
  test -z ${2} 2>/dev/null && { echo "2nd Argument value, '${2}', is invalid"; return ${__FAILED} ; }
  test -z ${3} 2>/dev/null && { echo "3rd Argument value, '${3}', is invalid"; return ${__FAILED} ; }

  fn__RefVariableExists ${5} || { echo "4th Argument value, '${4}', is invalid"; return ${__FAILED} ; }
  fn__RefVariableExists ${5} || { echo "5th Argument value, '${5}', is invalid"; return ${__FAILED} ; }
  fn__RefVariableExists ${6} || { echo "6th Argument value, '${6}', is invalid"; return ${__FAILED} ; }
  fn__RefVariableExists ${7} || { echo "7th Argument value, '${7}', is invalid"; return ${__FAILED} ; }
  fn__RefVariableExists ${8} || { echo "8th Argument value, '${8}', is invalid"; return ${__FAILED} ; }
  fn__RefVariableExists ${9} || { echo "9th Argument value, '${9}', is invalid"; return ${__FAILED} ; }

  # name reference variables
  #
  local rScriptsDirectoryName=${1}
  local rGitserverImageName=${2}
  local rGitserverShellGlobalProfile=${3}
  local -n rDebminHome=${4}
  local -n rDebminHomeDOS=${5}
  local -n rDebminHomeWSD=${6}
  local -n rDockerfilePath=${7}
  local -n rRemoveContainerOnStop=${8}
  local -n rNeedsRebuilding=${9}

  test ${#rScriptsDirectoryName} -lt 1 &&  { echo "1st Argument, '${1}', must have a valid value"; return ${__FAILED} ; }
  test ${#rGitserverImageName} -lt 1 &&  { echo "2nd Argument, '${2}', must have a valid value"; return ${__FAILED} ; }
  test ${#rGitserverShellGlobalProfile} -lt 1 &&  { echo "3rd Argument, '${3}', must have a valid value"; return ${__FAILED} ; }
  test ${#rDebminHome} -lt 1 &&  { echo "4th Argument, '${4}', must have a valid value"; return ${__FAILED} ; }

  # derived values
  #
  rDebminHome=${rDebminHome%%/${rScriptsDirectoryName}} # strip _commonUtils

  cd ${rDebminHome} 2>/dev/null && STS=$? || STS=$?
  [[ ${STS} -ne ${__SUCCESS} ]] && { echo "cd: ${rDebminHome}: No such file or directory"; return ${__FAILED}; }

  rDebminHomeDOS=$(fn__WSLPathToRealDosPath ${rDebminHome})
  rDebminHomeWSD=$(fn__WSLPathToWSDPath ${rDebminHome})
  rDockerfilePath=${rDebminHome}/Dockerfile.${rGitserverImageName}

  ## options toggles 
  rRemoveContainerOnStop=${__YES} # container started using this image is nto supposed to be used for work
  rNeedsRebuilding=${__NO}  # set to ${__YES} if image does not exist of Dockerfile changed

  # echo "rDebminHome: |${rDebminHome}|"
  # echo "rDebminHomeDOS: |${rDebminHomeDOS}|"
  # echo "rDebminHomeWSD: |${rDebminHomeWSD}|"
  # echo "rDockerfilePath: |${rDockerfilePath}|"
  # echo "rRemoveContainerOnStop: |${rRemoveContainerOnStop}|"
  # echo "rNeedsRebuilding: |${rNeedsRebuilding}|"

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
# https://askubuntu.com/questions/258219/how-do-i-make-apt-get-install-less-noisy
# -o=Dpkg::Use-Pty=0 
#
RUN \\
  export DEBIAN_FRONTEND=noninteractive && \\
  apt-get -qq -o=Dpkg::Use-Pty=0 update && \\
  apt-get -qq -o=Dpkg::Use-Pty=0 upgrade -y && \\
  apt-get -qq -o=Dpkg::Use-Pty=0 -y install --no-install-recommends apt-utils && \\
  apt-get -qq -o=Dpkg::Use-Pty=0 install \\
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
# set timezone - I live in Sydney - change as you see fit in the env variables above, 
# or in __env_GlobalConstants.sh before running 01_create_git_client_baseline_image.sh
# which produces this Dockerfile
#
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
