#!/bin/bash
# #############################################
# The MIT License (MIT)
#
# Copyright © 2020 Michael Czapski
# #############################################

declare -ur _02_create_git_client_container_utils

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


:<<-'COMMENT--fn__GetProjectName-----------------------------------------'
  Usage:
    fn__GetProjectName
      __DEBMIN_HOME in/out
  Returns:
    __SUCCESS and the project name derived from the directry path if project structure is correct and directory hierarchy exists 
    __FAILED if there were insufficient arguments or the directory path does not conform to expectations
COMMENT--fn__GetProjectName-----------------------------------------
function fn__GetProjectName() {
  local -r lUsage='
  Usage: 
    fn__GetProjectName \
      "__DEBMIN_HOME" # in/out
    '
  # this picks up missing arguments
  #
  [[ $# -lt 1 || "${0^^}" == "HELP" ]] && {
    echo -e "${__INSUFFICIENT_ARGS}\n${lUsage}"
    return ${__FAILED}
  }

  # this picks up arguments which are empty strings rather than being variable names, as expected
  # 
  [[ -n "${1}" ]] 2>/dev/null || { echo "1st Argument value, '${1}', is invalid"; return ${__FAILED} ; }

  ## expect directory structure like
  ## /mnt/x/dir1/dir2/..dirN/projectDir/_commonUtils/02_create_node13131_container
  ## and working directory /mnt/x/dir1/dir2/..dirN/projectDir/_commonUtils

  local -n inout__DEBMIN_HOME=${1}

  local -r lBaseDir=$(basename "${inout__DEBMIN_HOME}")
  if [[ "${lBaseDir}" != "${__SCRIPTS_DIRECTORY_NAME}" ]]
  then
    inout__DEBMIN_HOME="${inout__DEBMIN_HOME}/${__SCRIPTS_DIRECTORY_NAME}"
  fi

  fn__GetProjectDirectory "${1}" || return $?

  inout__DEBMIN_HOME=${inout__DEBMIN_HOME%%/${__SCRIPTS_DIRECTORY_NAME}}
  inout__DEBMIN_HOME=$(basename ${inout__DEBMIN_HOME})

  return ${__SUCCESS}
}


:<<-'COMMENT--fn__GetProjectDirectory-----------------------------------------'
  Usage:
    fn__GetProjectDirectory
      __DEBMIN_HOME in/out
  Returns:
    __SUCCESS and the directory path conforms to the expectation and directory path
    __FAILED if there were insufficient arguments or the directory path does not conform to expectations
COMMENT--fn__GetProjectDirectory-----------------------------------------
function fn__GetProjectDirectory() {
  local -r lUsage='
  Usage: 
    fn__GetProjectDirectory \
      "__DEBMIN_HOME"  \            # in/out
    '
  # this picks up missing arguments
  #
  [[ $# -lt 1 || "${0^^}" == "HELP" ]] && {
    echo -e "${__INSUFFICIENT_ARGS}\n${lUsage}"
    return ${__FAILED}
  }

  # this picks up arguments which are empty strings rather than being variable names, as expected
  # 
  [[ -n "${1}" ]] 2>/dev/null || { echo "1st Argument value, '${1}', is invalid"; return ${__FAILED} ; }

  ## expect directory structure like
  ## /mnt/x/dir1/dir2/..dirN/projectDir/_commonUtils/02_create_node13131_container
  ## and working directory /mnt/x/dir1/dir2/..dirN/projectDir/_commonUtils

  local -n inout__DEBMIN_HOME=${1}

  local -r lBasename=$(basename "${inout__DEBMIN_HOME}")

  if [[ "${lBasename}" != "${__SCRIPTS_DIRECTORY_NAME}" ]]
  then
    inout__DEBMIN_HOME="Invalid project structure - basename of the directory hierarchy is not '${__SCRIPTS_DIRECTORY_NAME}'"
    return ${__FAILED}
  fi
  
  if [[ ! -d ${inout__DEBMIN_HOME} ]]
  then
    inout__DEBMIN_HOME="Directory hierarchy '${inout__DEBMIN_HOME}' does not exist"
    return ${__FAILED}
  fi
  
  lProjectHomePath=${inout__DEBMIN_HOME%%/${__SCRIPTS_DIRECTORY_NAME}}

  inout__DEBMIN_HOME=${lProjectHomePath}
  return ${__SUCCESS}
}



:<<-'COMMENT--fn__GetClientContainerName-----------------------------------------'
  Usage:
    fn__GetClientContainerName
      __DEBMIN_HOME in
      __GIT_CLIENT_CONTAINER_NAME in/out
  Returns:
    __SUCCESS and the chosen name in populated __GIT_CLIENT_CONTAINER_NAME
    __FAILED if there were insufficient arguments
    Script abort if all opportunities to choose a container name were exhausted

COMMENT--fn__GetClientContainerName-----------------------------------------

function fn__GetClientContainerName() {
  local -r lUsage='
  Usage: 
    fn__GetClientContainerName \
      "__DEBMIN_HOME"  \            # in
      "__GIT_CLIENT_CONTAINER_NAME" # inout
    '
  # this picks up missing arguments
  #
  [[ $# -lt 2 || "${0^^}" == "HELP" ]] && {
    echo -e "${__INSUFFICIENT_ARGS}\n${lUsage}"
    return ${__FAILED}
  }

  # this picks up arguments which are empty strings
  # 
  [[ -n "${1}" ]] 2>/dev/null || { echo "1st Argument value, '${1}', is invalid"; return ${__FAILED} ; }
  [[ -n "${2}" ]] 2>/dev/null || { echo "2nd Argument value, '${2}', is invalid"; return ${__FAILED} ; }

  # name reference variables
  #
  local -n in__DEBMIN_HOME=$1
  local -n inout__GIT_CLIENT_CONTAINER_NAME=$2

  fn__ConfirmYN "Use default name '${inout__GIT_CLIENT_CONTAINER_NAME}' as container name? " && STS=${__YES} || STS=${__NO}
  if [[ ${STS} -eq ${__YES} ]] 
  then
    return ${__YES}
  fi

  declare lDerivedContainerName=$(fn__DeriveContainerName ${in__DEBMIN_HOME}) && STS=$? || STS=$?
  if [[ ${STS} -eq ${__FAILED} ]]
  then
    return ${__FAILED}
  fi

  fn__ConfirmYN "Use project directory-derived name '${lDerivedContainerName}' as container name? " && STS=${__YES} || STS=${__NO}
  if [[ ${STS} -eq ${__YES} ]] 
  then
    __GIT_CLIENT_CONTAINER_NAME=${lDerivedContainerName}
    return ${__YES}
  fi

  inPromptString="_????_ Please enter a valid identifier for container name (Defaut: '${lDerivedContainerName}'): "
  inMaxLength=20
  inTimeoutSecs=30
  outValidValue="${lDerivedContainerName}"

  fn__GetValidIdentifierInput \
    "inPromptString" \
    "inMaxLength" \
    "inTimeoutSecs" \
    "outValidValue" \
        && STS=$? \
        || STS=$?

  if [[ ${STS} -eq ${__FAILED} ]]
  then
    echo "____ Provided input did not result in a valid identifier - identifier based on input was '${outValidValue}'"
    return ${__FAILED}
  fi
  echo "____ Sanitized container name will be '${outValidValue}'"

  fn__ConfirmYN "Confirm '${outValidValue}' as container name? " && STS=$? || STS=$?
  if [[ ${STS} -eq ${__NO} ]]
  then
    return ${__NO}
  else
    inout__GIT_CLIENT_CONTAINER_NAME=${outValidValue}
  fi

  return ${__SUCCESS}
}



:<<-'COMMENT--fn__GetRemoteGitRepoName-----------------------------------------'
  Usage:
    fn__GetRemoteGitRepoName
      ${__GIT_CLIENT_REMOTE_REPO_NAME}
      "__GIT_CLIENT_REMOTE_REPO_NAME" out
  Returns:
    __SUCCESS and the chosen name in __GIT_CLIENT_CONTAINER_NAME ref variable
    __FAILED if there were insufficient arguments, all opportunities to choose a name were exhausted or other unrecoverable errors occured

COMMENT--fn__GetRemoteGitRepoName-----------------------------------------

function fn__GetRemoteGitRepoName() {
  local -r lUsage='
  Usage: 
    fn__GetRemoteGitRepoName \
      ${__GIT_CLIENT_REMOTE_REPO_NAME}  \
      "__GIT_CLIENT_REMOTE_REPO_NAME" # out
    '
  # this picks up missing arguments
  #
  [[ $# -lt 2 || "${0^^}" == "HELP" ]] && {
    echo -e "${__INSUFFICIENT_ARGS}\n${lUsage}"
    return ${__FAILED}
  }

  # name reference variables
  #
  local -r lDefaultGitRemoteRepoName="${1}"
  local -n out__GIT_CLIENT_REMOTE_REPO_NAME=${2} 2>/dev/null

  # this picks up arguments which are empty strings
  # 
  [[ -n lDefaultGitRemoteRepoName ]] 2>/dev/null || { echo "1st Argument value, '${1}', is invalid"; return ${__FAILED} ; }
  [[ -n "${2}" ]] 2>/dev/null || { echo "2nd Argument value, '${2}', is invalid"; return ${__FAILED} ; }

  fn__ConfirmYN "Use default name '${lDefaultGitRemoteRepoName}' as Remote Git Repository name? " && STS=${__YES} || STS=${__NO}
  if [[ ${STS} -eq ${__YES} ]] 
  then
    out__GIT_CLIENT_REMOTE_REPO_NAME=${lDefaultGitRemoteRepoName}
    return ${__YES}
  fi

  inPromptString="_????_ Please enter a valid identifier for Git Repository name (Defaut: '${lDefaultGitRemoteRepoName}'): "
  inMaxLength=${__MAX_CONTAIMER_NAME_LENGTH}
  inTimeoutSecs=${_PROMPTS_TIMEOUT_SECS_}
  outValidValue="${lDefaultGitRemoteRepoName}"

  # read -t 10 resp
  # echo "${FUNCNAME}:${LINENO}: resp: ${resp}"

  fn__GetValidIdentifierInput \
    "inPromptString" \
    "inMaxLength" \
    "inTimeoutSecs" \
    "outValidValue" \
        && STS=$? \
        || STS=$?

  if [[ ${STS} -eq ${__FAILED} ]]
  then
    echo "____ Provided input did not result in a valid identifier - identifier based on input was '${outValidValue}'"
    return ${__FAILED}
  fi
  echo "____ Sanitized Git Repository name will be '${outValidValue}'"

  fn__ConfirmYN "Confirm '${outValidValue}' as Git Repository name? " && STS=$? || STS=$?
  if [[ ${STS} -eq ${__NO} ]]
  then
    out__GIT_CLIENT_REMOTE_REPO_NAME=""
    return ${__NO}
  fi
echo ${outValidValue}
  out__GIT_CLIENT_REMOTE_REPO_NAME="${outValidValue}"
echo ${out__GIT_CLIENT_REMOTE_REPO_NAME}
  return ${__YES}
}


function fn__CreateDockerComposeFile() {
  local -r lUsage='
  Usage: 
    fn__CreateDockerComposeFile \
      "${__GIT_CLIENT_CONTAINER_NAME}"  \
      "${__GIT_CLIENT_HOST_NAME}"  \
      "${__DEVCICD_NET_DC_INTERNAL}"  \
      "${__CONTAINER_SOURCE_IMAGE_NAME}"  \
      "${__DEBMIN_HOME_DOS}:${__GIT_CLIENT_GUEST_HOME}" \
      "${__DOCKER_COMPOSE_FILE_WLS}"
    '
  [[ $# -lt  5 || "${0^^}" == "HELP" ]] && {
    echo -e "${__INSUFFICIENT_ARGS}\n${lUsage}"
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
  local TS=$(date '+%Y%m%d_%H%M%S')
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
        echo "____ docker-compose.yml_${pContainerName} changed - container may need updating"
      else
        rm -f ${pHostWSLPathToComposeFile}_${TS}
      fi
  fi
  return ${__DONE}
}


function fn__DeriveContainerName() {
  local -r lUsage='
  Usage: 
    lContainerName=$(fn__DeriveContainerName \
      ${__DEBMIN_HOME})
    '
  [[ $# -lt  1 || "${0^^}" == "HELP" ]] && {
    echo -e "${__INSUFFICIENT_ARGS}\n${lUsage}"
    return ${__FAILED}
  }

  # derive container name from the name of the parent of _commonUtils
  #
  local -r pWorkingDirectoryString=${1?"Current Working Directory is required\n${lUsage}"}
  local lContainerName=${pWorkingDirectoryString%%/${__SCRIPTS_DIRECTORY_NAME}}
  lContainerName=${lContainerName##*/} # strip directory hierarchy before parent of _commonUtils
  [[ -z lContainerName ]] && return ${__FAILED}

  # lContainerName=${lContainerName//[ _^%@-]/}  # remove special characters, if any, from project name
  lContainerName=$(fn__SanitizeInputIdentifier ${lContainerName} ) || return ${__FAILED}

  # reduce project name to no more than __MaxNameLen__ characters
  #
  local -ri __MaxNameLen__=${__MAX_CONTAIMER_NAME_LENGTH}
  local -ri nameLen=${#lContainerName}
  local startPos=$((${nameLen}-${__MaxNameLen__})) 
  startPos=${startPos//-*/0} 
  local -r lContainerName=${lContainerName:${startPos}}
  echo ${lContainerName}
  return ${__SUCCESS}
}


:<<-'COMMENT--fn__SetEnvironmentVariables-----------------------------------------'
  Usage:
    fn__SetEnvironmentVariables   \
      "${__DEBMIN_HOME}" \
      "${__GIT_CLIENT_IMAGE_NAME}:${__GIT_CLIENT_IMAGE_VERSION}"  \
      "__DEBMIN_HOME" \
      "__DEBMIN_HOME_WSD" \
      "__DEBMIN_HOME_DOS" \
      "__DOCKER_COMPOSE_FILE_WLS" \
      "__DOCKER_COMPOSE_FILE_DOS" \
      "__CONTAINER_SOURCE_IMAGE_NAME" \
      "__GIT_CLIENT_CONTAINER_NAME" \
      "__GIT_CLIENT_HOST_NAME" \
      "__GIT_CLIENT_REMOTE_REPO_NAME" \
  Returns:
    ${__SUCCESS}
    ${__INSUFFICIENT_ARGS_STS}
    ${__EMPTY_ARGUMENT_NOT_ALLOWED}
    ${__INVALID_VALUE}
    ${__FAILED}   # presumed container name is not a valid identifier
Rework fn__SetEnvironmentVariables tests and main 02 use thereof
COMMENT--fn__SetEnvironmentVariables-----------------------------------------

function fn__SetEnvironmentVariables() {

  ## expect directory structure like
  ## /mnt/x/dir1/dir2/..dirN/projectDir/_commonUtils/02_create_node13131_container
  ## and working directory /mnt/x/dir1/dir2/..dirN/projectDir/_commonUtils

  [[ $# -lt 11  ]] && return ${__INSUFFICIENT_ARGS_STS}

  function _fnMissingOrEmpty() { [[ -z "${1}" ]] ; }
  function _fnPresentAndValued() { [[ -n "${1}" ]] ; }

  _fnMissingOrEmpty  ${1} 2>/dev/null && return ${__EMPTY_ARGUMENT_NOT_ALLOWED}
  _fnMissingOrEmpty  ${2} 2>/dev/null && return ${__EMPTY_ARGUMENT_NOT_ALLOWED}

  # name variables
  #
  local -r lrDebminHomeIn=${1}
  local -r lrGitserverImageNameAndVersion=${2}
  local -r lrDebminHomeOut=${3}
  local -r lrDebminHomeOutWSD=${4} 
  local -r lrDebminHomeOutDOS=${5}
  local -r lrDockerComposeFileWSL=${6}
  local -r lrDockerComposeFileDOS=${7}
  local -r lrContainerSourceImage=${8}
  local -r lrGitClientContainerName=${9}
  local -r lrGitClientHostName=${10}
  local -r lrGitClientRemoteRepoName=${11}

  _fnMissingOrEmpty ${lrDebminHomeIn} && return ${__INVALID_VALUE}
  _fnMissingOrEmpty ${lrGitserverImageNameAndVersion} && return ${__INVALID_VALUE}
  _fnMissingOrEmpty ${lrDebminHomeOut} && return ${__INVALID_VALUE}
  _fnMissingOrEmpty ${lrDebminHomeOutWSD} && return ${__INVALID_VALUE}
  _fnMissingOrEmpty ${lrDebminHomeOutDOS} && return ${__INVALID_VALUE}
  _fnMissingOrEmpty ${lrDockerComposeFileWSL} && return ${__INVALID_VALUE}
  _fnMissingOrEmpty ${lrDockerComposeFileDOS} && return ${__INVALID_VALUE}
  _fnMissingOrEmpty ${lrContainerSourceImage} && return ${__INVALID_VALUE}
  _fnMissingOrEmpty ${lrGitClientContainerName} && return ${__INVALID_VALUE}
  _fnMissingOrEmpty ${lrGitClientHostName} && return ${__INVALID_VALUE}
  _fnMissingOrEmpty ${lrGitClientRemoteRepoName} && return ${__INVALID_VALUE}

  # _fnPresentAndValued ${2} && echo present and valued || echo not present or not valued

  local -n lrefDebminHomeOut=${3}
  local -n lrefDebminHomeOutWSD=${4} 
  local -n lrefDebminHomeOutDOS=${5}
  local -n lrefDockerComposeFileWSL=${6}
  local -n lrefDockerComposeFileDOS=${7}
  local -n lrefContainerSourceImage=${8}
  local -n lrefGitClientContainerName=${9}
  local -n lrefGitClientHostName=${10}
  local -n lrefGitClientRemoteRepoName=${11}

  # set environment
  #
  # mkdir -pv ${lrDebminHomeIn}

  test -d ${lrDebminHomeIn} || return ${__NO_SUCH_DIRECTORY}

  lrefDebminHomeOut=${lrDebminHomeIn%%/${__SCRIPTS_DIRECTORY_NAME}} # strip _commonUtils
  test -d ${lrefDebminHomeOut} || return ${__NO_SUCH_DIRECTORY}

  cd ${lrefDebminHomeOut}|| return ${__NO_SUCH_DIRECTORY}

  local lContainerName=${lrefDebminHomeOut##*/} # strip directory hierarchy before parent of _commonUtils
  lContainerName=$(fn__SanitizeInputIdentifier ${lContainerName} ) || return ${__FAILED}

  # reduce project name to no more than __MaxNameLen__ characters
  local -ri nameLen=${#lContainerName}
  local startPos=$((${nameLen}-${__MAX_CONTAIMER_NAME_LENGTH})) 
  startPos=${startPos//-*/0} 
  local -r lContainerName=${lContainerName:${startPos}}
  lrefGitClientContainerName=${lContainerName}
  lrefGitClientHostName=${lContainerName}
  lrefGitClientRemoteRepoName=${lContainerName}

  lrefDebminHomeOutWSD=$(fn__WSLPathToWSDPath ${lrefDebminHomeOut})
  lrefDebminHomeOutDOS=$(fn__WSLPathToRealDosPath ${lrefDebminHomeOut})

  lrefDockerComposeFileWSL="${lrefDebminHomeOut}/docker-compose.yml_${lContainerName}"
  lrefDockerComposeFileDOS="${lrefDebminHomeOutDOS}\\docker-compose.yml_${lContainerName}"

  lrefContainerSourceImage="${lrGitserverImageNameAndVersion}"

# echo "lrefDebminHomeOut: ${lrefDebminHomeOut}"
# echo "lrefDebminHomeOutWSD: ${lrefDebminHomeOutWSD} "
# echo "lrefDebminHomeOutDOS: ${lrefDebminHomeOutDOS}"
# echo "lrefDockerComposeFileWSL: ${lrefDockerComposeFileWSL}"
# echo "lrefDockerComposeFileDOS: ${lrefDockerComposeFileDOS}"
# echo "lrefContainerSourceImage: ${lrefContainerSourceImage}"
# echo "lrefGitClientContainerName: ${lrefGitClientContainerName}"
# echo "lrefGitClientHostName: ${lrefGitClientHostName0}"
# echo "lrefGitClientRemoteRepoName: ${lrefGitClientRemoteRepoName1}"

  return ${__SUCCESS}
}


function fn__CreateWindowsShortcutsForShellInContainer() {
  [[ $# -lt  4 || "${0^^}" == "HELP" ]] && {
    echo '
      Usage: 
        fn__CreateWindowsShortcutsForShellInContainer \
          "${__GIT_CLIENT_CONTAINER_NAME}" \
          "${__DEBMIN_HOME_DOS}" \
          "${__GIT_CLIENT_SHELL}" \
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

  lARGS="/c wsl -d Debian -- bash -lc \"docker.exe container exec -itu ${__GIT_CLIENT_USERNAME} --workdir ${__GIT_CLIENT_GUEST_HOME} ${pContainerName} ${pShellInContainer} -l\" || pause"
  fn__CreateWindowsShortcut \
    "${pHomeDosPath}\dcc exec -itu ${__GIT_CLIENT_USERNAME} ${pContainerName}.lnk" \
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


# function fn__AddGITServerToLocalKnown_hostsAndTestSshAccess() {
#   # introduce server to client
#   #
#   [[ $# -lt 3 || "${0^^}" == "HELP" ]] && {
#     local -r lUsage='
#   Usage: 
#     fn__AddGITServerToLocalKnown_hostsAndTestSshAccess \
#       ${__GIT_CLIENT_CONTAINER_NAME} \
#       ${__GIT_CLIENT_USERNAME} \
#       ${__GIT_CLIENT_SHELL} \
#         && STS=${__DONE} \
#         || STS=${__FAILED}
#         '
#     return ${__FAILED}
#   }
 
#   local -r pClientContainerName=${1?"${lUsage}"}
#   local -r pClientUsername=${2?"${lUsage}"}
#   local -r pShellInContainer=${3?"${lUsage}"}

#   local -r _CMD_="
#     ssh-keyscan -H ${__GITSERVER_HOST_NAME} >> ~/.ssh/known_hosts &&
#     ssh git@${__GITSERVER_HOST_NAME} list && echo 'Can connect to the remote git repo' || echo 'Cannot connect to the remote git repo'
#     "

#   _CMD_OUTPUT_=""
#   fn__ExecCommandInContainerGetOutput \
#     ${pClientContainerName} \
#     ${pClientUsername} \
#     ${pShellInContainer} \
#     "${_CMD_}" \
#     "_CMD_OUTPUT_" \
#       && return ${__DONE} \
#       || return ${__FAILED}
# }


function fn__TestLocalAndRemoteGitReposOperation() {

  # test local and remote git repository operation
  #
  [[ $# -lt 8 || "${0^^}" == "HELP" ]] && {
    local -r lUsage='
  Usage: 
    fn__TestLocalAndRemoteGitReposOperation \
      ${__GIT_CLIENT_CONTAINER_NAME} \
      ${__GIT_CLIENT_USERNAME} \
      ${__GIT_CLIENT_SHELL} \
      ${__GIT_CLIENT_GUEST_HOME} \
      ${__GITSERVER_HOST_NAME} \
      ${__GIT_USERNAME} \
      ${__GITSERVER_REPOS_ROOT} \
      ${__GIT_CLIENT_REMOTE_REPO_NAME} \
        && STS=${__DONE} \
        || STS=${__FAILED}
        '
    return ${__FAILED}
  }
 
  local -r pClientContainerName=${1?"${lUsage}"}
  local -r pClientUsername=${2?"${lUsage}"}
  local -r pClientShellInContainer=${3?"${lUsage}"}
  local -r pClientHomeDir=${4?"${lUsage}"}
  local -r pServerHostname=${5?"${lUsage}"}
  local -r pServerUsername=${6?"${lUsage}"}
  local -r pServerGitReposRoot=${7?"${lUsage}"}
  local -r pServerTestGitRepoName=${8?"${lUsage}"}

  local -r _CMD_="
    mkdir -p ${pClientHomeDir}/dev &&
    cd ${pClientHomeDir}/dev &&
    rm -Rf .git * &&

    git init &&

    git config core.editor nano &&
    git config user.name \"postmaster\" &&
    git config user.email \"postmaster@localhost\" &&

    { git remote remove origin 2>/dev/null || true ; } &&
    git remote add origin ssh://${pServerUsername}@${pServerHostname}${pServerGitReposRoot}/${pServerTestGitRepoName}.git &&

    { git pull origin master || true ; } &&

    echo \"echo 'Hello, ${pClientUsername}'\" > greet.sh &&
    chmod u+x greet.sh &&
    touch READEME.txt random.cpp random.h &&

    git add . || true &&
    git commit -m 'test commit' || true &&

    git push origin master &&

    cd ${pClientHomeDir}/dev &&
    rm -Rf .git || true &&
    rm -f *.{txt,sh,cpp,h} || true &&

    cd ${pClientHomeDir}/dev &&
    git init || true &&
    { git remote remove origin 2>/dev/null || true ; } &&
    git remote add origin ssh://${pServerUsername}@${pServerHostname}${pServerGitReposRoot}/${pServerTestGitRepoName}.git &&

    git pull origin master &&
    chmod u+x ./greet.sh &&
    ./greet.sh
  "

  local _CMD_OUTPUT_=""
  fn__ExecCommandInContainerGetOutput \
    ${pClientContainerName} \
    ${pClientUsername} \
    ${pClientShellInContainer} \
    "${_CMD_}" \
    "_CMD_OUTPUT_" \
        && return ${__DONE} \
        || return ${__FAILED}
}
