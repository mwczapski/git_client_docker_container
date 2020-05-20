#!/bin/bash
# #############################################
# The MIT License (MIT)
#
# Copyright © 2020 Michael Czapski
# #############################################


declare -u _01_create_git_client_baseline_image_tests="SOURCED"
echo "INFO 01_create_git_client_baseline_image_tests"


[[ ${bash_test_utils} ]] || source ./bash_test_utils/bash_test_utils.sh

[[ ${__env_GlobalConstants} ]] || source ./utils/__env_GlobalConstants.sh
[[ ${fn__UtilityGeneric} ]] || source ./utils/fn__UtilityGeneric.sh

[[ ${_01_create_git_client_baseline_image_utils} ]] || source ./01_create_git_client_baseline_image_utils.sh


declare -i iSuccessResults=0
declare -i iFailureResults=0

declare functionName
declare functionInputs
declare expectedStringResult
declare expectedStatusResult
declare expectedContentSameResult
declare actualStringResult
declare actualStatusResult
declare actualContentSameResult

declare -r gTS=$(date +%s)

declare -r _TEMP_DIR_=/tmp/tests_${gTS}

declare -i _RUN_TEST_SET_=${__NO}


## ################################################################
## create expected files 
## ################################################################
mkdir -p ${_TEMP_DIR_}

declare -r _DOCKER_ENTRYPOINT_ACTUAL_=${_TEMP_DIR_}/docker-entrypoint.sh
declare -r _DOCKER_ENTRYPOINT_EXPECTED_=${_TEMP_DIR_}/docker-entrypoint.sh.expected
cat <<-'EOF' > ${_DOCKER_ENTRYPOINT_EXPECTED_}
#!/bin/bash
set -e

# prevent container from exiting after successfull startup
# exec /bin/bash -c 'while true; do sleep 100000; done'
exec /bin/bash $@
EOF


declare -r _DOCKERFILE_ACTUAL_=${_TEMP_DIR_}/Dockerfile
declare -r _DOCKERFILE_EXPECTED_=${_TEMP_DIR_}/Dockerfile.expected
cat <<-'EOF' > ${_DOCKERFILE_EXPECTED_}
FROM bitnami/minideb:jessie

## Dockerfile Version: 20200510_105549
##
# the environment variables below will be used in creating the image
# and will be available to the containers created from the image ...
#
ENV DEBMIN_USERNAME=gitclient \
    DEBMIN_SHELL=/bin/bash \
    DEBMIN_SHELL_PROFILE=.bash_profile \
    DEBMIN_GUEST_HOME=/home/gitclient \
    GITSERVER_REPOS_ROOT=/opt/gitrepos \
    TZ_PATH=Australia/Sydney \
    TZ_NAME=Australia/Sydney  \
    ENV=/etc/profile  \
    DEBIAN_FRONTEND=noninteractive

COPY ./docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

# install necessary / usefull extra packages
# the following are needed to download, builld and install git from sources
# wget, unzip, build-essential, libssl-dev, libcurl4-openssl-dev, libexpat1-dev, gettex
#
RUN export DEBIAN_FRONTEND=noninteractive && \
  apt-get update && \
  apt-get upgrade -y && \
  apt-get -y install apt-utils && \
  apt-get -y install \
    tzdata \
    net-tools \
    iputils-ping \
    openssh-client \
    nano \
    less \
    git && \
\
    git --version && \
\
# set timezone - I live in Sydney - change as you see fit in the env variables above
    cp -v /usr/share/zoneinfo/${TZ_PATH} /etc/localtime && \
    echo "${TZ_NAME}" > /etc/timezone && \
    echo $(date) && \
\
# create non-root user
    addgroup developers && \
    useradd -G developers -m ${DEBMIN_USERNAME} -s ${DEBMIN_SHELL} -p ${DEBMIN_USERNAME} && \
\
# configure ssh client directory
    mkdir -pv ${DEBMIN_GUEST_HOME}/.ssh && \
    chown -Rv ${DEBMIN_USERNAME}:${DEBMIN_USERNAME} ${DEBMIN_GUEST_HOME}/.ssh
EOF


## ############################################################################
## define tests
## ############################################################################


functionName="fn__Create_docker_entry_point_file"
:<<-'------------Function_Usage_Note-------------------------------'
  Usage: 
      fn__Create_docker_entry_point_file \
        ${__DEBMIN_HOME}      - Full path to the directory to which to write the file.
        ${__GIT_CLIENT_SHELL} - Full path to guest shell binary, for example /bin/bash or /bin/ash or /bin/sh.
  Returns:
    __DONE / __SUCCESS
    __FAILED
------------Function_Usage_Note-------------------------------
_RUN_TEST_SET_=${__NO}
if [[ ${_RUN_TEST_SET_} -eq ${__YES} || ${_FORCE_RUNNING_ALL_TESTS_} ]]
then

  function fn__Create_docker_entry_point_file_test_001() {
    testIntent="${functionName} function will return __FAILURE status, insufficient number of arguments and Usage message"
    functionInputs=""
    expectedStringResult="${__INSUFFICIENT_ARGS}"
    expectedStatusResult=${__FAILED}
    actualStringResult=$( ${functionName} ${functionInputs} ) && actualStatusResult=$? || actualStatusResult=$? 
    # [[ ${actualStringResult} ]] && echo "________ ${LINENO}: ${functionName}: ${actualStringResult}" 

    assessReturnStatusAndStdOut \
      "${functionName}" \
      ${LINENO} \
      "${testIntent}" \
      "${expectedStringResult}" \
      ${expectedStatusResult} \
      "${actualStringResult}" \
      ${actualStatusResult} && { ((iSuccessResults++)); true ; } || { ((iFailureResults++)); true ; }
  }
  fn__Create_docker_entry_point_file_test_001


  function fn__Create_docker_entry_point_file_test_002() {
    testIntent="${functionName} function will return __FAILURE status, insufficient number of arguments and Usage message"
    functionInputs="${_TEMP_DIR_}"
    expectedStringResult="${__INSUFFICIENT_ARGS}"
    expectedStatusResult=${__FAILED}
    actualStringResult=$( ${functionName} ${functionInputs} ) && actualStatusResult=$? || actualStatusResult=$? 
    # [[ ${actualStringResult} ]] && echo "________ ${LINENO}: ${functionName}: ${actualStringResult}" 

    assessReturnStatusAndStdOut \
      "${functionName}" \
      ${LINENO} \
      "${testIntent}" \
      "${expectedStringResult}" \
      ${expectedStatusResult} \
      "${actualStringResult}" \
      ${actualStatusResult} && { ((iSuccessResults++)); true ; } || { ((iFailureResults++)); true ; }
  }
  fn__Create_docker_entry_point_file_test_002


  function fn__Create_docker_entry_point_file_test_003() {

    function fn__TestFunctionExecution() {
      testIntent="${functionName} function will return __SUCCESS status and will write docker-entrypoint.sh in the designated directory whose content is identical to the expected content"
      functionInputs="${_TEMP_DIR_} /bin/bash"
      expectedStringResult=""
      expectedStatusResult=${__SUCCESS}
      expectedContentSameResult=${__NO}
      actualStringResult=$( ${functionName} ${functionInputs} ) && actualStatusResult=$? || actualStatusResult=$? 
      [[ ${actualStringResult} ]] && echo "________ ${LINENO}: ${functionName}: ${actualStringResult}" 
      actualStringResult=${actualStringResult:0:${#expectedStringResult}}

      assessReturnStatusAndStdOut \
        "${functionName}" \
        ${LINENO} \
        "${testIntent}" \
        "${expectedStringResult}" \
        ${expectedStatusResult} \
        "${actualStringResult}" \
        ${actualStatusResult} && { ((iSuccessResults++)); true ; } || { ((iFailureResults++)); true ; }
    }
    fn__TestFunctionExecution


    testIntent="${functionName}/fn__TestFunctionOutput will return __SUCCESS completion code"
    function fn__TestFunctionOutput() {
      expectedStringResult=""
      expectedStatusResult=${__THE_SAME}

      local -r lExpectedFileName=${_DOCKER_ENTRYPOINT_EXPECTED_}
      local -r lActualFileName=${_DOCKER_ENTRYPOINT_ACTUAL_}

      fn__FileSameButForDate ${lExpectedFileName} ${lActualFileName} && actualStatusResult=$? || actualStatusResult=$?
      actualStringResult=""

      assessReturnStatusAndStdOut \
        "${functionName}" \
        ${LINENO} \
        "${testIntent}" \
        "${expectedStringResult}" \
        ${expectedStatusResult} \
        "${actualStringResult}" \
        ${actualStatusResult} && { ((iSuccessResults++)); true ; } || { ((iFailureResults++)); true ; }

    }
    fn__TestFunctionOutput

  }
  fn__Create_docker_entry_point_file_test_003

else 
  echo "Not running test for ${functionName}"
fi



functionName="fn__CreateDockerfile"
:<<-'------------Function_Usage_Note-------------------------------'
  Usage:
    fn__CreateDockerfile
      ${__DOCKERFILE_PATH}
      ${__DEBMIN_SOURCE_IMAGE_NAME}
      ${__GIT_CLIENT_USERNAME}
      ${__GIT_CLIENT_SHELL}
      ${__GIT_CLIENT_SHELL_PROFILE}
      ${__GIT_CLIENT_SHELL_GLOBAL_PROFILE}
      ${__GIT_CLIENT_GUEST_HOME}
      ${__GITSERVER_REPOS_ROOT} 
      ${__TZ_PATH}
      ${__TZ_NAME}
    returns ${__FAILED} OR ${__NEEDS_REBUILDING} => ${__YES}/${__NO}
------------Function_Usage_Note-------------------------------
_RUN_TEST_SET_=${__NO}
if [[ ${_RUN_TEST_SET_} -eq ${__YES} || ${_FORCE_RUNNING_ALL_TESTS_} ]]
then

  testIntent="${functionName} function will return __FAILURE status, insufficient number of arguments and Usage message"
  function fn__CreateDockerfile_test_001() {
    functionInputs=""
    expectedStringResult="${__INSUFFICIENT_ARGS}"
    expectedStatusResult=${__FAILED}
    actualStringResult=$( ${functionName} ${functionInputs} ) && actualStatusResult=$? || actualStatusResult=$? 
    actualStringResult=${actualStringResult:0:${#expectedStringResult}}
    # [[ ${actualStringResult} ]] && echo "________ ${LINENO}: ${functionName}: ${actualStringResult}" 

    assessReturnStatusAndStdOut \
      "${functionName}" \
      ${LINENO} \
      "${testIntent}" \
      "${expectedStringResult}" \
      ${expectedStatusResult} \
      "${actualStringResult}" \
      ${actualStatusResult} && { ((iSuccessResults++)); true ; } || { ((iFailureResults++)); true ; }
  }
  fn__CreateDockerfile_test_001


  function fn__CreateDockerfile_test_002() {

    testIntent="${functionName}/fn__TestFunctionExecution function will return __FAILURE status"
    function fn__TestFunctionExecution() {
      functionInputs="${_DOCKERFILE_ACTUAL_} img:1.0.0 gitx /bin/bashx .bashx_profile profilex /tmpx /opt/gitreposx Canada/Sydney Canada/Sydney"
      expectedStringResult=""
      expectedStatusResult=${__FAILED}
      expectedContentSameResult=${__NO}
      actualStringResult=$( ${functionName} ${functionInputs} ) && actualStatusResult=$? || actualStatusResult=$? 

      assessReturnStatusAndStdOut \
        "${functionName}" \
        ${LINENO} \
        "${testIntent}" \
        "${expectedStringResult}" \
        ${expectedStatusResult} \
        "${actualStringResult}" \
        ${actualStatusResult} && { ((iSuccessResults++)); true ; } || { ((iFailureResults++)); true ; }
    }
    fn__TestFunctionExecution
  }
  fn__CreateDockerfile_test_002


  function fn__CreateDockerfile_test_003() {

    testIntent="${functionName}/fn__TestFunctionExecution will return status of 1, file was created and image may need rebuilding"
    function fn__TestFunctionExecution() {
      functionInputs="${_DOCKERFILE_ACTUAL_} bitnami/minideb:jessie gitclient /bin/bash .bash_profile /etc/profile /home/gitclient /opt/gitrepos Australia/Sydney Australia/Sydney"
      expectedStringResult=""
      expectedStatusResult=${__SUCCESS}
      ${functionName} ${functionInputs} && actualStatusResult=$? || actualStatusResult=$? 

      actualStatusResult=${__SUCCESS}
      assessReturnStatusAndStdOut \
        "${functionName}" \
        ${LINENO} \
        "${testIntent}" \
        "${expectedStringResult}" \
        ${expectedStatusResult} \
        "${actualStringResult}" \
        ${actualStatusResult} && { ((iSuccessResults++)); true ; } || { ((iFailureResults++)); true ; }
    }
    fn__TestFunctionExecution


    testIntent="${functionName}/fn__TestFunctionOutput __THE_SAME status, and a filure to match expected content"
    function fn__TestFunctionOutput() {
      expectedStringResult=""
      expectedStatusResult=${__THE_SAME}

      local -r lExpectedFileName=${_DOCKERFILE_EXPECTED_}
      local -r lActualFileName=${_DOCKERFILE_ACTUAL_}

      fn__FileSameButForDate ${lExpectedFileName} ${lActualFileName} && actualStatusResult=$? || actualStatusResult=$?
      actualStringResult=""

      assessReturnStatusAndStdOut \
        "${functionName}" \
        ${LINENO} \
        "${testIntent}" \
        "${expectedStringResult}" \
        ${expectedStatusResult} \
        "${actualStringResult}" \
        ${actualStatusResult} && { ((iSuccessResults++)); true ; } || { ((iFailureResults++)); true ; }

    }
    fn__TestFunctionOutput
  }
  fn__CreateDockerfile_test_003


else 
  echo "Not running test for ${functionName}"
fi


functionName="fn__SetEnvironmentVariables"
:<<-'------------Function_Usage_Note-------------------------------'
  Usage: 
    fn__SetEnvironmentVariables \
      "${__SCRIPTS_DIRECTORY_NAME}" \
      "${__GITSERVER_IMAGE_NAME}"  \
      "${__GITSERVER_SHELL_GLOBAL_PROFILE}"  \
      "__DEBMIN_HOME"  \
      "__DEBMIN_HOME_DOS"  \
      "__DEBMIN_HOME_WSD" \
      "__DEBMIN_SOURCE_IMAGE_NAME"  \
      "__TZ_PATH"  \
      "__TZ_NAME"  \
      "__ENV"  \
      "__DOCKERFILE_PATH"  \
      "__REMOVE_CONTAINER_ON_STOP"  \
      "__NEEDS_REBUILDING"  \
  Returns:
    ${__SUCCESS}
    ${__FAILED} and error string on stdout
  Expects in environment:
    Constants from __env_GlobalConstants
------------Function_Usage_Note-------------------------------

_RUN_TEST_SET_=${__YES}
if [[ ${_RUN_TEST_SET_} -eq ${__YES} || ${_FORCE_RUNNING_ALL_TESTS_} ]]
then

  testIntent="${functionName} will return __FAILED and '______ Insufficient number of arguments'"
  function fn__SetEnvironmentVariables_test_001 {

    expectedStringResult="____ Insufficient number of arguments"
    expectedStatusResult=${__FAILED}

    actualStringResult=$( ${functionName} "" "" "" ) && actualStatusResult=$? || actualStatusResult=$?
    # [[ ${actualStringResult} ]] && echo "____ ${LINENO}: ${functionName}: ${actualStringResult}" 

    assessReturnStatusAndStdOut \
      "${functionName}" \
      ${LINENO} \
      "${testIntent}" \
      "${expectedStringResult}" \
      ${expectedStatusResult} \
      "${actualStringResult}" \
      ${actualStatusResult} && { ((iSuccessResults++)); true ; } || { ((iFailureResults++)); true ; }
  }
  fn__SetEnvironmentVariables_test_001


  testIntent="${functionName} will return __FAILED and '1st Argument value, '', is invalid'"
  function fn__SetEnvironmentVariables_test_002 {
    local -r lrScriptDirectoryName=${__SCRIPTS_DIRECTORY_NAME}
    local -r lrGotserverImageName="${__GITSERVER_IMAGE_NAME}"
    local -r lrGitserverShellGlobalProfile="${__GITSERVER_SHELL_GLOBAL_PROFILE}"
    

    expectedStringResult="1st Argument value, '', is invalid"
    expectedStatusResult=${__FAILED}

    actualStringResult=$( ${functionName} "" "" "" "" "" "" "" "" "" ) && actualStatusResult=$? || actualStatusResult=$?
    # [[ ${actualStringResult} ]] && echo "____ ${LINENO}: ${functionName}: ${actualStringResult}" 

    assessReturnStatusAndStdOut \
      "${functionName}" \
      ${LINENO} \
      "${testIntent}" \
      "${expectedStringResult}" \
      ${expectedStatusResult} \
      "${actualStringResult}" \
      ${actualStatusResult} && { ((iSuccessResults++)); true ; } || { ((iFailureResults++)); true ; }
  }
  fn__SetEnvironmentVariables_test_002


  testIntent="${functionName} will return __FAILED and 2nd Argument value, '', is invalid"
  function fn__SetEnvironmentVariables_test_003 {
    local -r lrScriptDirectoryName="${__SCRIPTS_DIRECTORY_NAME}"
    local -r lrGotserverImageName="${__GITSERVER_IMAGE_NAME}"
    local -r lrGitserverShellGlobalProfile="${__GITSERVER_SHELL_GLOBAL_PROFILE}"
    

    expectedStringResult="2nd Argument value, '', is invalid"
    expectedStatusResult=${__FAILED}

    actualStringResult=$( ${functionName} "${lrScriptDirectoryName}" "" "" "" "" "" "" "" "") && actualStatusResult=$? || actualStatusResult=$?
    # [[ ${actualStringResult} ]] && echo "____ ${LINENO}: ${functionName}: ${actualStringResult}" 

    assessReturnStatusAndStdOut \
      "${functionName}" \
      ${LINENO} \
      "${testIntent}" \
      "${expectedStringResult}" \
      ${expectedStatusResult} \
      "${actualStringResult}" \
      ${actualStatusResult} && { ((iSuccessResults++)); true ; } || { ((iFailureResults++)); true ; }
  }
  fn__SetEnvironmentVariables_test_003


  testIntent="${functionName} will return __FAILED and 3rd Argument value, '', is invalid"
  function fn__SetEnvironmentVariables_test_004 {
    local -r lrScriptDirectoryName="${__SCRIPTS_DIRECTORY_NAME}"
    local -r lrGitserverImageName="${__GITSERVER_IMAGE_NAME}"
    local -r lrGitserverShellGlobalProfile="${__GITSERVER_SHELL_GLOBAL_PROFILE}"
    

    expectedStringResult="3rd Argument value, '', is invalid"
    expectedStatusResult=${__FAILED}

    actualStringResult=$( ${functionName} "${lrScriptDirectoryName}" "${lrGitserverImageName}" "" "" "" "" "" "" "" "" "" "" ) && actualStatusResult=$? || actualStatusResult=$?
    # [[ ${actualStringResult} ]] && echo "____ ${LINENO}: ${functionName}: ${actualStringResult}" 

    assessReturnStatusAndStdOut \
      "${functionName}" \
      ${LINENO} \
      "${testIntent}" \
      "${expectedStringResult}" \
      ${expectedStatusResult} \
      "${actualStringResult}" \
      ${actualStatusResult} && { ((iSuccessResults++)); true ; } || { ((iFailureResults++)); true ; }
  }
  fn__SetEnvironmentVariables_test_004


  testIntent="${functionName} will return __FAILED and '4th Argument, 'lDebminHome', is not declared'"
  function fn__SetEnvironmentVariables_test_005 {
    local -r lrScriptDirectoryName="${__SCRIPTS_DIRECTORY_NAME}"
    local -r lrGitserverImageName="${__GITSERVER_IMAGE_NAME}"
    local -r lrGitserverShellGlobalProfile="${__GITSERVER_SHELL_GLOBAL_PROFILE}"
    # local lDebminHome="/mnt/d/gitserver/gitserver/_commonUtils"
    # local lDebminHome=""
    local lDebminHomeDOS=""
    local lDebminHomeWSD=""
    local lDockerfilePath=""
    local lRemoveContainerOnStop=""
    local lNeedsRebuilding=""
    

    expectedStringResult="4th Argument, 'lDebminHome', must have a valid value"
    expectedStatusResult=${__FAILED}

    actualStringResult=$( ${functionName} \
                              "${lrScriptDirectoryName}" \
                              "${lrGitserverImageName}" \
                              "${lrGitserverShellGlobalProfile}" \
                              "lDebminHome" \
                              "lDebminHomeDOS" \
                              "lDebminHomeWSD" \
                              "lDockerfilePath" \
                              "lRemoveContainerOnStop" \
                              "lNeedsRebuilding" ) && actualStatusResult=$? || actualStatusResult=$?
    # [[ ${actualStringResult} ]] && echo "____ ${LINENO}: ${functionName}: ${actualStringResult}" 

    assessReturnStatusAndStdOut \
      "${functionName}" \
      ${LINENO} \
      "${testIntent}" \
      "${expectedStringResult}" \
      ${expectedStatusResult} \
      "${actualStringResult}" \
      ${actualStatusResult} && { ((iSuccessResults++)); true ; } || { ((iFailureResults++)); true ; }
  }
  fn__SetEnvironmentVariables_test_005


  testIntent="${functionName} will return __FAILED and '4th Argument, 'lDebminHome', must have a valid value'"
  function fn__SetEnvironmentVariables_test_006 {
    local -r lrScriptDirectoryName="${__SCRIPTS_DIRECTORY_NAME}"
    local -r lrGitserverImageName="${__GITSERVER_IMAGE_NAME}"
    local -r lrGitserverShellGlobalProfile="${__GITSERVER_SHELL_GLOBAL_PROFILE}"
    # local lDebminHome="/mnt/d/gitserver/gitserver/_commonUtils"
    local lDebminHome=""
    local lDebminHomeDOS=""
    local lDebminHomeWSD=""
    local lDockerfilePath=""
    local lRemoveContainerOnStop=""
    local lNeedsRebuilding=""
    

    expectedStringResult="4th Argument, 'lDebminHome', must have a valid value"
    expectedStatusResult=${__FAILED}

    actualStringResult=$( ${functionName} \
                              "${lrScriptDirectoryName}" \
                              "${lrGitserverImageName}" \
                              "${lrGitserverShellGlobalProfile}" \
                              "lDebminHome" \
                              "lDebminHomeDOS" \
                              "lDebminHomeWSD" \
                              "lDockerfilePath" \
                              "lRemoveContainerOnStop" \
                              "lNeedsRebuilding" ) && actualStatusResult=$? || actualStatusResult=$?
    # [[ ${actualStringResult} ]] && echo "____ ${LINENO}: ${functionName}: ${actualStringResult}" 

    assessReturnStatusAndStdOut \
      "${functionName}" \
      ${LINENO} \
      "${testIntent}" \
      "${expectedStringResult}" \
      ${expectedStatusResult} \
      "${actualStringResult}" \
      ${actualStatusResult} && { ((iSuccessResults++)); true ; } || { ((iFailureResults++)); true ; }
  }
  fn__SetEnvironmentVariables_test_006


  function fn__SetEnvironmentVariables_test_007 {
    local -r lrScriptDirectoryName="${__SCRIPTS_DIRECTORY_NAME}"
    local -r lrGitserverImageName="${__GITSERVER_IMAGE_NAME}"
    local -r lrGitserverShellGlobalProfile="${__GITSERVER_SHELL_GLOBAL_PROFILE}"
    local lDebminHome="/mnt/d/gitserver/gitserver/_commonUtils"
    local lDebminHomeDOS=""
    local lDebminHomeWSD=""
    local lDockerfilePath=""
    local lRemoveContainerOnStop=""
    local lNeedsRebuilding=""
    
    testIntent="${functionName} will return __SUCCESS and set the values of the reference variables"
    fn__testInputAndExecution() {
      expectedStringResult=""
      expectedStatusResult=${__SUCCESS}

      ${functionName} \
        "${lrScriptDirectoryName}" \
        "${lrGitserverImageName}" \
        "${lrGitserverShellGlobalProfile}" \
        "lDebminHome" \
        "lDebminHomeDOS" \
        "lDebminHomeWSD" \
        "lDockerfilePath" \
        "lRemoveContainerOnStop" \
        "lNeedsRebuilding" && actualStatusResult=$? || actualStatusResult=$?
      # [[ ${actualStringResult} ]] && echo "____ ${LINENO}: ${functionName}: ${actualStringResult}" 

      assessReturnStatusAndStdOut \
        "${functionName}" \
        ${LINENO} \
        "${testIntent}" \
        "${expectedStringResult}" \
        ${expectedStatusResult} \
        "${actualStringResult}" \
        ${actualStatusResult} && { ((iSuccessResults++)); true ; } || { ((iFailureResults++)); true ; }
    }
    fn__testInputAndExecution

    testIntent="${functionName} will return __SUCCESS and match expected values of all reference variables"
    fn__testOutput() {
      expectedStringResult=""
      expectedStatusResult=${__SUCCESS}

      local lMismatches=0

      [[ "${lDebminHome}" != "/mnt/d/gitserver/gitserver" ]] && (( lMismatches++ ))
      [[ "${lDebminHomeDOS}" != "d:\gitserver\gitserver" ]] && (( lMismatches++ ))
      [[ "${lDebminHomeWSD}" != "d:/gitserver/gitserver" ]] && (( lMismatches++ ))
      [[ "${lDockerfilePath}" != "/mnt/d/gitserver/gitserver/Dockerfile.gitserver" ]] && (( lMismatches++ ))
      [[ "${lRemoveContainerOnStop}" != "0" ]] && (( lMismatches++ ))
      [[ "${lNeedsRebuilding}" != "1" ]] && (( lMismatches++ ))

      actualStringResult=""
      actualStatusResult=${lMismatches}

      assessReturnStatusAndStdOut \
        "${functionName}" \
        ${LINENO} \
        "${testIntent}" \
        "${expectedStringResult}" \
        ${expectedStatusResult} \
        "${actualStringResult}" \
        ${actualStatusResult} && { ((iSuccessResults++)); true ; } || { ((iFailureResults++)); true ; }
    }
    fn__testOutput
    
  }
  fn__SetEnvironmentVariables_test_007


  testIntent="${functionName} will return __FAILED and error changing directory to the non-existent directory"
  function fn__SetEnvironmentVariables_test_008 {
    local -r lrScriptDirectoryName="${__SCRIPTS_DIRECTORY_NAME}"
    local -r lrGitserverImageName="${__GITSERVER_IMAGE_NAME}"
    local -r lrGitserverShellGlobalProfile="${__GITSERVER_SHELL_GLOBAL_PROFILE}"
    local lDebminHome="/mnt/d/gitserver/gitserver/_commonUtils/areNotRight"
    local lDebminHomeDOS=""
    local lDebminHomeWSD=""
    local lDockerfilePath=""
    local lRemoveContainerOnStop=""
    local lNeedsRebuilding=""
    
    fn__testInputAndExecution() {
      expectedStringResult="cd: /mnt/d/gitserver/gitserver/_commonUtils/areNotRight: No such file or directory"
      expectedStatusResult=${__FAILED}

      actualStringResult=$( ${functionName} \
        "${lrScriptDirectoryName}" \
        "${lrGitserverImageName}" \
        "${lrGitserverShellGlobalProfile}" \
        "lDebminHome" \
        "lDebminHomeDOS" \
        "lDebminHomeWSD" \
        "lDockerfilePath" \
        "lRemoveContainerOnStop" \
        "lNeedsRebuilding" ) && actualStatusResult=$? || actualStatusResult=$?
      # [[ ${actualStringResult} ]] && echo "____ ${LINENO}: ${functionName}: ${actualStringResult}" 

      assessReturnStatusAndStdOut \
        "${functionName}" \
        ${LINENO} \
        "${testIntent}" \
        "${expectedStringResult}" \
        ${expectedStatusResult} \
        "${actualStringResult}" \
        ${actualStatusResult} && { ((iSuccessResults++)); true ; } || { ((iFailureResults++)); true ; }
    }
    fn__testInputAndExecution
  }
  fn__SetEnvironmentVariables_test_008


  function fn__SetEnvironmentVariables_test_009 {
    local -r lrScriptDirectoryName="${__SCRIPTS_DIRECTORY_NAME}"
    local -r lrGitserverImageName="${__GITSERVER_IMAGE_NAME}"
    local -r lrGitserverShellGlobalProfile="${__GITSERVER_SHELL_GLOBAL_PROFILE}"
    local lDebminHome="/mnt/d/gitserver/gitserver/backups"
    local lDebminHomeDOS=""
    local lDebminHomeWSD=""
    local lDockerfilePath=""
    local lRemoveContainerOnStop=""
    local lNeedsRebuilding=""
    
    testIntent="${functionName} will return __SUCCESS and set values of all reference variables"
    fn__testInputAndExecution() {
      expectedStringResult=""
      expectedStatusResult=${__SUCCESS}

      ${functionName} \
        "${lrScriptDirectoryName}" \
        "${lrGitserverImageName}" \
        "${lrGitserverShellGlobalProfile}" \
        "lDebminHome" \
        "lDebminHomeDOS" \
        "lDebminHomeWSD" \
        "lDockerfilePath" \
        "lRemoveContainerOnStop" \
        "lNeedsRebuilding" && actualStatusResult=$? || actualStatusResult=$?
      # [[ ${actualStringResult} ]] && echo "____ ${LINENO}: ${functionName}: ${actualStringResult}" 
      actualStringResult=""

      assessReturnStatusAndStdOut \
        "${functionName}" \
        ${LINENO} \
        "${testIntent}" \
        "${expectedStringResult}" \
        ${expectedStatusResult} \
        "${actualStringResult}" \
        ${actualStatusResult} && { ((iSuccessResults++)); true ; } || { ((iFailureResults++)); true ; }
    }
    fn__testInputAndExecution

    testIntent="${functionName} will return __FAILED and fail to match 4 variables"
    fn__testOutput() {
      expectedStringResult=""
      expectedStatusResult=4

      local lMismatches=0
      [[ "${lDebminHome}" != "/mnt/d/gitserver/gitserver" ]] && (( lMismatches++ ))
      [[ "${lDebminHomeDOS}" != "d:\gitserver\gitserver" ]] && (( lMismatches++ ))
      [[ "${lDebminHomeWSD}" != "d:/gitserver/gitserver" ]] && (( lMismatches++ ))
      [[ "${lDockerfilePath}" != "/mnt/d/gitserver/gitserver/Dockerfile.gitserver" ]] && (( lMismatches++ ))
      [[ "${lRemoveContainerOnStop}" != "0" ]] && (( lMismatches++ ))
      [[ "${lNeedsRebuilding}" != "1" ]] && (( lMismatches++ ))

      actualStringResult="Failed to match ${lMismatches} variable assignments"
      actualStatusResult=${lMismatches}

      assessReturnStatusAndStdOut \
        "${functionName}" \
        ${LINENO} \
        "${testIntent}" \
        "${expectedStringResult}" \
        ${expectedStatusResult} \
        "${actualStringResult}" \
        ${actualStatusResult} && { ((iSuccessResults++)); true ; } || { ((iFailureResults++)); true ; }
    }
    fn__testOutput
    
  }
  fn__SetEnvironmentVariables_test_009

else 
  echo "     . Not running test for ${functionName}"
fi




# clean up
# rm -Rf ${_TEMP_DIR_}

echo "____ Executed $((iSuccessResults+iFailureResults)) tests"
echo "____ ${iSuccessResults} tests were successful"
echo "____ ${iFailureResults} tests failed"

exit ${iFailureResults}
