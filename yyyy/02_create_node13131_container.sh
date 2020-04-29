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
  cd ${__DEBMIN_HOME}

  __DEBMIN_HOME=${__DEBMIN_HOME%%/_commonUtils} # strip _commonUtils
  __DEBMIN_HOME_DOS=$(fn__WSLPathToRealDosPath ${__DEBMIN_HOME})
  __DEBMIN_HOME_WSD=$(fn__WSLPathToWSDPath ${__DEBMIN_HOME})

  __DEBMIN_PPROJECT_NAME=${__DEBMIN_HOME##*/} # strip directory hierarchy before parent of _commonUtils
  __DEBMIN_PPROJECT_NAME=${__DEBMIN_PPROJECT_NAME//[ _^%@]/}  # remove special characters, if any, from project name

  __DEBMIN_USERNAME=node
  __DEBMIN_GUEST_HOME=/home/${__DEBMIN_USERNAME}

  __DEBMIN_SHELL="/bin/bash"

  __DOCKER_REPOSITORY_HOST="mcz11.czapski.id.au"
  __DEBMIN_SOURCE_IMAGE_NAME="${__DOCKER_REPOSITORY_HOST}/nodejs_baseline:1.0.0"

  __DEBMIN_NET_DC_INTERNAL=devcicd_net

  # __CONTAINER_NAME="nodejs13130"
  # __HOST_NAME="nodejs13130"
  __CONTAINER_NAME="${__DEBMIN_PPROJECT_NAME}"
  __HOST_NAME="${__DEBMIN_PPROJECT_NAME}"

  # __MAPPED_HOST_PORT_1=3101
  # __MAPPED_GUEST_PORT_1=3100
  # __CONTAINER_MAPPED_PORTS="127.0.0.1:${__MAPPED_HOST_PORT_1}:${__MAPPED_GUEST_PORT_1}/tcp"

  __PORT_MAPPINGS[0]=127.0.0.1:3101:3100/tcp
  __PORT_MAPPINGS[1]=127.0.0.1:5001:5000/tcp
  __PORT_MAPPINGS[2]=127.0.0.1:48080:8080/tcp

  __DOCKER_COMPOSE_FILE_WLS="${__DEBMIN_HOME}/docker-compose.yml_${__CONTAINER_NAME}"
  __DOCKER_COMPOSE_FILE_DOS="${__DEBMIN_HOME_DOS}\\docker-compose.yml_${__CONTAINER_NAME}"

}


function fn__CreateDockerComposeFile() {
  [[ $# -lt  7 || "${0^^}" == "HELP" ]] && {
    echo '
Usage: 
    fn__CreateDockerComposeFile \
      "${__CONTAINER_NAME}"  \
      "${__HOST_NAME}"  \
      "${__DEBMIN_NET_DC_INTERNAL}"  \
      "${__DEBMIN_SOURCE_IMAGE_NAME}"  \
      "__PORT_MAPPINGS"  \
      "${__DEBMIN_HOME_DOS}:${__DEBMIN_GUEST_HOME}" \
      "${__DOCKER_COMPOSE_FILE_WLS}"
'
    return ${__FAILED}
  }

  local pContainerName=${1?"Container Name to be assigned to the container"}
  local pHostName=${2?"Host Name to be assigned to the container instance"}
  local pNetworkName=${3?"Network Name to be used for this container"}
  local pSourceImageNameString=${4?"Full Image String naming the image on which to base the container"}
  local -n pContainerMapperdPortsArray=${5?"The name of the array containing expressions defining the host ports to which map to container ports, if any"}
  local pHostBoundVolumeString=${6?"Complete expression defining the host directory to map to container directory"}
  local pHostWSLPathToComposeFile=${7?"Host directory to which to write docker-compose.yml file"}
  local pContainerMapperdPortsArrayLen=${#pContainerMapperdPortsArray[@]}

  local lNodeModuleAnonVolume=${pHostBoundVolumeString##*:}

  # create Dockerfile
  local TS=$(date '+%Y%m%d_%H%M%s.%s')
  [[ -e ${pHostWSLPathToComposeFile} ]] &&
    cp -v \
      ${pHostWSLPathToComposeFile} \
      ${pHostWSLPathToComposeFile}_${TS}
    
  cat <<-EOF > ${pHostWSLPathToComposeFile} 
version: "3.7"

services:
    ${pContainerName}:
        container_name: ${pContainerName}
        image: ${pSourceImageNameString}

        restart: always

        entrypoint: /usr/local/bin/docker-entrypoint.sh

        tty: true         # these two keep the container running even if there is no listener in the foreground
        stdin_open: true

        expose:
$(
  for ((i=0; i<${pContainerMapperdPortsArrayLen}; i++)) {
    exposePort=${pContainerMapperdPortsArray[${i}]}
    exposePort=${exposePort##*:}
    exposePort=${exposePort%%/*}
    echo "            - \"${exposePort}\""; 
  }
)

        ports:
$( 
  for ((i=0; i<${pContainerMapperdPortsArrayLen}; i++)) { 
    echo "            - \"${pContainerMapperdPortsArray[${i}]}\""; 
  }
)

        networks:
            ${pNetworkName}:
                aliases:
                    - ${pHostName}

        hostname: ${pHostName}
        volumes:
            - "/var/run/docker.sock:/var/run/docker.sock"
            - "${pHostBoundVolumeString}"
            - "${lNodeModuleAnonVolume}/node_modules"

#        command: /bin/bash -c 'while true; do sleep 100000; done'
#        command: /usr/bin/node
networks:
    ${pNetworkName}:
        driver: bridge
EOF

  if [[ -e ${pHostWSLPathToComposeFile}_${TS} ]]; then
    diff -s ${pHostWSLPathToComposeFile} ${pHostWSLPathToComposeFile}_${TS} >/dev/null && STS=${__THE_SAME} || STS=${__DIFFERENT}
      if [[ $? -eq ${__DIFFERENT} ]]; then
        echo "______ docker-compose.yml_${pContainerName} changed - container may need updating"
      fi
  fi
  return ${__DONE}
}


fn__CreateWindowsShortcutsForShellInContainer() {
  [[ $# -lt  3 || "${0^^}" == "HELP" ]] && {
    echo '
Usage: 
  fn__CreateWindowsShortcutsForShellInContainer \
    "${__CONTAINER_NAME}" \
    "${__DEBMIN_HOME_DOS}" \
    "${__DEBMIN_SHELL}" \
    "${__DOCKER_COMPOSE_FILE_DOS}" && STS=${__DONE} || STS=${__FAILED}
'
    return ${__FAILED}
  }
 
  local pContainerName=${1?"Container Name to be assigned to the container"}
  local pHomeDosPath=${2?"Host Path, in DOS format, to write shortcuts to"}
  local pShellInContainer=${3?"Shell to use on connection to the container"}
  local pDockerComposeFileDos=${4?"Full DOS path to docker-compose.yml_XXX file "}

  local lDockerComposeCommand=""
  local lARGS=""
  local lDockerContainerCommandLine=""

  # create windows shortcuts for shell in container

  lARGS="/c wsl -d Debian -- bash -lc \"docker.exe container exec -itu node --workdir /home/node ${pContainerName} ${pShellInContainer} -l\" || pause"
  fn__CreateWindowsShortcut \
    "${pHomeDosPath}\dcc exec -itu node ${pContainerName}.lnk" \
    "C:\Windows\System32\cmd.exe" \
    "%~dp0" \
    "${fn__CreateWindowsShortcut__RUN_NORMAL_WINDOW}" \
    "C:\Windows\System32\wsl.exe" \
    "${lARGS}"

  lARGS="/c wsl -d Debian -- bash -lc \"docker.exe container exec -itu root --workdir / ${pContainerName} ${pShellInContainer} -l\" || pause"
  fn__CreateWindowsShortcut \
    "${pHomeDosPath}\dcc exec -itu root ${pContainerName}.lnk" \
    "C:\Windows\System32\cmd.exe" \
    "%~dp0" \
    "${fn__CreateWindowsShortcut__RUN_NORMAL_WINDOW}" \
    "C:\Windows\System32\wsl.exe" \
    "${lARGS}"



  lDockerComposeCommand="up --detach"
  lDockerContainerCommandLine=$(fn_GetDockerComposeDOSCommandLine \
    "${pDockerComposeFileDos}" \
    "${pContainerName}" \
    "${lDockerComposeCommand}"
    )
  lARGS="/c ${lDockerContainerCommandLine} || pause"

  fn__CreateWindowsShortcut \
    "${pHomeDosPath}\\dco ${pContainerName} ${lDockerComposeCommand}.lnk" \
    "C:\Windows\System32\cmd.exe" \
    "%~dp0" \
    "${fn__CreateWindowsShortcut__RUN_NORMAL_WINDOW}" \
    "C:\Windows\System32\wsl.exe" \
    "${lARGS}"


  lDockerComposeCommand="stop"
  lDockerContainerCommandLine=$(fn_GetDockerComposeDOSCommandLine \
    "${pDockerComposeFileDos}" \
    "${pContainerName}" \
    "${lDockerComposeCommand}"
    )
  lARGS="/c ${lDockerContainerCommandLine} || pause"

  fn__CreateWindowsShortcut \
    "${pHomeDosPath}\\dco ${pContainerName} ${lDockerComposeCommand}.lnk" \
    "C:\Windows\System32\cmd.exe" \
    "%~dp0" \
    "${fn__CreateWindowsShortcut__RUN_NORMAL_WINDOW}" \
    "C:\Windows\System32\wsl.exe" \
    "${lARGS}"


  lDockerComposeCommand="ps"
  lDockerContainerCommandLine=$(fn_GetDockerComposeDOSCommandLine \
    "${pDockerComposeFileDos}" \
    "${pContainerName}" \
    "${lDockerComposeCommand}"
    )
  lARGS="/c ${lDockerContainerCommandLine} && pause"

  fn__CreateWindowsShortcut \
    "${pHomeDosPath}\\dco ${pContainerName} ${lDockerComposeCommand}.lnk" \
    "C:\Windows\System32\cmd.exe" \
    "%~dp0" \
    "${fn__CreateWindowsShortcut__RUN_NORMAL_WINDOW}" \
    "C:\Windows\System32\wsl.exe" \
    "${lARGS}"


  lDockerComposeCommand="rm -s -v"
  lDockerContainerCommandLine=$(fn_GetDockerComposeDOSCommandLine \
    "${pDockerComposeFileDos}" \
    "${pContainerName}" \
    "${lDockerComposeCommand}"
    )
  lARGS="/c ${lDockerContainerCommandLine} || pause"

  fn__CreateWindowsShortcut \
    "${pHomeDosPath}\\dco ${pContainerName} ${lDockerComposeCommand}.lnk" \
    "C:\Windows\System32\cmd.exe" \
    "%~dp0" \
    "${fn__CreateWindowsShortcut__RUN_NORMAL_WINDOW}" \
    "C:\Windows\System32\wsl.exe" \
    "${lARGS}"


  return ${__DONE}
}

## ##################################################################################
## ##################################################################################
## expect directory structure like
## /mnt/x/dir1/dir2/..dirN/projectDir/_commonUtils/02_create_node13131_container
## and working directory /mnt/x/dir1/dir2/..dirN/projectDir/_commonUtils
## ##################################################################################
## ##################################################################################

# confirm project directory
# /mnt/x/dir1/dir2/..dirn/projectDir/_commonUtils/02_create_node13131_container
#
__DEBMIN_HOME=$(pwd)
__CWD_NAME=$(basename ${__DEBMIN_HOME})
[[ "${__CWD_NAME}" == "_commonUtils" ]] || {
  echo "${0} must run from directory with name _commonUtils and will use the name of its parent directory as project directory"
  exit
}

fn__ConfirmYN "Artefact location will be ${__DEBMIN_HOME} - Is this correct?" && true || {
  echo -e "_______ Aborting ...\n"
  exit
}

fn__SetEnvironmentVariables ## && STS=${__SUCCESS} || STS=${__FAILED} # let it fail 

fn__ImageExists "${__DEBMIN_SOURCE_IMAGE_NAME}" # let it fail if image does not exist

# note that we are passing the name of the array of port mappings - the function deals with access to the array
#
fn__CreateDockerComposeFile \
  "${__CONTAINER_NAME}"  \
  "${__HOST_NAME}"  \
  "${__DEBMIN_NET_DC_INTERNAL}"  \
  "${__DEBMIN_SOURCE_IMAGE_NAME}"  \
  "__PORT_MAPPINGS"  \
  "${__DEBMIN_HOME_WSD}/dev:${__DEBMIN_GUEST_HOME}/dev" \
  "${__DOCKER_COMPOSE_FILE_WLS}"


fn__ContainerExists ${__CONTAINER_NAME} && STS=${__YES} || STS=${__NO}
if [[ $STS -eq ${__YES} ]]; then

  fn__ContainerIsRunning ${__CONTAINER_NAME} && STS=${__YES} || STS=${__NO}
  if [[ $STS -eq ${__YES} ]]; then

    echo "______ Container ${__CONTAINER_NAME} Exist and is running ... - nothing needs doing"; 
    exit

  else
    fn__StartContainer ${__CONTAINER_NAME} && STS=${__YES} || STS=${__NO}
    if [[ $STS -eq ${__DONE} ]]; then
        echo "______ Container ${__CONTAINER_NAME} started"; 
    else
        echo "______ Failed to start container ${__CONTAINER_NAME} - investigate..."; 
        exit
    fi
  fi

else
  
  fn_DockerComposeUpDetached "${__DOCKER_COMPOSE_FILE_DOS}" "${__CONTAINER_NAME}" && STS=${__DONE} || STS=${__FAILED}
  if [[ $STS -eq ${__DONE} ]]; then
    echo "______ Container ${__CONTAINER_NAME} started"; 
  else
    echo "______ Failed to start container ${__CONTAINER_NAME} - investigate"; 
    exit
  fi
fi

fn__CreateWindowsShortcutsForShellInContainer \
  "${__CONTAINER_NAME}" \
  "${__DEBMIN_HOME_DOS}" \
  "${__DEBMIN_SHELL}" \
  "${__DOCKER_COMPOSE_FILE_DOS}" && STS=${__DONE} || STS=${__FAILED}


echo "______ ${0} Done"
