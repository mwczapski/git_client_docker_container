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
source ./utils/__env_devcicd_net.sh
source ./utils/__env_gitserverConstants.sh
source ./utils/__env_YesNoSuccessFailureContants.sh

source ./utils/fn__WSLPathToDOSandWSDPaths.sh
source ./utils/fn__ConfirmYN.sh
source ./utils/fn__DockerGeneric.sh
source ./utils/fn__FileSameButForDate.sh

source ./utils/fn__CreateWindowsShortcut.sh

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
  __ENV="${__GITSERVER_SHELL_GLOBAL_PROFILE}"

  __DOCKERFILE_PATH=${__DEBMIN_HOME}/Dockerfile.${__GITSERVER_IMAGE_NAME}

  ## toggles 
  __REMOVE_CONTAINER_ON_STOP=${__YES} # container started using this image is nto supposed to be used for work
  __NEEDS_REBUILDING=${__NO}  # set to ${__YES} if image does not exist of Dockerfile changed

}

function fn__Create_docker_entry_point_file() {

  [[ $# -lt  1 || "${0^^}" == "HELP" ]] && {
    echo '
Usage: 
    fn__Create_docker_entry_point_file \
      ${__GITSERVER_SHELL}
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
ENV DEBMIN_USERNAME=${__GIT_USERNAME} \\
    DEBMIN_SHELL=${__GITSERVER_SHELL} \\
    DEBMIN_SHELL_PROFILE=${__GITSERVER_SHELL_PROFILE} \\
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
    openssh-server \\
    nano \\
# the following are needed to download, builld and install git from sources
    wget \\
    unzip \\
    build-essential \\
    libssl-dev \\
    libcurl4-openssl-dev \\
    libexpat1-dev \\
    gettext && \\
\\
# set timezone - I live in Sydney - change as you see fit in the env variables above
    cp -v /usr/share/zoneinfo/\${TZ_PATH} /etc/localtime && \\
    echo "\${TZ_NAME}" > /etc/timezone && \\
    echo \$(date) && \\
\\
# create git user
    addgroup developers && \\
    useradd -G developers -m \${DEBMIN_USERNAME} -s \${DEBMIN_SHELL} -p \${DEBMIN_USERNAME} && \\
\\
## configure git and ssh access to git repositories on this git server
    sed -i 's|#PasswordAuthentication yes|PasswordAuthentication no|' /etc/ssh/sshd_config && \\
\\
# download and install latest git
    mkdir -pv /root/Downloads/git-master && \\
    cd /root/Downloads && \\
    TS=$(date +%Y%m%d) && \\
    wget https://github.com/git/git/archive/master.zip -O /root/Downloads/git-master-${TS}.zip  && \\
    unzip /root/Downloads/git-master-${TS}.zip && \\
    cd /root/Downloads/git-master && \\
    make prefix=/usr all  && \\
    make prefix=/usr install  && \\
    git --version && \\
\\
# create user's working directory
    mkdir -pv /home/\${DEBMIN_USERNAME}/.ssh/ && \\
    touch /home/\${DEBMIN_USERNAME}/.ssh/authorized_keys && \\
    chmod 600 /home/\${DEBMIN_USERNAME}/.ssh/authorized_keys && \\
    mkdir -pv \${GITSERVER_REPOS_ROOT} && \\
    chown -Rv \${DEBMIN_USERNAME}:developers \${GITSERVER_REPOS_ROOT} && \\
    chmod -v g+rxs \${GITSERVER_REPOS_ROOT} && \\
    echo /usr/bin/git-shell >> /etc/shells && \\
    chsh git -s /usr/bin/git-shell && \\
\\
# remove git source and build tools
  apt-get update && \\
  apt-get remove \\
    wget \\
    unzip \\
    build-essential \\
    libssl-dev \\
    libcurl4-openssl-dev \\
    libexpat1-dev \\
    gettext && \\
  apt-get update && \\
    apt-get autoremove && \\
    cd / && \\
    rm -Rvf /root/Downloads
EOF

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
  # echo "__NEEDS_REBUILDING: ${__NEEDS_REBUILDING}"
  return ${__NEEDS_REBUILDING}

}

function fnUpdateOwnershipOfNonRootUserResources() {
  local lUsage='
      Usage: 
        fnUpdateOwnershipOfNonRootUserResources  \
          ${__GITSERVER_CONTAINER_NAME} \
          ${__GIT_USERNAME} \
          ${__GITSERVER_GUEST_HOME}  \
          ${__GITSERVER_SHELL}  \
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
  echo "______ Updated ownership of ${pGitUsername} resources on ${pContainerName}"
}

## ##################################################################################
## ##################################################################################
## 
## ##################################################################################
## ##################################################################################

# confirm working directory
#
__DEBMIN_HOME=$(pwd | sed 's|/_commonUtils||')

fn__ConfirmYN "Artefacts location will be ${__DEBMIN_HOME} - Is this correct?" && true || {
  echo -e "_______ Aborting ...\n"
  exit
}

fn__SetEnvironmentVariables ## && STS=${__SUCCESS} || STS=${__FAILED} # let it fail 
echo "______ Set environment variables" 


fn__Create_docker_entry_point_file ${__GITSERVER_SHELL} ## && STS=${__SUCCESS} || STS=${__FAILED} # let it fail 
echo "______ Created docker-entrypoint.sh" 


fn__CreateDockerfile && __REBUILD_IMAGE=${__YES} || __REBUILD_IMAGE=${__NO} # if dockerfile has not changed
echo "______ Created Dockerfile: ${__DOCKERFILE_PATH}" 

fn__ImageExists \
  "${__GITSERVER_IMAGE_NAME}:${__GITSERVER_IMAGE_VERSION}" &&
    __IMAGE_EXISTS=${__YES} || 
    __IMAGE_EXISTS=${__NO}
[[ ${STS} -eq ${__YES} ]]  \
  && echo "______ Image ${__GITSERVER_IMAGE_NAME}:${__GITSERVER_IMAGE_VERSION} exists" \
  || echo "______ Image ${__GITSERVER_IMAGE_NAME}:${__GITSERVER_IMAGE_VERSION} does not exist"

[[ ${__IMAGE_EXISTS} -eq ${__NO} ]] && __REBUILD_IMAGE=${__YES}

if [[ ${__REBUILD_IMAGE} -eq ${__YES} ]]; then
  fn__BuildImage  \
    ${__REBUILD_IMAGE} \
    ${__GITSERVER_IMAGE_NAME} \
    ${__GITSERVER_IMAGE_VERSION} \
    ${__DEBMIN_HOME_DOS}/Dockerfile.${__GITSERVER_IMAGE_NAME} \
    ${__DEVCICD_NET} ## && STS=${__SUCCESS} || STS=${__FAILED} # let it abort if failed
  echo "______ Image ${__GITSERVER_IMAGE_NAME}:${__GITSERVER_IMAGE_VERSION} (re-)built"
fi

set -xv
fn__ContainerExists \
  "${__GITSERVER_CONTAINER_NAME}" \
    && STS=${__YES} \
    || STS=${__NO}
if [[ $STS -eq ${__YES} ]]; then
  echo "______ Container ${__GITSERVER_CONTAINER_NAME} exists - will stopp and remove"
  fn__StopAndRemoveContainer  ${__GITSERVER_CONTAINER_NAME} && STS=${__YES} || STS=${__NO}
  echo "______ Container ${__GITSERVER_CONTAINER_NAME} stopped and removed"
else
  echo "______ Container ${__GITSERVER_CONTAINER_NAME} does not exist"
fi
set +xv

fn__RunContainerDetached \
  "${__GITSERVER_IMAGE_NAME}" \
  "${__GITSERVER_IMAGE_VERSION}" \
  "${__GITSERVER_CONTAINER_NAME}" \
  "${__HOST_NAME}" \
  "${__REMOVE_CONTAINER_ON_STOP}" \
  "" \
  "${__DEVCICD_NET}" && STS=${__DONE} || STS=${__FAILED}
echo "______ Container ${__GITSERVER_CONTAINER_NAME} started"

if [[ $STS -eq ${__DONE} ]]; then

  fnUpdateOwnershipOfNonRootUserResources  \
    ${__GITSERVER_CONTAINER_NAME} \
    ${__GIT_USERNAME} \
    ${__GITSERVER_GUEST_HOME}  \
    ${__GITSERVER_SHELL}  \
    ${__GITSERVER_REPOS_ROOT}

  fn__CommitStopTagAndPushImageToRemoteRepository   \
    "${__GITSERVER_CONTAINER_NAME}" \
    "${__DOCKER_REPOSITORY_HOST}"  \
    "${__GITSERVER_IMAGE_NAME}" \
    "${__GITSERVER_IMAGE_VERSION}"
  echo "______ Container committed, stopped and removed. Image tagged and pushed to repository as ${__DOCKER_REPOSITORY_HOST}/${__GITSERVER_IMAGE_NAME}:${__GITSERVER_IMAGE_VERSION}" 

else
  ${__INDUCE_ERROR}
fi

echo "Done..."
