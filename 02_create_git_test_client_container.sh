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
            "${__GIT_TEST_CLIENT_USERNAME}" \
            "${__GIT_TEST_CLIENT_IMAGE_NAME}:${__GIT_TEST_CLIENT_IMAGE_VERSION}"
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

  local lContainerName=${__GIT_TEST_CLIENT_CONTAINER_NAME}
  # local lContainerName=${pDebminHome##*/} # strip directory hierarchy before parent of _commonUtils
  # lContainerName=${lContainerName//[ _^%@-]/}  # remove special characters, if any, from project name

  # reduce project name to no more than __MaxNameLen__ characters
  local -ri __MaxNameLen__=15
  local -ri nameLen=${#lContainerName}
  local startPos=$((${nameLen}-${__MaxNameLen__})) 
  startPos=${startPos//-*/0} 
  local -r lContainerName=${lContainerName:${startPos}}

  readonly __DEBMIN_SOURCE_IMAGE_NAME="${pDebminSourceImageName}"

  __DEBMIN_HOME=${pDebminHome}
  readonly __DEBMIN_HOME_WSD=$(fn__WSLPathToWSDPath ${pDebminHome})
  readonly __DEBMIN_HOME_DOS=$(fn__WSLPathToRealDosPath ${pDebminHome})

  readonly __DOCKER_COMPOSE_FILE_WLS="${pDebminHome}/docker-compose.yml_${lContainerName}"
  readonly __DOCKER_COMPOSE_FILE_DOS="${lDebminHome_DOS}\\docker-compose.yml_${lContainerName}"

}


function fn__CreateDockerComposeFile() {
  [[ $# -lt  6 || "${0^^}" == "HELP" ]] && {
    echo '
      Usage: 
          fn__CreateDockerComposeFile \
            "${__GIT_TEST_CLIENT_CONTAINER_NAME}"  \
            "${__GIT_TEST_CLIENT_HOST_NAME}"  \
            "${__DEVCICD_NET_DC_INTERNAL}"  \
            "${__DEBMIN_SOURCE_IMAGE_NAME}"  \
            "${__DEBMIN_HOME_DOS}:${__GIT_TEST_CLIENT_GUEST_HOME}" \
            "${__DOCKER_COMPOSE_FILE_WLS}"
      '
    return ${__FAILED}
  }

  local -r pContainerName=${1?"Container Name to be assigned to the container"}
  local -r pHostName=${2?"Host Name to be assigned to the container instance"}
  local -r pNetworkName=${3?"Network Name to be used for this container"}
  local -r pSourceImageNameString=${4?"Full Image String naming the image on which to base the container"}
  local -r pHostBoundVolumeString=${5?"Complete expression defining the host directory to map to container directory"}
  local -r pHostWSLPathToComposeFile=${6?"Host directory to which to write docker-compose.yml file"}

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

        tty: true         # these two keep the container running even if there is no listener in the foreground
        stdin_open: true

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

    fn__FileSameButForDate \
      ${pHostWSLPathToComposeFile}  \
      ${pHostWSLPathToComposeFile}_${TS} \
        && STS=${__THE_SAME} \
        || STS=${__DIFFERENT}

      if [[ ${STS} -eq ${__DIFFERENT} ]]; then
        echo "______ docker-compose.yml_${pContainerName} changed - container may need updating"
      else
        rm -f ${pHostWSLPathToComposeFile}_${TS}
      fi
  fi
  return ${__DONE}
}



function fn__CreateWindowsShortcutsForShellInContainer() {
  [[ $# -lt  4 || "${0^^}" == "HELP" ]] && {
    echo '
      Usage: 
        fn__CreateWindowsShortcutsForShellInContainer \
          "${__GIT_TEST_CLIENT_CONTAINER_NAME}" \
          "${__DEBMIN_HOME_DOS}" \
          "${__GIT_TEST_CLIENT_SHELL}" \
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

  lARGS="/c wsl -d Debian -- bash -lc \"docker.exe container exec -itu ${__GIT_TEST_CLIENT_USERNAME} --workdir ${__GIT_TEST_CLIENT_GUEST_HOME} ${pContainerName} ${pShellInContainer} -l\" || pause"
  fn__CreateWindowsShortcut \
    "${pHomeDosPath}\dcc exec -itu ${__GIT_TEST_CLIENT_USERNAME} ${pContainerName}.lnk" \
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


function fn__GenerateSSHKeyPair() {
  [[ $# -lt  4 || "${0^^}" == "HELP" ]] && {
    echo '
  Usage: 
    fn__GenerateSSHKeyPair \
      ${__GIT_TEST_CLIENT_CONTAINER_NAME} \
      ${__GIT_TEST_CLIENT_USERNAME} \
      ${__GIT_TEST_CLIENT_SHELL} \
      "__GIT_TEST_CLIENT_ID_RSA_PUB_" \
        && return ${__DONE} \
        || return ${__FAILED}
        '
    return ${__FAILED}
  }
 
  local -r pClientContainerName=${1?"Container Name to be assigned to the container"}
  local -r pClientUsername=${2?"Host Path, in DOS format, to write shortcuts to"}
  local -r pShellInContainer=${3?"Shell to use on connection to the container"}
  local -n pNameOfOutputVarFromCaller=${4?"Shell to use on connection to the container"}

  # generate id_rsa keypair
  #
  local -r _CMD_='
    rm -rvf ${HOME}/.ssh/id_rsa* >/dev/null || true
    ssh-keygen -f ${HOME}/.ssh/id_rsa -t rsa -b 2048 -q -N "" >/dev/null
    cat ${HOME}/.ssh/id_rsa.pub
  '
  local _CMD_OUTPUT=""
  fn__ExecCommandInContainerGetOutput \
    ${pClientContainerName} \
    ${pClientUsername} \
    ${pShellInContainer} \
    "${_CMD_}" \
    "pNameOfOutputVarFromCaller" \
      && STS=${__DONE} \
      || STS=${__FAILED}

    return ${STS}
}


function fn__IntroduceClientsToServerUsingClientsPublicKey() {
  # introduce client's id_rsa public key to gitserver, which needs it to allow git test client access over ssh
  #
  [[ $# -lt 6 || "${0^^}" == "HELP" ]] && {
    local -r lUsage='
  Usage: 
    fn__IntroduceClientsToServerUsingClientsPublicKey \
      ${__GIT_TEST_CLIENT_CONTAINER_NAME} \
      ${__GIT_TEST_CLIENT_USERNAME} \
      ${__GIT_TEST_CLIENT_ID_RSA_PUB_}  \
      ${__GITSERVER_CONTAINER_NAME} \
      ${__GIT_USERNAME} \
      ${__GITSERVER_SHELL} \
        && STS=${__DONE} \
        || STS=${__FAILED}
        '
    return ${__FAILED}
  }
 
  local -r pClientContainerName=${1?"${lUsage}"}
  local -r pClientUsername=${2?"${lUsage}"}
  local -r pClient_id_rsa_pub=${3?"${lUsage}"}
  local -r pServerContainerName=${4?"${lUsage}"}
  local -r pServerUsername=${5?"${lUsage}"}
  local -r pShellInContainer=${6?"${lUsage}"}

  local -r _CMD_="
    { test -e \${HOME}/.ssh/authorized_keys \
      || touch \${HOME}/.ssh/authorized_keys ; } &&

    { mv \${HOME}/.ssh/authorized_keys ~/.ssh/authorized_keys_previous &&
    chmod 0600 \${HOME}/.ssh/authorized_keys_previous ; } &&

    { test -e \${HOME}/.ssh/authorized_keys \
      && cp \${HOME}/.ssh/authorized_keys \${HOME}/.ssh/authorized_keys_previous \
      || touch \${HOME}/.ssh/authorized_keys \${HOME}/.ssh/authorized_keys_previous ; } &&

    sed \"/${pClientUsername}@${pClientContainerName}/d\" \${HOME}/.ssh/authorized_keys_previous > \${HOME}/.ssh/authorized_keys &&

    echo "\"${pClient_id_rsa_pub}\"" >> \${HOME}/.ssh/authorized_keys &&

    cat \${HOME}/.ssh/authorized_keys
  "

  local _CMD_OUTPUT_=""
  fn__ExecCommandInContainerGetOutput \
    ${pServerContainerName} \
    ${pServerUsername} \
    ${pShellInContainer} \
    "${_CMD_}" \
    "_CMD_OUTPUT_" \
      && return ${__DONE} \
      || return ${__FAILED}
}


function fnAddGITServerToLocalKnown_hostsAndTestSshAccess() {
  echo 'hello'
}


function fnCreateRemoteGitRepoForThisProject() {
  echo 'hello'
}


function fnPerformGitSetupOnHost() {
  echo 'hello'
}


function fnTestRemoteGitRepoOperation() {
  echo 'hello'
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
  "${__GIT_TEST_CLIENT_USERNAME}" \
  "${__GIT_TEST_CLIENT_IMAGE_NAME}:${__GIT_TEST_CLIENT_IMAGE_VERSION}" ## && STS=${__SUCCESS} || STS=${__FAILED} # let it fail 
echo "______ Set local environment variables"; 

fn__ConfirmYN "Create Windows Shortcuts?" && _CREATE_WINDOWS_SHORTCUTS_=${__YES} || _CREATE_WINDOWS_SHORTCUTS_=${__NO}

fn__ConfirmYN "Artefact location will be ${__DEBMIN_HOME} - Is this correct?" && true || {
  echo -e "_______ Aborting ...\n"
  exit
}

# note that we are passing the name of the array of port mappings - the function deals with access to the array
#
fn__CreateDockerComposeFile \
  "${__GIT_TEST_CLIENT_CONTAINER_NAME}"  \
  "${__GIT_TEST_CLIENT_HOST_NAME}"  \
  "${__DEVCICD_NET}"  \
  "${__DEBMIN_SOURCE_IMAGE_NAME}"  \
  "${__DEBMIN_HOME_WSD}/${__GIT_TEST_CLIENT_CONTAINER_NAME}/backups:${__GIT_TEST_CLIENT_GUEST_HOME}/backups" \
  "${__DOCKER_COMPOSE_FILE_WLS}"
echo "______ Created ${__DOCKER_COMPOSE_FILE_WLS}"; 


fn__ImageExists \
  "${__DEBMIN_SOURCE_IMAGE_NAME}" \
  && echo "______ Image ${__DEBMIN_SOURCE_IMAGE_NAME} exist" \
  || {
    echo "repo: ${__DOCKER_REPOSITORY_HOST}/${__GIT_TEST_CLIENT_IMAGE_NAME}:${__GIT_TEST_CLIENT_IMAGE_VERSION}"
    fn__PullImageFromRemoteRepository   \
      ${__DOCKER_REPOSITORY_HOST}  \
      ${__GIT_TEST_CLIENT_IMAGE_NAME} \
      ${__GIT_TEST_CLIENT_IMAGE_VERSION} \
        && echo "______ Image ${__DOCKER_REPOSITORY_HOST}/${__GIT_TEST_CLIENT_IMAGE_NAME}:${__GIT_TEST_CLIENT_IMAGE_VERSION} pulled from remote docker repository" \
        || {
          echo "______ Cannot find image ${__DEBMIN_SOURCE_IMAGE_NAME} [${__DOCKER_REPOSITORY_HOST}/${__GIT_TEST_CLIENT_IMAGE_NAME}:${__GIT_TEST_CLIENT_IMAGE_VERSION}]" 
          echo "______ Aborting script execution ..." 
          exit
        }
  }

fn__ContainerExists \
  ${__GIT_TEST_CLIENT_CONTAINER_NAME} \
    && STS=${__YES} \
    || STS=${__NO}
if [[ $STS -eq ${__YES} ]]; then

  fn__ContainerIsRunning ${__GIT_TEST_CLIENT_CONTAINER_NAME} && STS=${__YES} || STS=${__NO}
  if [[ $STS -eq ${__YES} ]]; then
    echo "______ Container ${__GIT_TEST_CLIENT_CONTAINER_NAME} Exist and is running ... - nothing needs doing"; 
    exit

  else
    fn__StartContainer ${__GIT_TEST_CLIENT_CONTAINER_NAME} && STS=${__YES} || STS=${__NO}
    if [[ $STS -eq ${__DONE} ]]; then
        echo "______ Container ${__GIT_TEST_CLIENT_CONTAINER_NAME} started"; 
    else
        echo "______ Failed to start container ${__GIT_TEST_CLIENT_CONTAINER_NAME} - investigate..."; 
        exit
    fi
  fi

else
  
  fn_DockerComposeUpDetached "${__DOCKER_COMPOSE_FILE_DOS}" "${__GIT_TEST_CLIENT_CONTAINER_NAME}" && STS=${__DONE} || STS=${__FAILED}
  if [[ $STS -eq ${__DONE} ]]; then
    echo "______ Container ${__GIT_TEST_CLIENT_CONTAINER_NAME} started"; 
  else
    echo "______ Failed to start container ${__GIT_TEST_CLIENT_CONTAINER_NAME} - investigate"; 
    exit
  fi
fi

# # generate id_rsa keypair
# #
# _CMD_='
#   rm -rvf ${HOME}/.ssh/id_rsa* >/dev/null || true
#   ssh-keygen -f ${HOME}/.ssh/id_rsa -t rsa -b 2048 -q -N "" >/dev/null
#   cat ${HOME}/.ssh/id_rsa.pub
# '
__GIT_TEST_CLIENT_ID_RSA_PUB_="a"
fn__GenerateSSHKeyPair \
  ${__GIT_TEST_CLIENT_CONTAINER_NAME} \
  ${__GIT_TEST_CLIENT_USERNAME} \
  ${__GIT_TEST_CLIENT_SHELL} \
  "__GIT_TEST_CLIENT_ID_RSA_PUB_" \
    && STS=${__DONE} \
    || STS=${__FAILED}
echo "______ Generated ${__GIT_TEST_CLIENT_GUEST_HOME}'s ssh keypair"; 

fn__IntroduceClientsToServerUsingClientsPublicKey \
  ${__GIT_TEST_CLIENT_CONTAINER_NAME} \
  ${__GIT_TEST_CLIENT_USERNAME} \
  "${__GIT_TEST_CLIENT_ID_RSA_PUB_}"  \
  ${__GITSERVER_CONTAINER_NAME} \
  ${__GIT_USERNAME} \
  ${__GITSERVER_SHELL} \
    && STS=${__DONE} \
    || STS=${__FAILED}
echo "______ Added ${__GIT_TEST_CLIENT_GUEST_HOME}'s public key to ${__GITSERVER_HOST_NAME}'s ~/.ssh/authorised_keys"; 


# _CMD_="
# ssh-keyscan -H ${__GITSERVER_HOST_NAME} >> ~/.ssh/known_hosts &&
# ssh git@${__GITSERVER_HOST_NAME} list && echo 'Can connect to the remote git repo' || echo 'Cannot connect to the remote git repo'
# "
# _CMD_OUTPUT_=""
# fn__ExecCommandInContainerGetOutput \
#   ${__GIT_TEST_CLIENT_CONTAINER_NAME} \
#   ${__GIT_TEST_CLIENT_USERNAME} \
#   ${__GIT_TEST_CLIENT_SHELL} \
#   "${_CMD_}" \
#   "_CMD_OUTPUT_" \
#     && STS=${__DONE} \
#     || STS=${__FAILED}
# echo "______ Added ${__GITSERVER_HOST_NAME} to ${__GIT_TEST_CLIENT_GUEST_HOME}'s ~/.ssh/known_hosts"; 

# # test script to exercise local and remote git repository functionality,
# # ssh configuration and object ownership
# #
# _CMD_="
#   mkdir -p ${__GIT_TEST_CLIENT_GUEST_HOME}/dev &&
#   cd ${__GIT_TEST_CLIENT_GUEST_HOME}/dev &&
#   rm -Rf .git * &&

#   git init &&

#   git config core.editor nano &&
#   git config user.name \"postmaster\" &&
#   git config user.email \"postmaster@localhost\" &&

#   { git remote remove origin 2>/dev/null || true ; } &&
#   git remote add origin ssh://${__GIT_USERNAME}@${__GITSERVER_HOST_NAME}${__GITSERVER_REPOS_ROOT}/${__GITSERVER_REM_TEST_REPO_NAME}.git &&

#   { git pull origin master || true ; } &&

#   echo \"echo 'Hello, ${__GIT_TEST_CLIENT_USERNAME}'\" > greet.sh &&
#   chmod u+x greet.sh &&
#   touch READEME.txt random.cpp random.h &&

#   git add . || true &&
#   git commit -m 'test commit'  || true &&

#   git push origin master &&

#   cd ${__GIT_TEST_CLIENT_GUEST_HOME}/dev &&
#   rm -Rf .git || true &&
#   rm -f *.{txt,sh,cpp,h} || true &&

#   cd ${__GIT_TEST_CLIENT_GUEST_HOME}/dev &&
#   git init || true &&
#   { git remote remove origin 2>/dev/null || true ; } &&
#   git remote add origin ssh://${__GIT_USERNAME}@${__GITSERVER_HOST_NAME}${__GITSERVER_REPOS_ROOT}/${__GITSERVER_REM_TEST_REPO_NAME}.git &&

#   git pull origin master &&
#   chmod u+x ./greet.sh &&
#   ./greet.sh
# "
# _CMD_OUTPUT_=""
# fn__ExecCommandInContainerGetOutput \
#   ${__GIT_TEST_CLIENT_CONTAINER_NAME} \
#   ${__GIT_TEST_CLIENT_USERNAME} \
#   ${__GIT_TEST_CLIENT_SHELL} \
#   "${_CMD_}" \
#   "_CMD_OUTPUT_" \
#       && echo "______ Local abd Remote Git repository test completed" \
#       || echo "______ Local abd Remote Git repository test failed - investigate!!!"

# [[ ${_CREATE_WINDOWS_SHORTCUTS_} -eq ${__YES} ]] && {
#   fn__CreateWindowsShortcutsForShellInContainer \
#     "${__GIT_TEST_CLIENT_CONTAINER_NAME}" \
#     "${__DEBMIN_HOME_DOS}" \
#     "${__GIT_TEST_CLIENT_SHELL}" \
#     "${__DOCKER_COMPOSE_FILE_DOS}" && STS=${__DONE} || STS=${__FAILED}
#   echo "______ Created Windows Shortcuts"; 
# }

echo "______ ${0} Done"
