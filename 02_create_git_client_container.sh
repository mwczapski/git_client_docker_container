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
# are sourced conditionally - if they were not sourced earlier
#
[[ ${__env_GlobalConstants} ]] || source ./utils/__env_GlobalConstants.sh

[[ ${fn__DockerGeneric} ]] || source ./utils/fn__DockerGeneric.sh
[[ ${__env_devcicd_net} ]] || source ./utils/__env_devcicd_net.sh
[[ ${__env_gitserverConstants} ]] || source ./utils/__env_gitserverConstants.sh
[[ ${__env_gitClientConstants} ]] || source ./utils/__env_gitClientConstants.sh

[[ ${fn__WSLPathToDOSandWSDPaths} ]] || source ./utils/fn__WSLPathToDOSandWSDPaths.sh
[[ ${fn__GitserverGeneric} ]] || source ./utils/fn__GitserverGeneric.sh
[[ ${fn__UtilityGeneric} ]] || source ./utils/fn__UtilityGeneric.sh

[[ ${fn__CreateWindowsShortcut} ]] || source ./utils/fn__CreateWindowsShortcut.sh

[[ ${_02_create_git_client_container_utils} ]] || source ./02_create_git_client_container_utils.sh


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
declare __DEBMIN_HOME=$(pwd)
fn__GetProjectDirectory \
  "__DEBMIN_HOME" || {
    echo "${0}:${LINENO} must run from directory with name _commonUtils and will use the name of its parent directory as project directory."
    exit
  }

declare lProjectName="${__DEBMIN_HOME}/${__SCRIPTS_DIRECTORY_NAME}"
fn__GetProjectName \
  "lProjectName" || {
    echo "${0}:${LINENO} must run from directory with name _commonUtils and will use the name of its parent directory as project directory."
    exit
  }

fn__SetEnvironmentVariables \
  "${__DEBMIN_HOME}" \
  "${__GIT_CLIENT_USERNAME}" \
  "${__GIT_CLIENT_IMAGE_NAME}:${__GIT_CLIENT_IMAGE_VERSION}" ## && STS=${__SUCCESS} || STS=${__FAILED} # let it fail 
echo "______ Set local environment variables"; 

fn__ConfirmYN "Project Directory is ${__DEBMIN_HOME}, Project Name is '${lProjectName}' - Is this correct?" && true || {
  echo -e "______ Aborting ...\n"
  exit
}

cd ${__DEBMIN_HOME}


## offer default container name first
## if not accepted offer derived container name next
## if not accepted request that name be entered explicitly
##
_PROMPTS_TIMEOUT_SECS_=30

:<<-'COMMENT--fn__GetClientContainerName-----------------------------------------'
  Usage
    fn__GetClientContainerName
      __DEBMIN_HOME in
      __GIT_CLIENT_CONTAINER_NAME in/out
  Returns:
    __FAILED if there was an error or all options were exchusted without name selection
    __SUCCESS and the chosen name in __GIT_CLIENT_CONTAINER_NAME
COMMENT--fn__GetClientContainerName-----------------------------------------

fn__GetClientContainerName  \
  "__DEBMIN_HOME" \
  "__GIT_CLIENT_CONTAINER_NAME" && STS=$? || STS=$?
if [[ ${STS} -ne ${__SUCCESS} ]]
then
  echo "______ Failed to choose container name."
  echo "______ Aborting ..."
  exit ${__FAILED}
fi
echo "______ Using '${__GIT_CLIENT_CONTAINER_NAME}' as Container Name and Host Name"





exit

fn__ConfirmYN "Create remote git repository ${__GIT_CLIENT_REMOTE_REPO_NAME} if it does not exist? " && _CREATE_REMOTE_GIT_REPO_=${__YES} || _CREATE_REMOTE_GIT_REPO_=${__NO}
echo "______ Will $([[ ${__GIT_CLIENT_REMOTE_REPO_NAME} == ${__NO} ]] && echo "NOT ")create remote git repository ${__GIT_CLIENT_REMOTE_REPO_NAME}"


  # __GIT_CLIENT_CONTAINER_NAME=${lContainerName}
  # __GIT_CLIENT_HOST_NAME=${lContainerName}

fn__ConfirmYN "Create Windows Shortcuts?" && _CREATE_WINDOWS_SHORTCUTS_=${__YES} || _CREATE_WINDOWS_SHORTCUTS_=${__NO}
echo "______ Will $([[ ${_CREATE_WINDOWS_SHORTCUTS_} == ${__NO} ]] && echo "NOT ")create windows shortcuts"


fn__CreateDockerComposeFile \
  "${__GIT_CLIENT_CONTAINER_NAME}"  \
  "${__GIT_CLIENT_HOST_NAME}"  \
  "${__DEVCICD_NET}"  \
  "${__DEBMIN_SOURCE_IMAGE_NAME}"  \
  "${__DEBMIN_HOME_WSD}/${__GIT_CLIENT_CONTAINER_NAME}/backups:${__GIT_CLIENT_GUEST_HOME}/backups" \
  "${__DOCKER_COMPOSE_FILE_WLS}"
echo "______ Created ${__DOCKER_COMPOSE_FILE_WLS}"; 


fn__ImageExists \
  "${__DEBMIN_SOURCE_IMAGE_NAME}" \
  && echo "______ Image ${__DEBMIN_SOURCE_IMAGE_NAME} exist" \
  || {
    echo "repo: ${__DOCKER_REPOSITORY_HOST}/${__GIT_CLIENT_IMAGE_NAME}:${__GIT_CLIENT_IMAGE_VERSION}"
    fn__PullImageFromRemoteRepository   \
      ${__DOCKER_REPOSITORY_HOST}  \
      ${__GIT_CLIENT_IMAGE_NAME} \
      ${__GIT_CLIENT_IMAGE_VERSION} \
        && echo "______ Image ${__DOCKER_REPOSITORY_HOST}/${__GIT_CLIENT_IMAGE_NAME}:${__GIT_CLIENT_IMAGE_VERSION} pulled from remote docker repository" \
        || {
          echo "______ Cannot find image ${__DEBMIN_SOURCE_IMAGE_NAME} [${__DOCKER_REPOSITORY_HOST}/${__GIT_CLIENT_IMAGE_NAME}:${__GIT_CLIENT_IMAGE_VERSION}]" 
          echo "______ Aborting script execution ..." 
          exit
        }
  }


fn__ContainerExists \
  ${__GIT_CLIENT_CONTAINER_NAME} \
    && STS=${__YES} \
    || STS=${__NO}

if [[ $STS -eq ${__YES} ]]; then

  fn__ContainerIsRunning ${__GIT_CLIENT_CONTAINER_NAME} && STS=${__YES} || STS=${__NO}
  if [[ $STS -eq ${__YES} ]]; then
    echo "______ Container ${__GIT_CLIENT_CONTAINER_NAME} Exist and is running ... - nothing needs doing"; 
    exit

  else

    fn__StartContainer ${__GIT_CLIENT_CONTAINER_NAME} && STS=${__YES} || STS=${__NO}
    if [[ $STS -eq ${__DONE} ]]; then
        echo "______ Container ${__GIT_CLIENT_CONTAINER_NAME} started"; 
    else
        echo "______ Failed to start container ${__GIT_CLIENT_CONTAINER_NAME} - investigate..."; 
        exit
    fi
  fi

else
  
  fn_DockerComposeUpDetached "${__DOCKER_COMPOSE_FILE_DOS}" "${__GIT_CLIENT_CONTAINER_NAME}" && STS=${__DONE} || STS=${__FAILED}
  if [[ $STS -eq ${__DONE} ]]; then
    echo "______ Container ${__GIT_CLIENT_CONTAINER_NAME} started"; 
  else
    echo "______ Failed to start container ${__GIT_CLIENT_CONTAINER_NAME} - investigate"; 
    exit
  fi
fi


__GIT_CLIENT_ID_RSA_PUB_="a"
fn__GenerateSSHKeyPair \
  ${__GIT_CLIENT_CONTAINER_NAME} \
  ${__GIT_CLIENT_USERNAME} \
  ${__GIT_CLIENT_SHELL} \
  "__GIT_CLIENT_ID_RSA_PUB_" \
    && STS=${__DONE} \
    || STS=${__FAILED}
echo "______ Generated ${__GIT_CLIENT_GUEST_HOME}'s ssh keypair"; 


fn__IntroduceClientsToServerUsingClientsPublicKey \
  ${__GIT_CLIENT_CONTAINER_NAME} \
  ${__GIT_CLIENT_USERNAME} \
  "${__GIT_CLIENT_ID_RSA_PUB_}"  \
  ${__GITSERVER_CONTAINER_NAME} \
  ${__GIT_USERNAME} \
  ${__GITSERVER_SHELL} \
    && STS=${__DONE} \
    || STS=${__FAILED}
echo "______ Added ${__GIT_CLIENT_GUEST_HOME}'s public key to ${__GITSERVER_HOST_NAME}'s ~/.ssh/authorised_keys"; 


fn__AddGITServerToLocalKnown_hostsAndTestSshAccess \
  ${__GIT_CLIENT_CONTAINER_NAME} \
  ${__GIT_CLIENT_USERNAME} \
  ${__GIT_CLIENT_SHELL} \
    && STS=${__DONE} \
    || STS=${__FAILED}
echo "STS:${STS}"
echo "______ Added ${__GITSERVER_HOST_NAME} to ${__GIT_CLIENT_GUEST_HOME}'s \${HOME}/.ssh/known_hosts"; 


# client's public key must be in git server's authorised_keys file
#
fn__AddClientPublicKeyToServerAuthorisedKeysStore \
  "${lClientIdRSAPub}"  \
  ${__GITSERVER_CONTAINER_NAME} \
  ${__GIT_USERNAME} \
  ${__GITSERVER_SHELL} \
    && STS=${__DONE} \
    || STS=${__FAILED}





# if repo already exists we can't create a new one with the same name
#
fn__DoesRepoAlreadyExist \
  ${__GIT_CLIENT_REMOTE_REPO_NAME}  \
  ${__GITSERVER_CONTAINER_NAME} \
  ${__GIT_USERNAME} \
  ${__GITSERVER_SHELL} \
    && {
      echo "______ Git Repository ${__GIT_CLIENT_REMOTE_REPO_NAME} already exists - aborting"
      exit
    } \
    || STS=$? # can be __NO or __EXECUTION_ERROR

  [[ ${STS} -eq ${__EXECUTION_ERROR} ]] && {
      echo "______ Failed to determine whether Git Repository ${__GIT_CLIENT_REMOTE_REPO_NAME} already exists - aborting"
      exit 
  }

fn__CreateNewClientGitRepositoryOnRemote \
  ${__GIT_CLIENT_REMOTE_REPO_NAME}  \
  ${__GITSERVER_CONTAINER_NAME} \
  ${__GIT_USERNAME} \
  ${__GITSERVER_SHELL} \
  ${__GITSERVER_REPOS_ROOT} \
    && {
      echo "______ Created remote repository ${__GIT_CLIENT_REMOTE_REPO_NAME}"
    } \
    || {
      echo "______ Failed to create remote repository ${__GIT_CLIENT_REMOTE_REPO_NAME}"
    }





# fn__TestLocalAndRemoteGitReposOperation \
#   ${__GIT_CLIENT_CONTAINER_NAME} \
#   ${__GIT_CLIENT_USERNAME} \
#   ${__GIT_CLIENT_SHELL} \
#   ${__GIT_CLIENT_GUEST_HOME} \
#   ${__GITSERVER_HOST_NAME} \
#   ${__GIT_USERNAME} \
#   ${__GITSERVER_REPOS_ROOT} \
#   ${__GIT_CLIENT_REMOTE_REPO_NAME} \
#     && echo "______ Local and Remote Git repository test completed" \
#     || echo "______ Local and Remote Git repository test failed - investigate!!!"


[[ ${_CREATE_WINDOWS_SHORTCUTS_} -eq ${__YES} ]] && {
  fn__CreateWindowsShortcutsForShellInContainer \
    "${__GIT_CLIENT_CONTAINER_NAME}" \
    "${__DEBMIN_HOME_DOS}" \
    "${__GIT_CLIENT_SHELL}" \
    "${__DOCKER_COMPOSE_FILE_DOS}" && STS=${__DONE} || STS=${__FAILED}
  echo "______ Created Windows Shortcuts"; 
}


echo "______ ${0} Done"
