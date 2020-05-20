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
[[ ${fn__SSHInContainerUtils} ]] || source ./utils/fn__SSHInContainerUtils.sh

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
    exit ${__FAILED}
  }

declare lProjectName="${__DEBMIN_HOME}/${__SCRIPTS_DIRECTORY_NAME}"
fn__GetProjectName \
  "lProjectName" || {
    echo "${0}:${LINENO} must run from directory with name _commonUtils and will use the name of its parent directory as project directory."
    exit ${__FAILED}
  }

# fn__SetEnvironmentVariables \
#   "${__DEBMIN_HOME}" \
#   "${__GIT_CLIENT_USERNAME}" \
#   "${__GIT_CLIENT_IMAGE_NAME}:${__GIT_CLIENT_IMAGE_VERSION}" ## && STS=${__SUCCESS} || STS=${__FAILED} # let it fail 
# echo "____ Set local environment variables"; 

:<<-'COMMENT--fn__SetEnvironmentVariables-----------------------------------------'
  Usage:
    fn__SetEnvironmentVariables
      "${__DEBMIN_HOME}" \
      "${__GIT_CLIENT_IMAGE_NAME}:${__GIT_CLIENT_IMAGE_VERSION}"
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
    ${__NO_SUCH_DIRECTORY}
Rework fn__SetEnvironmentVariables tests and main 02 use thereof
COMMENT--fn__SetEnvironmentVariables-----------------------------------------

fn__SetEnvironmentVariables \
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
  "__GIT_CLIENT_REMOTE_REPO_NAME" && STS=$? || STS=$?

case ${STS} in
  ${__SUCCESS})
    ;;
  ${__INSUFFICIENT_ARGS_STS})
    echo "${__INSUFFICIENT_ARGS}"
    echo "____ ${LINENO}: Aborting ..."
    exit ${STS}
    ;;
  ${__EMPTY_ARGUMENT_NOT_ALLOWED})
    echo "_error Empty arguments not allowed"
    echo "____ ${LINENO}: Aborting ..."
    exit ${STS}
    ;;
  ${__INVALID_VALUE})
    echo "_error Argument has invalid value"
    echo "____ ${LINENO}: Aborting ..."
    exit ${STS}
    ;;
  ${__NO_SUCH_DIRECTORY})
    echo "_error script not running from '${__SCRIPTS_DIRECTORY_NAME}'"
    echo "____ ${LINENO}: Aborting ..."
    exit ${STS}
    ;;
esac
echo "____ Set environment variables"; 


fn__ConfirmYN "Project Directory is ${__DEBMIN_HOME}, Project Name is '${lProjectName}' - Is this correct?" && true || {
  echo -e "____ Aborting ...\n"
  exit ${__FAILED}
}


cd ${__DEBMIN_HOME}


declare -i _PROMPTS_TIMEOUT_SECS_=30

fn__GetClientContainerName  \
  "__DEBMIN_HOME" \
  "__GIT_CLIENT_CONTAINER_NAME" && STS=$? || STS=$?
if [[ ${STS} -ne ${__SUCCESS} ]]
then
  echo "____ Failed to choose container name."
  echo "____ Aborting ..."
  exit ${__FAILED}
fi
echo "____ Using '${__GIT_CLIENT_CONTAINER_NAME}' as Container Name and Host Name"

__GIT_CLIENT_HOST_NAME=${__GIT_CLIENT_CONTAINER_NAME}



## ask if user wants to create a repo
## if yes, ask for name offering default and an opportunity to change
## if not - set the flag to no do it
#
fn__ConfirmYN "Create remote git repository if it does not exist? " && _CREATE_REMOTE_GIT_REPO_=${__YES} || _CREATE_REMOTE_GIT_REPO_=${__NO}
if [[ ${_CREATE_REMOTE_GIT_REPO_} -eq ${__YES} ]]
then
  fn__GetRemoteGitRepoName \
    ${__GIT_CLIENT_REMOTE_REPO_NAME}  \
    "__GIT_CLIENT_REMOTE_REPO_NAME" && STS=$? || STS=$?
  if [[ ${STS} -eq ${__SUCCESS} ]]
  then
    echo "____ Will use '${__GIT_CLIENT_REMOTE_REPO_NAME}' as the name of the remote git repository which to create"
  else
    _CREATE_REMOTE_GIT_REPO_=${__NO}
    echo "____ Will not create remote git repository"
  fi
fi


fn__ConfirmYN "Create Windows Shortcuts?" && _CREATE_WINDOWS_SHORTCUTS_=${__YES} || _CREATE_WINDOWS_SHORTCUTS_=${__NO}
echo "____ Will $([[ ${_CREATE_WINDOWS_SHORTCUTS_} == ${__NO} ]] && echo "NOT ")create windows shortcuts"


fn__CreateDockerComposeFile \
  "${__GIT_CLIENT_CONTAINER_NAME}"  \
  "${__GIT_CLIENT_HOST_NAME}"  \
  "${__DEVCICD_NET}"  \
  "${__CONTAINER_SOURCE_IMAGE_NAME}"  \
  "${__DEBMIN_HOME_WSD}/${__GIT_CLIENT_CONTAINER_NAME}/backups:${__GIT_CLIENT_GUEST_HOME}/backups" \
  "${__DOCKER_COMPOSE_FILE_WLS}"
echo "____ Created ${__DOCKER_COMPOSE_FILE_WLS}"; 


fn__ImageExists \
  "${__CONTAINER_SOURCE_IMAGE_NAME}" \
  && echo "____ Image ${__CONTAINER_SOURCE_IMAGE_NAME} exist" \
  || {
    echo "repo: ${__DOCKER_REPOSITORY_HOST}/${__GIT_CLIENT_IMAGE_NAME}:${__GIT_CLIENT_IMAGE_VERSION}"
    fn__PullImageFromRemoteRepository   \
      ${__DOCKER_REPOSITORY_HOST}  \
      ${__GIT_CLIENT_IMAGE_NAME} \
      ${__GIT_CLIENT_IMAGE_VERSION} \
        && echo "____ Image ${__DOCKER_REPOSITORY_HOST}/${__GIT_CLIENT_IMAGE_NAME}:${__GIT_CLIENT_IMAGE_VERSION} pulled from remote docker repository" \
        || {
          echo "____ Cannot find image ${__CONTAINER_SOURCE_IMAGE_NAME} [${__DOCKER_REPOSITORY_HOST}/${__GIT_CLIENT_IMAGE_NAME}:${__GIT_CLIENT_IMAGE_VERSION}]" 
          echo "____ Aborting script execution ..." 
          exit ${__FAILED}
        }
  }


fn__ContainerExists \
  ${__GIT_CLIENT_CONTAINER_NAME} \
    && STS=${__YES} \
    || STS=${__NO}

if [[ $STS -eq ${__YES} ]]; then

  fn__ContainerIsRunning ${__GIT_CLIENT_CONTAINER_NAME} && STS=${__YES} || STS=${__NO}
  if [[ $STS -eq ${__YES} ]]; then
    echo "____ Container '${__GIT_CLIENT_CONTAINER_NAME}' exist and is running - nothing needs doing - exiting"; 
    exit ${__SUCCESS}

  else

    fn__StartContainer ${__GIT_CLIENT_CONTAINER_NAME} && STS=${__YES} || STS=${__NO}
    if [[ $STS -eq ${__DONE} ]]; then
        echo "____ Container ${__GIT_CLIENT_CONTAINER_NAME} started"; 
    else
        echo "____ Failed to start container ${__GIT_CLIENT_CONTAINER_NAME} - investigate..."; 
        exit ${__FAILED}
    fi
  fi

else
  
  fn_DockerComposeUpDetached "${__DOCKER_COMPOSE_FILE_DOS}" "${__GIT_CLIENT_CONTAINER_NAME}" && STS=${__DONE} || STS=${__FAILED}
  if [[ $STS -eq ${__DONE} ]]; then
    echo "____ Container ${__GIT_CLIENT_CONTAINER_NAME} started"; 
  else
    echo "____ Failed to start container ${__GIT_CLIENT_CONTAINER_NAME} - investigate"; 
    exit ${__FAILED}
  fi
fi


declare __GIT_CLIENT_ID_RSA_PUB_=""
fn__GenerateSSHKeyPairInClientContainer \
  ${__GIT_CLIENT_CONTAINER_NAME} \
  ${__GIT_CLIENT_USERNAME} \
  ${__GIT_CLIENT_SHELL} \
  "__GIT_CLIENT_ID_RSA_PUB_" \
    && STS=${__DONE} \
    || STS=${__FAILED}
echo "____ Generated ${__GIT_CLIENT_GUEST_HOME}'s ssh keypair"; 


fn__IntroduceRemoteClientToServerWithPublicKey \
  ${__GIT_CLIENT_CONTAINER_NAME} \
  ${__GIT_CLIENT_USERNAME} \
  "${__GIT_CLIENT_ID_RSA_PUB_}"  \
  ${__GITSERVER_CONTAINER_NAME} \
  ${__GIT_USERNAME} \
  ${__GITSERVER_SHELL} \
    && STS=${__DONE} \
    || STS=${__FAILED}
echo "____ Added '${__GIT_CLIENT_GUEST_HOME}' public key to '${__GITSERVER_HOST_NAME}' ~/.ssh/authorised_keys"; 


fn__AddGITServerToLocalKnown_hostsAndTestSshAccess \
  ${__GIT_CLIENT_CONTAINER_NAME} \
  ${__GIT_CLIENT_USERNAME} \
  ${__GIT_CLIENT_SHELL} \
    && STS=${__DONE} \
    || STS=${__FAILED}
echo "____ Added '${__GITSERVER_HOST_NAME}' to '${__GIT_CLIENT_GUEST_HOME}' \${HOME}/.ssh/known_hosts"; 


# client's public key must be in git server's authorised_keys file
#
fn__AddClientPublicKeyToServerAuthorisedKeysStore \
  "${__GIT_CLIENT_ID_RSA_PUB_}"  \
  ${__GITSERVER_CONTAINER_NAME} \
  ${__GIT_USERNAME} \
  ${__GITSERVER_SHELL} \
    && STS=${__DONE} \
    || STS=${__FAILED}
echo "____ Added '${__GIT_CLIENT_CONTAINER_NAME}' to '${__GIT_CLIENT_GUEST_HOME}' \${HOME}/.ssh/known_hosts"; 


# if repo already exists we can't create a new one with the same name
#
fn__DoesRepoAlreadyExist \
  ${__GIT_CLIENT_REMOTE_REPO_NAME}  \
  ${__GITSERVER_CONTAINER_NAME} \
  ${__GIT_USERNAME} \
  ${__GITSERVER_SHELL} && STS=$? || STS=$?

  if [[ ${STS} -eq ${__YES} ]]
  then
    echo "____ Git Repository ${__GIT_CLIENT_REMOTE_REPO_NAME} already exists - will skip creation steps"
  elif [[ ${STS} -eq ${__EXECUTION_ERROR} ]]
  then
    echo "____ Failed to determine whether Git Repository ${__GIT_CLIENT_REMOTE_REPO_NAME} already exists - will skip creation steps"
  else
    fn__CreateNewClientGitRepositoryOnRemote \
      ${__GIT_CLIENT_REMOTE_REPO_NAME}  \
      ${__GITSERVER_CONTAINER_NAME} \
      ${__GIT_USERNAME} \
      ${__GITSERVER_SHELL} \
      ${__GITSERVER_REPOS_ROOT} && STS=$? || STS=$?

    if [[ ${STS} -eq ${__DONE} ]]
    then
      fn__DoesRepoAlreadyExist \
        ${__GIT_CLIENT_REMOTE_REPO_NAME}  \
        ${__GITSERVER_CONTAINER_NAME} \
        ${__GIT_USERNAME} \
        ${__GITSERVER_SHELL} && STS=$? || STS=$?

      if [[ ${STS} -eq ${__YES} ]]
      then
        echo "____ Created remote repository ${__GIT_CLIENT_REMOTE_REPO_NAME}"
      else
        echo "____ Failed to create remote repository ${__GIT_CLIENT_REMOTE_REPO_NAME} - investigate"
      fi
    else
      echo "____ Failed to create remote repository ${__GIT_CLIENT_REMOTE_REPO_NAME}"
    fi
  fi

# fn__TestLocalAndRemoteGitReposOperation \
#   ${__GIT_CLIENT_CONTAINER_NAME} \
#   ${__GIT_CLIENT_USERNAME} \
#   ${__GIT_CLIENT_SHELL} \
#   ${__GIT_CLIENT_GUEST_HOME} \
#   ${__GITSERVER_HOST_NAME} \
#   ${__GIT_USERNAME} \
#   ${__GITSERVER_REPOS_ROOT} \
#   ${__GIT_CLIENT_REMOTE_REPO_NAME} \
#     && echo "____ Local and Remote Git repository test completed" \
#     || echo "____ Local and Remote Git repository test failed - investigate!!!"


[[ ${_CREATE_WINDOWS_SHORTCUTS_} -eq ${__YES} ]] && {
  fn__CreateWindowsShortcutsForShellInContainer \
    "${__GIT_CLIENT_CONTAINER_NAME}" \
    "${__DEBMIN_HOME_DOS}" \
    "${__GIT_CLIENT_SHELL}" \
    "${__DOCKER_COMPOSE_FILE_DOS}" && STS=${__DONE} || STS=${__FAILED}
  echo "____ Created Windows Shortcuts"; 
}


echo "____ ${0} Done"
