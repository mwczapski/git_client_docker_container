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

echo "______ Sourced common variables and functions"; 



function fn__SetEnvironmentVariables() {

  ## expect directory structure like
  ## /mnt/x/dir1/dir2/..dirN/projectDir/_commonUtils/02_create_node13131_container
  ## and working directory /mnt/x/dir1/dir2/..dirN/projectDir/_commonUtils

  [[ $# -lt  1 || "${0^^}" == "HELP" ]] && {
    echo '
      Usage: 
          fn__SetEnvironmentVariables \
            "${__DEBMIN_HOME}" \
            "${__GITSERVER_USERNAME}" \
            "${__DOCKER_REPOSITORY_HOST}/${__GITSERVER_IMAGE_NAME}:${__GITSERVER_IMAGE_VERSION}"
      '
    return ${__FAILED}
  }

  local pDebminHome=${1?"Directory path from which script is started"}
  local -r pGitserverUsername=${2?"Gitserver non-root username"}
  local -r pDebminSourceImageName=${3?"Full name of the image to use, including remote repository, if any"}

  # set environment
  #
  mkdir -pv ${pDebminHome}
  cd ${pDebminHome}

  pDebminHome=${pDebminHome%%/_commonUtils} # strip _commonUtils
  local -r lDebminHome_DOS=$(fn__WSLPathToRealDosPath ${pDebminHome})

  local lContainerName=${pDebminHome##*/} # strip directory hierarchy before parent of _commonUtils
  lContainerName=${lContainerName//[ _^%@-]/}  # remove special characters, if any, from project name

  # reduce project name to no more than __MaxNameLen__ characters
  local -ri __MaxNameLen__=15
  local -ri nameLen=${#lContainerName}
  local startPos=$((${nameLen}-${__MaxNameLen__})) 
  startPos=${startPos//-*/0} 
  local -r lContainerName=${lContainerName:${startPos}}

  readonly __DEBMIN_SOURCE_IMAGE_NAME="${pDebminSourceImageName}"
  readonly __CONTAINER_NAME="${lContainerName}"
  readonly __HOST_NAME="${lContainerName}"

  readonly __DEBMIN_HOME_WSD=$(fn__WSLPathToWSDPath ${pDebminHome})
  readonly __DEBMIN_HOME_DOS=$(fn__WSLPathToRealDosPath ${pDebminHome})

  readonly __DOCKER_COMPOSE_FILE_WLS="${pDebminHome}/docker-compose.yml_${lContainerName}"
  readonly __DOCKER_COMPOSE_FILE_DOS="${lDebminHome_DOS}\\docker-compose.yml_${lContainerName}"

}


function fn__CreateDockerComposeFile() {
  [[ $# -lt  7 || "${0^^}" == "HELP" ]] && {
    echo '
      Usage: 
          fn__CreateDockerComposeFile \
            "${__CONTAINER_NAME}"  \
            "${__HOST_NAME}"  \
            "${__DEVCICD_NET_DC_INTERNAL}"  \
            "${__DEBMIN_SOURCE_IMAGE_NAME}"  \
            "__GITSERVER_PORT_MAPPINGS"  \
            "${__DEBMIN_HOME_DOS}:${__GITSERVER_GUEST_HOME}" \
            "${__DOCKER_COMPOSE_FILE_WLS}"
      '
    return ${__FAILED}
  }

  local -r pContainerName=${1?"Container Name to be assigned to the container"}
  local -r pHostName=${2?"Host Name to be assigned to the container instance"}
  local -r pNetworkName=${3?"Network Name to be used for this container"}
  local -r pSourceImageNameString=${4?"Full Image String naming the image on which to base the container"}
  local -n pContainerMapperdPortsArray=${5?"The name of the array containing expressions defining the host ports to which map to container ports, if any"}
  local -r pHostBoundVolumeString=${6?"Complete expression defining the host directory to map to container directory"}
  local -r pHostWSLPathToComposeFile=${7?"Host directory to which to write docker-compose.yml file"}

  local -r lContainerMappedPortsArrayLen=${#pContainerMapperdPortsArray[@]}
  local -r lNodeModuleAnonVolume=${pHostBoundVolumeString##*:}

  # create Dockerfile
  local TS=$(date '+%Y%m%d_%H%M%s.%s')
  [[ -e ${pHostWSLPathToComposeFile} ]] &&
    cp ${pHostWSLPathToComposeFile} ${pHostWSLPathToComposeFile}_${TS}
    
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
  for ((i=0; i<${lContainerMappedPortsArrayLen}; i++)) {
    exposePort=${pContainerMapperdPortsArray[${i}]}
    exposePort=${exposePort##*:}
    exposePort=${exposePort%%/*}
    echo "            - \"${exposePort}\""; 
  }
)

        ports:
$( 
  for ((i=0; i<${lContainerMappedPortsArrayLen}; i++)) { 
    echo "            - \"${pContainerMapperdPortsArray[${i}]}\""; 
  }
)

        # networks:
        #     ${pNetworkName}:
        #         aliases:
        #             - ${pHostName}

        hostname: ${pHostName}
        volumes:
            - "/var/run/docker.sock:/var/run/docker.sock"
            - "${pHostBoundVolumeString}"

networks:
    default:
        driver: bridge
        external:
            name: ${pNetworkName}
EOF

  if [[ -e ${pHostWSLPathToComposeFile}_${TS} ]]; then
    diff -s ${pHostWSLPathToComposeFile} ${pHostWSLPathToComposeFile}_${TS} >/dev/null && STS=${__THE_SAME} || STS=${__DIFFERENT}
      if [[ $? -eq ${__DIFFERENT} ]]; then
        echo "______ docker-compose.yml_${pContainerName} changed - container may need updating"
      fi
  fi
  return ${__DONE}
}


function fn__CreateWindowsShortcutsForShellInContainer() {
  [[ $# -lt  3 || "${0^^}" == "HELP" ]] && {
    echo '
      Usage: 
        fn__CreateWindowsShortcutsForShellInContainer \
          "${__CONTAINER_NAME}" \
          "${__DEBMIN_HOME_DOS}" \
          "${__GITSERVER_SHELL}" \
          "${__DOCKER_COMPOSE_FILE_DOS}" && STS=${__DONE} || STS=${__FAILED}
      '
    return ${__FAILED}
  }
 
  local -r pContainerName=${1?"Container Name to be assigned to the container"}
  local -r pHomeDosPath=${2?"Host Path, in DOS format, to write shortcuts to"}
  local -r pShellInContainer=${3?"Shell to use on connection to the container"}
  local -r pDockerComposeFileDos=${4?"Full DOS path to docker-compose.yml_XXX file "}

  local lDockerComposeCommand=""
  local lARGS=""
  local lDockerContainerCommandLine=""

  # create windows shortcuts for shell in container

  lARGS="/c wsl -d Debian -- bash -lc \"docker.exe container exec -itu ${__GIT_USERNAME} --workdir ${__GITSERVER_GUEST_HOME} ${pContainerName} ${pShellInContainer} -l\" || pause"
  fn__CreateWindowsShortcut \
    "${pHomeDosPath}\dcc exec -itu ${__GIT_USERNAME} ${pContainerName}.lnk" \
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
    "C:\Program Files\Docker\Docker\resources\bin\docker.exe" \
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
    "C:\Program Files\Docker\Docker\resources\bin\docker.exe" \
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
    "C:\Program Files\Docker\Docker\resources\bin\docker.exe" \
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
    "C:\Program Files\Docker\Docker\resources\bin\docker.exe" \
    "${lARGS}"


  return ${__DONE}
}

function fnGiveOwnershipToNonRootUser() {
  #
  # fnGiveOwnershipToNonRootUser  \
  #   ${__CONTAINER_NAME} \
  #   ${__GIT_USERNAME} \
  #   ${__GITSERVER_GUEST_HOME}  \
  #   ${__GITSERVER_SHELL}
  #
  pContainerName=${1?"Usage: $0 requires __CONTAINER_NAME, __GIT_USERNAME, __GITSERVER_GUEST_HOME and __GITSERVER_SHELL as its arguments"}
  pGuestHome=${2?"Usage: $0 requires __CONTAINER_NAME, __GIT_USERNAME, __GITSERVER_GUEST_HOME and __GITSERVER_SHELL as its arguments"}
  pGitUsername=${3?"Usage: $0 requires __CONTAINER_NAME, __GIT_USERNAME, __GITSERVER_GUEST_HOME and __GITSERVER_SHELL as its arguments"}
  pContainerShell=${4?"Usage: $0 requires __CONTAINER_NAME, __GITSERVER_GUEST_HOME and __GITSERVER_SHELL as its arguments"}

  echo "______ As root on ${pContainerName}, giving ownership of node_modules directory to node";

  ${__DOCKER_EXE} container exec -itu root -w ${pGuestHome} ${pContainerName} ${pContainerShell} -lc "
  chown -R pGitUsername:pGitUsername ${pGuestHome}
  # chmod -R g+s ${pGuestHome}/dev
  # chmod -R g+s ${pGuestHome}/dev/node_modules
  "
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
readonly __CWD_NAME=$(basename ${__DEBMIN_HOME})
[[ "${__CWD_NAME}" == "_commonUtils" ]] || {
  echo "${0} must run from directory with name _commonUtils and will use the name of its parent directory as project directory"
  exit
}


fn__SetEnvironmentVariables \
  "${__DEBMIN_HOME}" \
  "${__GITSERVER_USERNAME}" \
  "${__DOCKER_REPOSITORY_HOST}/${__GITSERVER_IMAGE_NAME}:${__GITSERVER_IMAGE_VERSION}" \
    ## && STS=${__SUCCESS} || STS=${__FAILED} # let it fail 
echo "______ Set local environment variables"; 

fn__ConfirmYN "Artefact location will be ${__DEBMIN_HOME} - Is this correct?" && true || {
  echo -e "_______ Aborting ...\n"
  exit
}

# note that we are passing the name of the array of port mappings - the function deals with access to the array
#
fn__CreateDockerComposeFile \
  "${__CONTAINER_NAME}"  \
  "${__HOST_NAME}"  \
  "${__DEVCICD_NET}"  \
  "${__DEBMIN_SOURCE_IMAGE_NAME}"  \
  "__GITSERVER_PORT_MAPPINGS"  \
  "${__DEBMIN_HOME_WSD}/backups:${__GITSERVER_HOST_BACKUP_DIR}" \
  "${__DOCKER_COMPOSE_FILE_WLS}"
echo "______ Created ${__DOCKER_COMPOSE_FILE_WLS}"; 

fn__CreateWindowsShortcutsForShellInContainer \
  "${__CONTAINER_NAME}" \
  "${__DEBMIN_HOME_DOS}" \
  "${__GITSERVER_SHELL}" \
  "${__DOCKER_COMPOSE_FILE_DOS}" && STS=${__DONE} || STS=${__FAILED}
echo "______ Created Windows Shortcuts"; 


exit


fn__ImageExists 
  "${__DEBMIN_SOURCE_IMAGE_NAME}" # let it fail if image does not exist


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

# fnGiveOwnershipToNonRootUser  \
#   ${__CONTAINER_NAME} \
#   ${__GIT_USERNAME} \
#   ${__GITSERVER_GUEST_HOME}  \
#   ${__GITSERVER_SHELL}

echo "______ ${0} Done"
