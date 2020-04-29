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

source ./utils/fn__CreateWindowsShortcut.sh


function fn__SetEnvironmentVariables() {

  # set environment
  #
  mkdir -pv ${__DEBMIN_HOME}
  cd ${__DEBMIN_HOME}

  __DEBMIN_HOME=${__DEBMIN_HOME%%/_commonUtils} # strip _commonUtils
  __DEBMIN_HOME_DOS=$(fn__WSLPathToRealDosPath ${__DEBMIN_HOME})
  __DEBMIN_HOME_WSD=$(fn__WSLPathToWSDPath ${__DEBMIN_HOME})


#  __DEBMIN_GNAME=${__GIT_USERNAME}
 
  __DEBMIN_SOURCE_IMAGE_NAME="bitnami/minideb:jessie"

  __TZ_PATH=Australia/Sydney
  __TZ_NAME=Australia/Sydney
  __ENV="/etc/profile"

  # __DEVCICD_NET_DC_INTERNAL=devcicd_net
  # __DEVCICD_NET=docker_${__DEVCICD_NET_DC_INTERNAL}

  # __CONTAINER_NAME="nodejs_baseline"
  # __HOST_NAME="nodejsbase"

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
      "<${__GITSERVER_SHELL}>"
'
    return ${__FAILED}
  }
 
  local pGuestShell=${1?"Full path to guest's shell binary, for example /bin/bash or /bin/ash or /bin/sh"}

  cat <<-EOF > ${__DEBMIN_HOME}/docker-entrypoint.sh
#!/bin/bash
set -e

# prevent container from exiting after successfull startup
# exec /bin/bash -c 'while true; do sleep 100000; done'
# exec ${pGuestShell} $@
exec $@
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
FROM bitnami/minideb:jessie

## Dockerfile Version: ${TS}
##
# the environment variables below will be used in creating the image
# and will be available to the containers created from the image
#
ENV DEBMIN_USERNAME=${__GIT_USERNAME} \\
#    DEBMIN_GNAME=${__DEBMIN_GNAME} \\
    DEBMIN_SHELL=${__GITSERVER_SHELL} \\
    DEBMIN_SHELL_PROFILE=${__GITSERVER_SHELL_PROFILE} \\
    TZ_PATH=${__TZ_PATH} \\
    TZ_NAME=${__TZ_NAME}  \\
    ENV=${__ENV}  \\
    DEBIAN_FRONTEND=noninteractive

COPY ./docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

# install necessary / usefull extra packages
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
      nano && \\
# needed to download, unzip and install latest git from sources
      wget \\
      unzip \\
      build-essential \\
      libssl-dev \\
      libcurl4-openssl-dev \\
      libexpat1-dev \\
      gettext \\
\\
# set timezone - I live in Sydney - change as you see fit in the env variables above
    cp -v /usr/share/zoneinfo/\${TZ_PATH} /etc/localtime && \\
    echo "\${TZ_NAME}" > /etc/timezone && \\
    echo $(date) && \\
\\
# create git user
    addgroup developers && \\
    useradd -G developers -m \${DEBMIN_USERNAME} -s \${DEBMIN_SHELL} -p \${DEBMIN_USERNAME} && \\
\\
## configure git and ssh access to git repositories on this git server
    sed -i 's|#PasswordAuthentication yes|PasswordAuthentication no|' /etc/ssh/sshd_config && \\
\\
# create user's working directory
    touch /home/\${DEBMIN_USERNAME}/.ssh/authorized_keys && \\
    chmod 600 /home/\${DEBMIN_USERNAME}/.ssh/authorized_keys && \\
    mkdir -pv /opt/gitrepos && \\
    chown -Rv \${DEBMIN_USERNAME}:developers /opt/gitrepos && \\
    chmod -v g+rxs /opt/gitrepos && \\
    echo /usr/bin/git-shell >> /etc/shells && \\
    chsh git -s /usr/bin/git-shell  && \\ 
\\
# download and install latest git
    mkdir -pv ~/Downloads   && \\
    cd ~/Downloads  && \\
    wget https://github.com/git/git/archive/master.zip -O ./git_master_$(date +%Y%m%d).zip  && \\
    unzip git_master_20200428.zip   && \\
    make prefix=/usr all  && \\
    make prefix=/usr install  && \\
    git --version
EOF

  if [[ -e ${__DOCKERFILE_PATH}_${TS} ]]; then

    diff -s ${__DOCKERFILE_PATH} ${__DOCKERFILE_PATH}_${TS} >/dev/null && STS=${__THE_SAME} || STS=${__DIFFERENT}
  
    if [[ ${STS} -eq ${__DIFFERENT} ]]; then
      __NEEDS_REBUILDING=${__YES}
    fi
  fi
  return ${__NEEDS_REBUILDING}

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

echo "__REBUILD_IMAGE: ${__REBUILD_IMAGE}"
exit


fn__ImageExists "${__GITSERVER_IMAGE_NAME}:${__GITSERVER_IMAGE_VERSION}" __IMAGE_EXISTS=${__YES} || __IMAGE_EXISTS=${__NO}
if [[ ${__IMAGE_EXISTS} -eq ${__NO} || ${__REBUILD_IMAGE} -eq ${__YES} ]]; then
  fn__BuildImage  \
    "${__REBUILD_IMAGE}" \
    "${__GITSERVER_IMAGE_NAME}" \
    "${__GITSERVER_IMAGE_VERSION}" \
    "${__DEBMIN_HOME_DOS}/Dockerfile.${__GITSERVER_IMAGE_NAME}" \
    "${__DEVCICD_NET}" ## && STS=${__SUCCESS} || STS=${__FAILED} # let it abort if failed
  echo "______ Image ${__GITSERVER_IMAGE_NAME}:${__GITSERVER_IMAGE_VERSION} (re-)built"
fi


fn__ContainerExists ${__CONTAINER_NAME} && STS=${__YES} || STS=${__NO}
if [[ $STS -eq ${__YES} ]]; then
  fn__StopAndRemoveContainer  ${__CONTAINER_NAME} ## && STS=${__YES} || STS=${__NO} # let it abort if failed
  echo "______ Container ${__CONTAINER_NAME} stopped and removed"
fi


fn__RunContainerDetached \
  "${__GITSERVER_IMAGE_NAME}" \
  "${__GITSERVER_IMAGE_VERSION}" \
  "${__CONTAINER_NAME}" \
  "${__HOST_NAME}" \
  "${__REMOVE_CONTAINER_ON_STOP}" \
  "" \
  "${__DEVCICD_NET}" && STS=${__DONE} || STS=${__FAILED}
echo "______ Container ${__CONTAINER_NAME} started"

if [[ $STS -eq ${__DONE} ]]; then

  fn__CommitStopTagAndPushImageToRemoteRepository   \
    "${__CONTAINER_NAME}" \
    "${__DOCKER_REPOSITORY_HOST}"  \
    "${__GITSERVER_IMAGE_NAME}" \
    "${__GITSERVER_IMAGE_VERSION}"
  echo "______ Image committed, stopped, tagged and pushed to repository as ${__DOCKER_REPOSITORY_HOST}/${__GITSERVER_IMAGE_NAME}:${__GITSERVER_IMAGE_VERSION}" 


else
  ${__INDUCE_ERROR}
fi

echo "Done..."
