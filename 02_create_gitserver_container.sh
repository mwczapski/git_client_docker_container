#!/bin/bash
# #############################################
# The MIT License (MIT)
#
# Copyright © 2020 Michael Czapski
# #############################################

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
            "${__GITSERVER_USERNAME}" \
            "${__GITSERVER_IMAGE_NAME}:${__GITSERVER_IMAGE_VERSION}"
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
  # readonly __GITSERVER_CONTAINER_NAME="${lContainerName}"
  # readonly __GITSERVER_HOST_NAME="${lContainerName}"

  __DEBMIN_HOME=${pDebminHome}
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
            "${__GITSERVER_CONTAINER_NAME}"  \
            "${__GITSERVER_HOST_NAME}"  \
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

        # entrypoint: /usr/local/bin/docker-entrypoint.sh

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

    fn__FileSameButForDate \
      ${pHostWSLPathToComposeFile}  \
      ${pHostWSLPathToComposeFile}_${TS} \
        && STS=${__THE_SAME} \
        || STS=${__DIFFERENT}

      if [[ ${STS} -eq ${__DIFFERENT} ]]; then
        echo "______ docker-compose.yml_${pContainerName} changed - container may need updating"
      else
        rm -fv ${pHostWSLPathToComposeFile}_${TS}
      fi
  fi
  return ${__DONE}
}


function fn__CreateWindowsShortcutsForShellInContainer() {
  [[ $# -lt  3 || "${0^^}" == "HELP" ]] && {
    echo '
      Usage: 
        fn__CreateWindowsShortcutsForShellInContainer \
          "${__GITSERVER_CONTAINER_NAME}" \
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


function fnTestTest() {


  ## functions
  function fn__MakeCustomGitShellCommandsDirectory() {
    
    [[ $# -lt 3 || "${0^^}" == "HELP" ]] && {
      local -r lUsage='
    Usage: 
      fn__PopulateGitShellCommandsCustom \
        ${__GITSERVER_CONTAINER_NAME} \
        ${__GIT_USERNAME} \
        ${__GITSERVER_SHELL} \
          && STS=${__DONE} \
          || STS=${__FAILED}
          '
      return ${__FAILED}
    }
  
    local -r pServerContainerName=${1?"${lUsage}"}
    local -r pGitUsername=${2?"${lUsage}"}
    local -r pShellInContainer=${3?"${lUsage}"}
  
    _CMD_="mkdir -p ${__GITSERVER_GUEST_HOME}/git-shell-commands"
    fn__ExecCommandInContainer \
      ${pServerContainerName} \
      ${pGitUsername} \
      ${pShellInContainer} \
      "${_CMD_}" \
        && STS=${__DONE} \
        || STS=${__FAILED}
    echo "______ Created Custom Git Shell Commands directory"; 
  }


 
function fn__CreateCustomGitShellCommandsAndCopyToServer() {

  [[ $# -lt 5 || "${0^^}" == "HELP" ]] && {
  local -r lUsage='
  Usage: 
    fn__CreateCustomGitShellCommandsAndCopyToServer \
      ${__GITSERVER_CONTAINER_NAME} \
      ${__GIT_USERNAME} \
      ${__GITSERVER_SHELL} \
      ${__DEBMIN_HOME_DOS}  \
      ${__DEBMIN_HOME}  \
        && STS=${__DONE} \
        || STS=${__FAILED}
        '
    return ${__FAILED}
  }

  local -r pServerContainerName=${1?"${lUsage}"}
  local -r pGitUsername=${2?"${lUsage}"}
  local -r pShellInContainer=${3?"${lUsage}"}
  local -r pDebminHomeDosPath=${4?"${lUsage}"}
  local -r pDebminHome=${5?"${lUsage}"}

  # make and copy local files
  #
  mkdir -p ${pDebminHome}/git-shell-commands

  cat <<-'EOF' > ${pDebminHome}/git-shell-commands/menu.data
  The following commands are implemented

  -   help                    - show this help message
  -   list                    - list all git repositories
  -   backup <git repo name>  - backup the named repository

EOF
  fn__CopyFileFromHostToContainer \
    ${pServerContainerName} \
    "${pDebminHomeDosPath}\git-shell-commands\menu.data" \
    "${__GITSERVER_GUEST_HOME}/git-shell-commands/menu.data" \
      && STS=${__DONE} \
      || STS=${__FAILED}


  cat <<-EOF >${pDebminHome}/git-shell-commands/no-interactive-login 
#!/bin/sh
echo '----------------------------------------------------------------------'
printf '%s\n' "Hi ${USER}! You've successfully authenticated, but I do not"
printf '%s\n' "provide interactive shell access."
echo '----------------------------------------------------------------------'
echo "\$(IFS= cat ${__GITSERVER_GUEST_HOME}/git-shell-commands/menu.data | while read line; do echo "\${line}"; done)"
echo '----------------------------------------------------------------------'
#exit 128
EOF
  fn__CopyFileFromHostToContainer \
    ${pServerContainerName} \
    "${pDebminHomeDosPath}\git-shell-commands\no-interactive-login" \
    "${__GITSERVER_GUEST_HOME}/git-shell-commands/no-interactive-login" \
      && STS=${__DONE} \
      || STS=${__FAILED}


  cat <<-EOF > ${pDebminHome}/git-shell-commands/help
#!/bin/sh
echo "\$(IFS=  cat ${__GITSERVER_GUEST_HOME}/git-shell-commands/menu.data | while read line; do echo "\${line}"; done)"
exit 0
EOF
  fn__CopyFileFromHostToContainer \
    ${pServerContainerName} \
    "${pDebminHomeDosPath}\git-shell-commands\help" \
    "${__GITSERVER_GUEST_HOME}/git-shell-commands/help" \
      && STS=${__DONE} \
      || STS=${__FAILED}


  cat <<-EOF > ${pDebminHome}/git-shell-commands/list
#!/bin/sh
__GITSERVER_REPOS_ROOT="${__GITSERVER_REPOS_ROOT}"
echo
echo 'Repository Name'
echo '----------------------------------------------------------------------'
find ${__GITSERVER_REPOS_ROOT} -name \*.git -exec basename {} \; | while read i; do echo \${i%%.git}; done
echo '----------------------------------------------------------------------'
exit 0
EOF
  fn__CopyFileFromHostToContainer \
    ${pServerContainerName} \
    "${pDebminHomeDosPath}\git-shell-commands\list" \
    "${__GITSERVER_GUEST_HOME}/git-shell-commands/list" \
      && STS=${__DONE} \
      || STS=${__FAILED}


    cat <<-EOF > ${pDebminHome}/git-shell-commands/backup
#!/bin/sh
GITSERVER_REPOS_ROOT="${__GITSERVER_REPOS_ROOT}"
echo
repoName=\${1?"Name of the Git Repository, which to back, up is required"}
repoName=\${repoName%%.git}
[ -d \${GITSERVER_REPOS_ROOT}/\${repoName}.git ] \
  || { 
    echo "Repository \${1} does not exist - aborting"
    exit 1
  }
TS_FORMAT='+%Y-%m-%d_%H:%M:%S'
TS=\$(date \${TS_FORMAT})
cd \${GITSERVER_REPOS_ROOT}
tar czf \${HOME}/backups/\${repoName}_\${TS} \${repoName}.git || {
  STS=\$?
  echo "Failed to back up repository \${1}"
  echo "Please cpontact your git server administrator"
  exit \${STS}
}
echo "______ Backed up repository \${repoName} to file \${repoName}_\${TS}"
echo "______ \$(ls -lht --time-style="\${TS_FORMAT}" \${HOME}/backups/\${repoName}_\${TS} | cut -d' ' -f3- )"

exit 0
EOF
    fn__CopyFileFromHostToContainer \
      ${pServerContainerName} \
      "${pDebminHomeDosPath}\git-shell-commands\backup" \
      "${__GITSERVER_GUEST_HOME}/git-shell-commands/backup" \
        && STS=${__DONE} \
        || STS=${__FAILED}

}

  ## ###########################################################################
  ## run them
  ##
  fn__MakeCustomGitShellCommandsDirectory \
    ${__GITSERVER_CONTAINER_NAME} \
    ${__GIT_USERNAME} \
    ${__GITSERVER_SHELL} \
      && {

        fn__CreateCustomGitShellCommandsAndCopyToServer \
          ${__GITSERVER_CONTAINER_NAME} \
          ${__GIT_USERNAME} \
          ${__GITSERVER_SHELL} \
          ${__DEBMIN_HOME_DOS}  \
          ${__DEBMIN_HOME}  \
            && {
              echo "______ Created Custom Git Shell Commands"; 
            } \
            || STS=${__FAILED}
      } \
      || STS=${__FAILED}

}


:<<-'COMMENT-----------------------------------------------'

expect directory structure like
/mnt/x/dir1/dir2/..dirN/projectDir/_commonUtils/02_create_node13131_container
and working directory /mnt/x/dir1/dir2/..dirN/projectDir/_commonUtils

COMMENT-----------------------------------------------


## ##################################################################################
## ##################################################################################
##
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
  "${__GITSERVER_IMAGE_NAME}:${__GITSERVER_IMAGE_VERSION}" ## && STS=${__SUCCESS} || STS=${__FAILED} # let it fail 
echo "______ Set local environment variables"; 

fn__ConfirmYN "Create Windows Shortcuts?" && _CREATE_WINDOWS_SHORTCUTS_=${__YES} || _CREATE_WINDOWS_SHORTCUTS_=${__NO}

fn__ConfirmYN "Artefact location will be ${__DEBMIN_HOME} - Is this correct?" && true || {
  echo -e "_______ Aborting ...\n"
  exit
}

# note that we are passing the name of the array of port mappings - the function deals with access to the array
#
fn__CreateDockerComposeFile \
  "${__GITSERVER_CONTAINER_NAME}"  \
  "${__GITSERVER_HOST_NAME}"  \
  "${__DEVCICD_NET}"  \
  "${__DEBMIN_SOURCE_IMAGE_NAME}"  \
  "__GITSERVER_PORT_MAPPINGS"  \
  "${__DEBMIN_HOME_WSD}/backups:${__GITSERVER_HOST_BACKUP_DIR}" \
  "${__DOCKER_COMPOSE_FILE_WLS}"
echo "______ Created ${__DOCKER_COMPOSE_FILE_WLS}"; 


fn__ImageExists \
  "${__DEBMIN_SOURCE_IMAGE_NAME}" \

  && echo "______ Image ${__DEBMIN_SOURCE_IMAGE_NAME} exist" \

  || {
    echo "repo: ${__DOCKER_REPOSITORY_HOST}/${__GITSERVER_IMAGE_NAME}:${__GITSERVER_IMAGE_VERSION}"
    fn__PullImageFromRemoteRepository   \
      ${__DOCKER_REPOSITORY_HOST}  \
      ${__GITSERVER_IMAGE_NAME} \
      ${__GITSERVER_IMAGE_VERSION} \
        && echo "______ Image ${__DOCKER_REPOSITORY_HOST}/${__GITSERVER_IMAGE_NAME}:${__GITSERVER_IMAGE_VERSION} pulled from remote docker repository" \
        || {
          echo "______ Cannot find image ${__DEBMIN_SOURCE_IMAGE_NAME} [${__DOCKER_REPOSITORY_HOST}/${__GITSERVER_IMAGE_NAME}:${__GITSERVER_IMAGE_VERSION}]" 
          echo "______ Aborting script execution ..." 
          exit
        }
  }


fn__ContainerExists \
  ${__GITSERVER_CONTAINER_NAME} \
    && STS=${__YES} \
    || STS=${__NO}
    
if [[ $STS -eq ${__YES} ]]; then

  fn__ContainerIsRunning ${__GITSERVER_CONTAINER_NAME} && STS=${__YES} || STS=${__NO}
  if [[ $STS -eq ${__YES} ]]; then

    echo "______ Container ${__GITSERVER_CONTAINER_NAME} Exist and is running ... - nothing needs doing"; 

    ## ######################################
    ## ######################################
    # fnTestTest
    #     exit
    ## ######################################
    ## ######################################

  else
    fn__StartContainer ${__GITSERVER_CONTAINER_NAME} && STS=${__YES} || STS=${__NO}
    if [[ $STS -eq ${__DONE} ]]; then
        echo "______ Container ${__GITSERVER_CONTAINER_NAME} started"; 
    else
        echo "______ Failed to start container ${__GITSERVER_CONTAINER_NAME} - investigate..."; 
        exit
    fi
  fi

else
  
  fn_DockerComposeUpDetached "${__DOCKER_COMPOSE_FILE_DOS}" "${__GITSERVER_CONTAINER_NAME}" && STS=${__DONE} || STS=${__FAILED}
  if [[ $STS -eq ${__DONE} ]]; then
    echo "______ Container ${__GITSERVER_CONTAINER_NAME} started"; 
  else
    echo "______ Failed to start container ${__GITSERVER_CONTAINER_NAME} - investigate"; 
    exit
  fi
fi

_CMD_="service ssh start"
fn__ExecCommandInContainer \
  ${__GITSERVER_CONTAINER_NAME} \
  "root" \
  ${__GITSERVER_SHELL} \
  "${_CMD_}" \
    && STS=${__DONE} \
    || STS=${__FAILED}
echo "______ Started ssh server in ${__GITSERVER_CONTAINER_NAME} container"; 


_CMD_="
( [[ -d  ${__GITSERVER_REPOS_ROOT}/${__GITSERVER_REM_TEST_REPO_NAME}.git ]] && \
rm -Rfv  ${__GITSERVER_REPOS_ROOT}/${__GITSERVER_REM_TEST_REPO_NAME}.git ; ) ;\
 { 
   mkdir -pv ${__GITSERVER_REPOS_ROOT}/${__GITSERVER_REM_TEST_REPO_NAME}.git \
   && chown -Rv ${__GIT_USERNAME}:developers  ${__GITSERVER_REPOS_ROOT}/${__GITSERVER_REM_TEST_REPO_NAME}.git \
   && chmod -v g+s ${__GITSERVER_REPOS_ROOT}/${__GITSERVER_REM_TEST_REPO_NAME}.git \
   && cd ${__GITSERVER_REPOS_ROOT}/${__GITSERVER_REM_TEST_REPO_NAME}.git \
   && su - -s ${__GITSERVER_SHELL} -c 'git init --bare ${__GITSERVER_REPOS_ROOT}/${__GITSERVER_REM_TEST_REPO_NAME}.git' ${__GIT_USERNAME}; \
  }"

fn__ExecCommandInContainer \
  ${__GITSERVER_CONTAINER_NAME} \
  "root" \
  ${__GITSERVER_SHELL} \
  "${_CMD_}" \
    && STS=${__DONE} \
    || STS=${__FAILED}
echo "______ Initialised test Git repository in ${__GITSERVER_CONTAINER_NAME} container"; 

[[ ${_CREATE_WINDOWS_SHORTCUTS_} -eq ${__YES} ]] && {
  fn__CreateWindowsShortcutsForShellInContainer \
    "${__GITSERVER_CONTAINER_NAME}" \
    "${__DEBMIN_HOME_DOS}" \
    "${__GITSERVER_SHELL}" \
    "${__DOCKER_COMPOSE_FILE_DOS}" && STS=${__DONE} || STS=${__FAILED}
  echo "______ Created Windows Shortcuts"; 
}

echo "______ ${0} Done"
