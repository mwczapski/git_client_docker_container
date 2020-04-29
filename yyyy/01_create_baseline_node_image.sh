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

source ./utils/const__YesNoSuccessFailureContants.sh

source ./utils/fn__WSLPathToDosPath.sh
source ./utils/fn__ConfirmYN.sh
source ./utils/fn__DockerGeneric.sh

source ./utils/fn__CreateWindowsShortcut.sh



function fn__SetEnvironmentVariables() {

  # set environment
  #
  mkdir -pv ${__DEBMIN_HOME}

  __DEBMIN_HOME_DOS=$(fn__WSLPathToDosPath ${__DEBMIN_HOME})

  cd ${__DEBMIN_HOME}

  __DEBMIN_USERNAME=node
  __DEBMIN_UID=1001
  __DEBMIN_GID=1001
  __DEBMIN_GNAME=${__DEBMIN_USERNAME}
  __DEBMIN_GUEST_HOME=/home/${__DEBMIN_USERNAME}

  __DEBMIN_SHELL=/bin/bash
  __DEBMIN_SHELL_PROFILE=.bash_profile

  __DEBMIN_SOURCE_IMAGE_NAME="bitnami/minideb:jessie"
  __DEBMIN_IMAGE_NAME="nodejs_baseline"
  __DEBMIN_IMAGE_VERSION=1.0.0

  __TZ_PATH=Australia/Sydney
  __TZ_NAME=Australia/Sydney
  __ENV="/etc/profile"

  __DEBMIN_NET_DC_INTERNAL=devcicd_net
  __DEBMIN_NET=docker_${__DEBMIN_NET_DC_INTERNAL}

  __CONTAINER_NAME="nodejs_baseline"
  __HOST_NAME="nodejsbase"

  __DOCKERFILE_PATH=${__DEBMIN_HOME}/Dockerfile.${__DEBMIN_IMAGE_NAME}

  # __MAPPED_HOST_PORT_1=3101
  # __MAPPED_GUEST_PORT_1=3100
  # __CONTAINER_MAPPED_PORTS=" -p 127.0.0.1:${__MAPPED_HOST_PORT_1}:${__MAPPED_GUEST_PORT_1}/tcp "

  __DOCKER_REPOSITORY_HOST=mcz11.czapski.id.au

  ## toggles 
  __REMOVE_CONTAINER_ON_STOP=${__YES} # container started using this image is nto supposed to be used for work
  __NEEDS_REBUILDING=${__NO}  # set to ${__YES} if image does not exist of Dockerfile changed

}

function fn__Create_docker_entry_point_file() {

  [[ $# -lt  1 || "${0^^}" == "HELP" ]] && {
    echo '
Usage: 
    fn__Create_docker_entry_point_file \
      "<${__DEBMIN_SHELL}>"
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

  local TS=$(date '+%Y%m%d_%H%M%s.%s')
  [[ -e ${__DOCKERFILE_PATH} ]] && cp -v ${__DOCKERFILE_PATH} ${__DOCKERFILE_PATH}_${TS}
    
  cat <<-EOF > ${__DOCKERFILE_PATH}
FROM ${__DEBMIN_SOURCE_IMAGE_NAME}

## Dockerfile Version: ${TS}
##
# the environment variables below will be used in creating the image
# and will be available to the containers created from the image
#
ENV DEBMIN_USERNAME=${__DEBMIN_USERNAME} \\
DEBMIN_PASSWD=${__DEBMIN_USERNAME} \\
DEBMIN_UID=${__DEBMIN_UID} \\
DEBMIN_GID=${__DEBMIN_GID} \\
DEBMIN_GNAME=${__DEBMIN_GNAME} \\
DEBMIN_SHELL=${__DEBMIN_SHELL} \\
DEBMIN_SHELL_PROFILE=${__DEBMIN_SHELL_PROFILE} \\
DEBMIN_GUEST_HOME=${__DEBMIN_GUEST_HOME} \\
TZ_PATH="${__TZ_PATH}" \\
TZ_NAME="${__TZ_NAME}" \\
ENV=${__ENV} \\
DEBIAN_FRONTEND=noninteractive

COPY ./docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

# install extra packages
RUN apt-get update -q && \\
    apt-get upgrade -y && \\
    apt-get -y install \\
      apt-utils \\
      software-properties-common \\
      tzdata \\
      net-tools \\
      iputils-ping \\
      curl \\
      openssh-client \\
      git \\
      nano && \\
\\
# set timezone - I live in Sydney - change as you see fit in the env variables above
    cp -v /usr/share/zoneinfo/\${TZ_PATH} /etc/localtime && \\
    echo "\${TZ_NAME}" > /etc/timezone && \\
    echo \$(date) && \\
\\
# install latest nodejs for debian
# https://tecadmin.net/install-latest-nodejs-npm-on-debian/
# curl -sL https://deb.nodesource.com/setup_13.x | sudo bash -
\\
    curl -sL https://deb.nodesource.com/setup_13.x -o /root/debian_nodejs_setup_13.x && \\
    chmod u+x /root/debian_nodejs_setup_13.x && \\
    /root/debian_nodejs_setup_13.x && \\
    apt-get install -y nodejs && \\
    npm --version && \\
    node --version && \\
\\
# install global development packages
# npm install --global lite-server && \\
    npm install --global nodemon && \\
    npm install --global serve && \\
    npm install --global json && \\
    npm install --global eslint@^6.0.0 && \\
    npm install --global prettier && \\
    npm install --global eslint-plugin-prettier && \\
    npm install --global eslint-config-prettier && \\
    npm install --global eslint-plugin-node && \\
    npm install --global eslint-config-node && \\
\\
# create non-root user 
    addgroup --gid \${DEBMIN_GID} \${DEBMIN_GNAME} && \\
    useradd -c '\${DEBMIN_USER} non-root user' -u \${DEBMIN_UID} --gid \${DEBMIN_GID} -m -s \${DEBMIN_SHELL} -d \${DEBMIN_GUEST_HOME} \${DEBMIN_USERNAME} && \\
\\
    echo \${DEBMIN_PASSWD} >pw && \\
    echo \${DEBMIN_PASSWD} >>pw && \\
    cat pw | passwd \${DEBMIN_USERNAME} && \\
    rm -v pw && \\
\\
# configure ssh client artefacts
    mkdir -pv \${DEBMIN_GUEST_HOME}/.ssh && \\
    chown -Rv \${DEBMIN_UID}:\${DEBMIN_GID} \${DEBMIN_GUEST_HOME}/.ssh && \\
    su - \${DEBMIN_USERNAME} -s /bin/bash -c "ssh-keygen -f \${DEBMIN_GUEST_HOME}/.ssh/id_rsa -t rsa -b 2048 -q -N \"\"" && \\
    cat \${DEBMIN_GUEST_HOME}/.ssh/id_rsa.pub

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


fn__Create_docker_entry_point_file ${__DEBMIN_SHELL} ## && STS=${__SUCCESS} || STS=${__FAILED} # let it fail 
echo "______ Created docker-entrypoint.sh" 


fn__CreateDockerfile && __REBUILD_IMAGE=${__YES} || __REBUILD_IMAGE=${__NO} # if dockerfile has not changed
echo "______ Created Dockerfile.${__DOCKERFILE_PATH}" 


fn__ImageExists "${__DEBMIN_IMAGE_NAME}:${__DEBMIN_IMAGE_VERSION}" __IMAGE_EXISTS=${__YES} || __IMAGE_EXISTS=${__NO}
if [[ ${__IMAGE_EXISTS} -eq ${__NO} || ${__REBUILD_IMAGE} -eq ${__YES} ]]; then
  fn__BuildImage  \
    "${__REBUILD_IMAGE}" \
    "${__DEBMIN_IMAGE_NAME}" \
    "${__DEBMIN_IMAGE_VERSION}" \
    "${__DEBMIN_HOME_DOS}/Dockerfile.${__DEBMIN_IMAGE_NAME}" \
    "${__DEBMIN_NET}" ## && STS=${__SUCCESS} || STS=${__FAILED} # let it abort if failed
  echo "______ Image ${__DEBMIN_IMAGE_NAME}:${__DEBMIN_IMAGE_VERSION} (re-)built"
fi


fn__ContainerExists ${__CONTAINER_NAME} && STS=${__YES} || STS=${__NO}
if [[ $STS -eq ${__YES} ]]; then
  fn__StopAndRemoveContainer  ${__CONTAINER_NAME} ## && STS=${__YES} || STS=${__NO} # let it abort if failed
  echo "______ Container ${__CONTAINER_NAME} stopped and removed"
fi


fn__RunContainerDetached \
  "${__DEBMIN_IMAGE_NAME}" \
  "${__DEBMIN_IMAGE_VERSION}" \
  "${__CONTAINER_NAME}" \
  "${__HOST_NAME}" \
  "${__REMOVE_CONTAINER_ON_STOP}" \
  "" \
  "${__DEBMIN_NET}" && STS=${__DONE} || STS=${__FAILED}
echo "______ Container ${__CONTAINER_NAME} started"

if [[ $STS -eq ${__DONE} ]]; then

  fn__CommitStopTagAndPushImageToRemoteRepository   \
    "${__CONTAINER_NAME}" \
    "${__DOCKER_REPOSITORY_HOST}"  \
    "${__DEBMIN_IMAGE_NAME}" \
    "${__DEBMIN_IMAGE_VERSION}"
  echo "______ Image committed, stopped, tagged and pushed to repository as ${__DOCKER_REPOSITORY_HOST}/${__DEBMIN_IMAGE_NAME}:${__DEBMIN_IMAGE_VERSION}" 

  # fn__ContainerExists ${__CONTAINER_NAME} && STS=${__YES} || STS=${__NO}
  # if [[ $STS -eq ${__YES} ]]; then
  #   fn__StopAndRemoveContainer  ${__CONTAINER_NAME} ## && STS=${__YES} || STS=${__NO} # let it abort if failed
  #   echo "______ Container ${__CONTAINER_NAME} stopped and removed" 
  # fi

  # # create windows shortcuts for shell in container

  # __ARGS="/c wsl -d Debian -- bash -lc \"docker.exe container exec -itu node --workdir /home/node ${__CONTAINER_NAME} bash -l\" || pause"
  # fn__CreateWindowsShortcut \
  #   "${__DEBMIN_HOME_DOS}\run shell as node in container.lnk" \
  #   "C:\Windows\System32\cmd.exe" \
  #   "%~dp0" \
  #   "${fn__CreateWindowsShortcut__RUN_NORMAL_WINDOW}" \
  #   "C:\Windows\System32\wsl.exe" \
  #   "${__ARGS}"

  # __ARGS="/c wsl -d Debian -- bash -lc \"docker.exe container exec -itu root --workdir /home/node ${__CONTAINER_NAME} bash -l\" || pause"
  # fn__CreateWindowsShortcut \
  #   "${__DEBMIN_HOME_DOS}\run shell as root in container.lnk" \
  #   "C:\Windows\System32\cmd.exe" \
  #   "%~dp0" \
  #   "${fn__CreateWindowsShortcut__RUN_NORMAL_WINDOW}" \
  #   "C:\Windows\System32\wsl.exe" \
  #   "${__ARGS}"

else
  ${__INDUCE_ERROR}
fi

echo "Done..."
