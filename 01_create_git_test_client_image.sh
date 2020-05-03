#!/bin/bash

set -o pipefail
set -o errexit

traperr() {
  echo "ERROR: ------------------------------------------------"
  echo "ERROR: ${BASH_SOURCE[1]} at about ${BASH_LINENO[0]}"
  echo "ERROR: ------------------------------------------------"
}
set -o errtrace
trap traperr ERR

# common environment variable values and utility functions
#
[[ ${__env_YesNoSuccessFailureContants} ]] || source ./utils/__env_YesNoSuccessFailureContants.sh

[[ ${fn__DockerGeneric} ]] || source ./utils/fn__DockerGeneric.sh
[[ ${__env_devcicd_net} ]] || source ./utils/__env_devcicd_net.sh
[[ ${__env_gitserverConstants} ]] || source ./utils/__env_gitserverConstants.sh
[[ ${__env_gitTestClientConstants} ]] || source ./utils/__env_gitTestClientConstants.sh

[[ ${fn__WSLPathToDOSandWSDPaths} ]] || source ./utils/fn__WSLPathToDOSandWSDPaths.sh
[[ ${fn__ConfirmYN} ]] || source ./utils/fn__ConfirmYN.sh
[[ ${fn__FileSameButForDate} ]] || source ./utils/fn__FileSameButForDate.sh

[[ ${fn__CreateWindowsShortcut} ]] || source ./utils/fn__CreateWindowsShortcut.sh

## #######################################################################################

function fn__SetEnvironmentVariables() {

  # set environment
  #
  mkdir -pv ${__DEBMIN_HOME}
  cd ${__DEBMIN_HOME}

  __DEBMIN_HOME=${__DEBMIN_HOME%%/_commonUtils} # strip _commonUtils
  __DEBMIN_HOME_DOS=$(fn__WSLPathToRealDosPath ${__DEBMIN_HOME})
  __DEBMIN_HOME_WSD=$(fn__WSLPathToWSDPath ${__DEBMIN_HOME})
  __DEBMIN_SOURCE_IMAGE_NAME="bitnami/minideb:jessie"
  __TZ_PATH=Australia/Sydney
  __TZ_NAME=Australia/Sydney
  __ENV="${__GIT_TEST_CLIENT_SHELL_GLOBAL_PROFILE}"

  __DOCKERFILE_PATH=${__DEBMIN_HOME}/Dockerfile.${__GIT_TEST_CLIENT_IMAGE_NAME}

  ## toggles 
  __REMOVE_CONTAINER_ON_STOP=${__YES} # container started using this image is nto supposed to be used for work
  __NEEDS_REBUILDING=${__NO}  # set to ${__YES} if image does not exist of Dockerfile changed

}

function fn__Create_docker_entry_point_file() {
  [[ $# -lt  1 || "${0^^}" == "HELP" ]] && {
    echo '
  Usage: 
      fn__Create_docker_entry_point_file \
        ${__GIT_TEST_CLIENT_SHELL}
'
    return ${__FAILED}
  }
   local pGuestShell=${1?"Full path to guest's shell binary, for example /bin/bash or /bin/ash or /bin/sh"}

  cat <<-EOF > ${__DEBMIN_HOME}/docker-entrypoint.sh
#!/bin/bash
set -e

# prevent container from exiting after successfull startup
# exec /bin/bash -c 'while true; do sleep 100000; done'
exec ${pGuestShell} \$@
EOF
  chmod +x ${__DEBMIN_HOME}/docker-entrypoint.sh
}



function fn__CreateDockerfile() {

  # create Dockerfile
  local __NEEDS_REBUILDING=${__NO}
  local STS=${__SUCCESS}

  local TS=$(date '+%Y%m%d_%H%M%S')
  [[ -e ${__DOCKERFILE_PATH} ]] && cp ${__DOCKERFILE_PATH} ${__DOCKERFILE_PATH}_${TS}
    
  cat <<-EOF > ${__DOCKERFILE_PATH}
FROM ${__DEBMIN_SOURCE_IMAGE_NAME}

## Dockerfile Version: ${TS}
##
# the environment variables below will be used in creating the image
# and will be available to the containers created from the image ...
#
ENV DEBMIN_USERNAME=${__GIT_TEST_CLIENT_USERNAME} \\
    DEBMIN_SHELL=${__GIT_TEST_CLIENT_SHELL} \\
    DEBMIN_SHELL_PROFILE=${__GIT_TEST_CLIENT_SHELL_PROFILE} \\
    DEBMIN_GUEST_HOME=${__GIT_TEST_CLIENT_GUEST_HOME} \\
    GITSERVER_REPOS_ROOT=${__GITSERVER_REPOS_ROOT} \\
    TZ_PATH=${__TZ_PATH} \\
    TZ_NAME=${__TZ_NAME}  \\
    ENV=${__ENV}  \\
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

## ##########################################################################
## ##########################################################################
## 
## lookup https://git-scm.com/docs/git-shell to create git-shell-commands for use over ssh
## like help, list, backup and suchlike
## 
## ##########################################################################
## ##########################################################################

  if [[ -e ${__DOCKERFILE_PATH}_${TS} ]]; then

    fn__FileSameButForDate \
      ${__DOCKERFILE_PATH}  \
      ${__DOCKERFILE_PATH}_${TS} \
        && STS=${__THE_SAME} \
        || STS=${__DIFFERENT}

    if [[ ${STS} -eq ${__DIFFERENT} ]]; then
      __NEEDS_REBUILDING=${__YES}
    fi
  fi
  return ${__NEEDS_REBUILDING}

}

function fnUpdateOwnershipOfNonRootUserResources() {
  local lUsage='
      Usage: 
        fnUpdateOwnershipOfNonRootUserResources  \
          ${__GIT_TEST_CLIENT_CONTAINER_NAME} \
          ${__GIT_USERNAME} \
          ${DEBMIN_GUEST_HOME}  \
          ${__GIT_TEST_CLIENT_SHELL}  \
          ${__GITSERVER_REPOS_ROOT}
      '
  [[ $# -lt  4 || "${0^^}" == "HELP" ]] && {
    echo ${lUsage}
    return ${__FAILED}
  }
  pContainerName=${1?"${lUsage}"}
  pGitUsername=${2?"${lUsage}"}
  pGuestHome=${3?"${lUsage}"}
  pContainerShell=${4?"${lUsage}"}
  pGitReposRoot=${5?"${lUsage}"}

  ${__DOCKER_EXE} container exec -itu root -w ${pGitReposRoot} ${pContainerName} ${pContainerShell} -lc "
  chown -R ${pGitUsername}:${pGitUsername} ${pGuestHome}
  chown -R ${pGitUsername}:${pGitUsername} ${pGitReposRoot}
  "
  echo "_____ Updated ownership of ${pGitUsername} resources on ${pContainerName}"
}

## ##################################################################################
## ##################################################################################
## 
## ##################################################################################
## ##################################################################################

# is there a command line argument that asks for the image to be uploaded ot the remote docker repository?

fn__PushToRemoteDockerRepo ${1} && STS=${__YES} || STS=${__NO} 
readonly __PUSH_TO_REMOTE_DOCKER_REPO=$STS
echo "______ Push of the image to the remote Docker repository has $([[ ${__PUSH_TO_REMOTE_DOCKER_REPO} -eq ${__NO} ]] && echo "NOT ")been requested."

# confirm working directory
#
__DEBMIN_HOME=$(pwd | sed 's|/_commonUtils||')

fn__ConfirmYN "Artefacts location will be ${__DEBMIN_HOME} - Is this correct?" && true || {
  echo -e "______ Aborting ...\n"
  exit
}


fn__SetEnvironmentVariables ## && STS=${__SUCCESS} || STS=${__FAILED} # let it fail 
echo "_____ Set environment variables" 


fn__Create_docker_entry_point_file ${__GIT_TEST_CLIENT_SHELL} ## && STS=${__SUCCESS} || STS=${__FAILED} # let it fail 
echo "_____ Created docker-entrypoint.sh" 


fn__CreateDockerfile && __REBUILD_IMAGE=${__YES} || __REBUILD_IMAGE=${__NO} # if dockerfile has not changed
echo "_____ Created Dockerfile: ${__DOCKERFILE_PATH}" 

fn__ImageExists \
  "${__GIT_TEST_CLIENT_IMAGE_NAME}:${__GIT_TEST_CLIENT_IMAGE_VERSION}" &&
    __IMAGE_EXISTS=${__YES} || 
    __IMAGE_EXISTS=${__NO}
[[ ${STS} -eq ${__YES} ]]  \
  && echo "_____ Image ${__GIT_TEST_CLIENT_IMAGE_NAME}:${__GIT_TEST_CLIENT_IMAGE_VERSION} exists" \
  || {
    echo "_____ Image ${__GIT_TEST_CLIENT_IMAGE_NAME}:${__GIT_TEST_CLIENT_IMAGE_VERSION} does not exist"
    __REBUILD_IMAGE=${__YES}
  }

if [[ ${__REBUILD_IMAGE} -eq ${__YES} ]]; then
  fn__BuildImage  \
    ${__REBUILD_IMAGE} \
    ${__GIT_TEST_CLIENT_IMAGE_NAME} \
    ${__GIT_TEST_CLIENT_IMAGE_VERSION} \
    ${__DEBMIN_HOME_DOS}/Dockerfile.${__GIT_TEST_CLIENT_IMAGE_NAME} \
    ${__DEVCICD_NET} ## && STS=${__SUCCESS} || STS=${__FAILED} # let it abort if failed
  echo "_____ Image ${__GIT_TEST_CLIENT_IMAGE_NAME}:${__GIT_TEST_CLIENT_IMAGE_VERSION} (re-)built"
fi


fn__ContainerExists \
  ${__GIT_TEST_CLIENT_CONTAINER_NAME} \
    && STS=${__YES} \
    || STS=${__NO}

if [[ $STS -eq ${__YES} ]]; then
  echo "_____ Container ${__GIT_TEST_CLIENT_CONTAINER_NAME} exists - will stopp and remove"
  fn__StopAndRemoveContainer  \
    ${__GIT_TEST_CLIENT_CONTAINER_NAME} \
      && STS=${__YES} \
      || STS=${__NO}
  echo "_____ Container ${__GIT_TEST_CLIENT_CONTAINER_NAME} stopped and removed"
else
  echo "_____ Container ${__GIT_TEST_CLIENT_CONTAINER_NAME} does not exist"
fi


fn__RunContainerDetached \
  ${__GIT_TEST_CLIENT_IMAGE_NAME} \
  ${__GIT_TEST_CLIENT_IMAGE_VERSION} \
  ${__GIT_TEST_CLIENT_CONTAINER_NAME} \
  ${__GIT_TEST_CLIENT_HOST_NAME} \
  ${__REMOVE_CONTAINER_ON_STOP} \
  ${__EMPTY} \
  ${__DEVCICD_NET} \
    && STS=${__DONE} || \
    STS=${__FAILED}
echo "_____ Container ${__GIT_TEST_CLIENT_CONTAINER_NAME} started"

if [[ $STS -eq ${__DONE} ]]; then

  fn__CommitChangesStopContainerAndSaveImage   \
    "${__GIT_TEST_CLIENT_CONTAINER_NAME}" \
    "${__GIT_TEST_CLIENT_IMAGE_NAME}" \
    "${__GIT_TEST_CLIENT_IMAGE_VERSION}"
  echo "_____ Commited changes to ${__GIT_TEST_CLIENT_IMAGE_NAME}:${__GIT_TEST_CLIENT_IMAGE_VERSION} and Stopped container ${__CONTAINER_NAME}"

  if [[ ${__PUSH_TO_REMOTE_DOCKER_REPO} == ${__YES} ]]; then
    fn__PushImageToRemoteRepository   \
      "${__DOCKER_REPOSITORY_HOST}"  \
      "${__GIT_TEST_CLIENT_IMAGE_NAME}" \
      "${__GIT_TEST_CLIENT_IMAGE_VERSION}"
    echo "_____ Image tagged and pushed to repository as ${__DOCKER_REPOSITORY_HOST}/${__GIT_TEST_CLIENT_IMAGE_NAME}:${__GIT_TEST_CLIENT_IMAGE_VERSION}" 
  else
    echo "_____ On user request on user request image ${__GIT_TEST_CLIENT_IMAGE_NAME}:${__GIT_TEST_CLIENT_IMAGE_VERSION} has NOT been pushed to Docker repository ${__DOCKER_REPOSITORY_HOST}" 
  fi
else
  ${__INDUCE_ERROR}
fi

echo "Done..."


# if [[ $STS -eq ${__DONE} ]]; then

#   fnUpdateOwnershipOfNonRootUserResources  \
#     ${__GIT_TEST_CLIENT_CONTAINER_NAME} \
#     ${__GIT_USERNAME} \
#     ${DEBMIN_GUEST_HOME}  \
#     ${__GIT_TEST_CLIENT_SHELL}  \
#     ${__GITSERVER_REPOS_ROOT}
#   echo "_____ Updated ownership of resources for user ${__GIT_USERNAME}"

#   fn__CommitChangesStopContainerAndSaveImage   \
#     "${__GIT_TEST_CLIENT_CONTAINER_NAME}" \
#     "${__GIT_TEST_CLIENT_IMAGE_NAME}" \
#     "${__GIT_TEST_CLIENT_IMAGE_VERSION}"
#   echo "_____ Commited changes to ${__GIT_TEST_CLIENT_IMAGE_NAME}:${__GIT_TEST_CLIENT_IMAGE_VERSION} and Stopped container ${__CONTAINER_NAME}"

#   if [[ ${__PUSH_TO_REMOTE_DOCKER_REPO} == ${__YES} ]]; then
#     fn__PushImageToRemoteRepository   \
#       "${__DOCKER_REPOSITORY_HOST}"  \
#       "${__GIT_TEST_CLIENT_IMAGE_NAME}" \
#       "${__GIT_TEST_CLIENT_IMAGE_VERSION}"
#     echo "_____ Image tagged and pushed to repository as ${__DOCKER_REPOSITORY_HOST}/${__GIT_TEST_CLIENT_IMAGE_NAME}:${__GIT_TEST_CLIENT_IMAGE_VERSION}" 
#   else
#     echo "_____ On user request on user request image ${__GIT_TEST_CLIENT_IMAGE_NAME}:${__GIT_TEST_CLIENT_IMAGE_VERSION} has NOT been pushed to Docker repository ${__DOCKER_REPOSITORY_HOST}" 
#   fi

# else
#   ${__INDUCE_ERROR}
# fi

# echo "Done..."
