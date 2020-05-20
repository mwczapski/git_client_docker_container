#!/bin/bash
# #############################################
# The MIT License (MIT)
#
# Copyright © 2020 Michael Czapski
# #############################################

declare -u _02_create_git_client_container_tests="SOURCED"
echo "INFO 02_create_git_client_container_tests"

[[ ${bash_test_utils} ]] || source ./bash_test_utils/bash_test_utils.sh

[[ ${__env_GlobalConstants} ]] || source ./utils/__env_GlobalConstants.sh
[[ ${__env_gitClientConstants} ]] || source ./utils/__env_gitClientConstants.sh
[[ ${fn__UtilityGeneric} ]] || source ./utils/fn__UtilityGeneric.sh

[[ ${_02_create_git_client_container_utils} ]] || source ./02_create_git_client_container_utils.sh


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

declare -r _TEMP_DIR_PREFIX=/tmp/tests_
declare -r _TEMP_DIR_=${_TEMP_DIR_PREFIX}${gTS}

declare -i _RUN_TEST_SET_=${__NO}

# defining _FORCE_RUNNING_ALL_TESTS_ will force all test sets in this suite 
# to be executed regardless of the setting for each test set
#
#_FORCE_RUNNING_ALL_TESTS_=""

# echo "------------------------------------ F ---------------"
# declare -F 
# echo "------------------------------------ F ---------------"

## ################################################################
## create expected files 
## ################################################################
mkdir -p ${_TEMP_DIR_}

declare -r _DOCKER_COMPOSE_ACTUAL_=${_TEMP_DIR_}/docker_compose.yml
declare -r _DOCKER_COMPOSE_EXPECTED_=${_TEMP_DIR_}/docker_compose.yml.expected
cat <<-'EOF' > ${_DOCKER_COMPOSE_EXPECTED_}
version: "3.7"

services:
    testapp:
        container_name: testapp
        image: gitclient:1.0.0

        restart: always

        tty: true         # these two keep the container running even if there is no listener in the foreground
        stdin_open: true

        hostname: testapp
        volumes:
            - "/var/run/docker.sock:/var/run/docker.sock"
            - "d:/tmp/testapp/backups:/home/gitclient/backups"

networks:
    default:
        driver: bridge
        external:
            name: devcicd_net
EOF


## ############################################################################
## define tests
## ############################################################################


functionName="fn__SetEnvironmentVariables"
:<<-'------------Function_Usage_Note-------------------------------'
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
    ${__NO_SUCH_DIRECTORY}
    ${__FAILED}   # presumed container name is not a valid identifier
------------Function_Usage_Note-------------------------------
_RUN_TEST_SET_=${__NO}
if [[ ${_RUN_TEST_SET_} -eq ${__YES} || ${_FORCE_RUNNING_ALL_TESTS_} ]]
then

  testIntent="${functionName} will return __INSUFFICIENT_ARGS_STS status"
  function fn__SetEnvironmentVariables_test_001 {
    local -r lDebminHome="/mnt/d/tmp/testapp/_commonUtils"
    local -r pGitclientUsername="testapp"
    local -r pDebminSourceImageName="gitclient:1.0.0"

    expectedStringResult=""
    expectedStatusResult=${__INSUFFICIENT_ARGS_STS}
    actualStringResult=$( ${functionName} ${lDebminHome} ${pGitclientUsername} ) && actualStatusResult=$? || actualStatusResult=$?
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


  function fn__SetEnvironmentVariables_test_002 {
    local -r lrDebminHomeIn="/mnt/d/tmp/testapp$(date +%s)/_commonUtils"
    local -r lrGitserverImageNameAndVersion="gitclient:1.0.0"
    local lOutDebminHomeOut=""
    local lOutDebminHomeOutWSD=""
    local lOutDebminHomeOutDOS=""
    local lOutDockerComposeFileWSL=""
    local lOutDockerComposeFileDOS=""
    local lOutContainerSourceImage=""
    local lOutGitClientContainerName=""
    local lOutGitClientHostName=""
    local lOutGitClientRemoteRepoName=""

    testIntent="${functionName} function will return __NO_SUCH_DIRECTORY"
    fn__testInputAndExecution() {
      expectedStringResult=""
      expectedStatusResult=${__NO_SUCH_DIRECTORY}

      ${functionName} \
        "${lrDebminHomeIn}" \
        "${lrGitserverImageNameAndVersion}" \
        "lOutDebminHomeOut" \
        "lOutDebminHomeOutWSD" \
        "lOutDebminHomeOutDOS" \
        "lOutDockerComposeFileWSL" \
        "lOutDockerComposeFileDOS" \
        "lOutContainerSourceImage" \
        "lOutGitClientContainerName" \
        "lOutGitClientHostName" \
        "lOutGitClientRemoteRepoName" && actualStatusResult=$? || actualStatusResult=$?

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
  fn__SetEnvironmentVariables_test_002


  function fn__SetEnvironmentVariables_test_003 {
    local -r lrDebminHomeIn="/mnt/d/gitserver/gitclient/_commonUtils"
    local -r lrGitserverImageNameAndVersion="gitclient:1.0.0"
    local lOutDebminHomeOut=""
    local lOutDebminHomeOutWSD=""
    local lOutDebminHomeOutDOS=""
    local lOutDockerComposeFileWSL=""
    local lOutDockerComposeFileDOS=""
    local lOutContainerSourceImage=""
    local lOutGitClientContainerName=""
    local lOutGitClientHostName=""
    local lOutGitClientRemoteRepoName=""

    testIntent="${functionName} function will return __SUCCESS"
    fn__testInputAndExecution() {
      expectedStringResult=""
      expectedStatusResult=${__SUCCESS}

      ${functionName} \
        "${lrDebminHomeIn}" \
        "${lrGitserverImageNameAndVersion}" \
        "lOutDebminHomeOut" \
        "lOutDebminHomeOutWSD" \
        "lOutDebminHomeOutDOS" \
        "lOutDockerComposeFileWSL" \
        "lOutDockerComposeFileDOS" \
        "lOutContainerSourceImage" \
        "lOutGitClientContainerName" \
        "lOutGitClientHostName" \
        "lOutGitClientRemoteRepoName" && actualStatusResult=$? || actualStatusResult=$?

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

      [[ "${lOutDebminHomeOut}" != "/mnt/d/gitserver/gitclient" ]] && (( lMismatches++ ))
      [[ "${lOutDebminHomeOutWSD}" != "d:/gitserver/gitclient" ]] && (( lMismatches++ ))
      [[ "${lOutDebminHomeOutDOS}" != "d:\gitserver\gitclient" ]] && (( lMismatches++ ))
      [[ "${lOutDockerComposeFileWSL}" != "/mnt/d/gitserver/gitclient/docker-compose.yml_gitclient" ]] && (( lMismatches++ ))
      [[ "${lOutDockerComposeFileDOS}" != "d:\gitserver\gitclient\docker-compose.yml_gitclient" ]] && (( lMismatches++ ))
      [[ "${lOutContainerSourceImage}" != "gitclient:1.0.0" ]] && (( lMismatches++ ))
      [[ "${lOutGitClientContainerName}" != "gitclient" ]] && (( lMismatches++ ))
      [[ "${lOutGitClientHostName}" != "gitclient" ]] && (( lMismatches++ ))
      [[ "${lOutGitClientRemoteRepoName}" != "gitclient" ]] && (( lMismatches++ ))

      actualStringResult=""
      test ${lMismatches} -gt 0 && actualStatusResult=${__FAILED} || actualStatusResult=${__SUCCESS}

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
  fn__SetEnvironmentVariables_test_003


  function fn__SetEnvironmentVariables_test_004 {
    # local -r lrDebminHomeIn="/mnt/d/gitserver/gitclient/_commonUtils"
    local -r lrDebminHomeIn="/mnt/d/gitserver/gitclient"
    local -r lrGitserverImageNameAndVersion="gitclient:1.0.0XX"
    local lOutDebminHomeOut=""
    local lOutDebminHomeOutWSD=""
    local lOutDebminHomeOutDOS=""
    local lOutDockerComposeFileWSL=""
    local lOutDockerComposeFileDOS=""
    local lOutContainerSourceImage=""
    local lOutGitClientContainerName=""
    local lOutGitClientHostName=""
    local lOutGitClientRemoteRepoName=""

    testIntent="${functionName} function will return __SUCCESS"
    fn__testInputAndExecution() {
      expectedStringResult=""
      expectedStatusResult=${__SUCCESS}

      ${functionName} \
        "${lrDebminHomeIn}" \
        "${lrGitserverImageNameAndVersion}" \
        "lOutDebminHomeOut" \
        "lOutDebminHomeOutWSD" \
        "lOutDebminHomeOutDOS" \
        "lOutDockerComposeFileWSL" \
        "lOutDockerComposeFileDOS" \
        "lOutContainerSourceImage" \
        "lOutGitClientContainerName" \
        "lOutGitClientHostName" \
        "lOutGitClientRemoteRepoName" && actualStatusResult=$? || actualStatusResult=$?

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


    testIntent="${functionName} will return __FAILED, some variable values will not match expected values of reference variables"
    fn__testOutput() {
      expectedStringResult=""
      expectedStatusResult=${__FAILED}

      local lMismatches=0

      [[ "${lOutDebminHomeOut}" != "/mnt/d/gitserver/gitclient" ]] && (( lMismatches++ ))
      [[ "${lOutDebminHomeOutWSD}" != "d:/gitserver/gitclient" ]] && (( lMismatches++ ))
      [[ "${lOutDebminHomeOutDOS}" != "d:\gitserver\gitclient" ]] && (( lMismatches++ ))
      [[ "${lOutDockerComposeFileWSL}" != "/mnt/d/gitserver/gitclient/docker-compose.yml_gitclient" ]] && (( lMismatches++ ))
      [[ "${lOutDockerComposeFileDOS}" != "d:\gitserver\gitclient\docker-compose.yml_gitclient" ]] && (( lMismatches++ ))
      [[ "${lOutContainerSourceImage}" != "gitclient:1.0.0" ]] && (( lMismatches++ ))
      [[ "${lOutGitClientContainerName}" != "gitclient" ]] && (( lMismatches++ ))
      [[ "${lOutGitClientHostName}" != "gitclient" ]] && (( lMismatches++ ))
      [[ "${lOutGitClientRemoteRepoName}" != "gitclient" ]] && (( lMismatches++ ))

      actualStringResult=""
      test ${lMismatches} -gt 0 && actualStatusResult=${__FAILED} || actualStatusResult=${__SUCCESS}

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
  fn__SetEnvironmentVariables_test_004


  function fn__SetEnvironmentVariables_test_005 {
    local -r lrDebminHomeIn="/mnt/d/tmp/testapp$(date +%s)/_commonUtils"
    local -r lrGitserverImageNameAndVersion="gitclient:1.0.0"
    local lOutDebminHomeOut=""
    local lOutDebminHomeOutWSD=""
    local lOutDebminHomeOutDOS=""
    local lOutDockerComposeFileWSL=""
    local lOutDockerComposeFileDOS=""
    local lOutContainerSourceImage=""
    local lOutGitClientContainerName=""
    local lOutGitClientHostName=""
    local lOutGitClientRemoteRepoName=""

    testIntent="${functionName} function will return __INSUFFICIENT_ARGS_STS - one of the expected output variables is missing"
    fn__testInputAndExecution() {
      expectedStringResult=""
      expectedStatusResult=${__INSUFFICIENT_ARGS_STS}

      ${functionName} \
        "${lrDebminHomeIn}" \
        "${lrGitserverImageNameAndVersion}" \
        "lOutDebminHomeOut" \
        "lOutDebminHomeOutWSD" \
        "lOutDebminHomeOutDOS" \
        "lOutDockerComposeFileWSL" \
        "lOutDockerComposeFileDOS" \
        "lOutContainerSourceImage" \
        "lOutGitClientHostName" \
        "lOutGitClientRemoteRepoName" && actualStatusResult=$? || actualStatusResult=$?

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
  fn__SetEnvironmentVariables_test_005


  function fn__SetEnvironmentVariables_test_006 {
    local -r lrDebminHomeIn="/mnt/d/tmp/testapp$(date +%s)/_commonUtils"
    local -r lrGitserverImageNameAndVersion="gitclient:1.0.0"
    local lOutDebminHomeOut=""
    local lOutDebminHomeOutWSD=""
    local lOutDebminHomeOutDOS=""
    local lOutDockerComposeFileWSL=""
    local lOutDockerComposeFileDOS=""
    local lOutContainerSourceImage=""
    local lOutGitClientContainerName=""
    local lOutGitClientHostName=""
    local lOutGitClientRemoteRepoName=""

    testIntent="${functionName} function will return __INVALID_VALUE - one of the expected output variables is empty"
    fn__testInputAndExecution() {
      expectedStringResult=""
      expectedStatusResult=${__INVALID_VALUE}

      ${functionName} \
        "${lrDebminHomeIn}" \
        "${lrGitserverImageNameAndVersion}" \
        "lOutDebminHomeOut" \
        "lOutDebminHomeOutWSD" \
        "lOutDebminHomeOutDOS" \
        "lOutDockerComposeFileWSL" \
        "lOutDockerComposeFileDOS" \
        "lOutContainerSourceImage" \
        "" \
        "lOutGitClientHostName" \
        "lOutGitClientRemoteRepoName" && actualStatusResult=$? || actualStatusResult=$?

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
  fn__SetEnvironmentVariables_test_006


else 
  echo "   . Not running test for ${functionName}"
fi


functionName="fn__CreateDockerComposeFile"
:<<-'------------Function_Usage_Note-------------------------------'
  Usage:
    fn__CreateDockerComposeFile \
      "${__GIT_CLIENT_CONTAINER_NAME}"  \
      "${__GIT_CLIENT_HOST_NAME}"  \
      "${__DEVCICD_NET_DC_INTERNAL}"  \
      "${__DEBMIN_SOURCE_IMAGE_NAME}"  \
      "${__DEBMIN_HOME_DOS}:${__GIT_CLIENT_GUEST_HOME}" \
      "${__DOCKER_COMPOSE_FILE_WLS}"
    returns 
      ${__DONE} and creates a docker-compose.yml_XXXX file 
      ${__FAILED} if insufficient number of arguments are provided
------------Function_Usage_Note-------------------------------
_RUN_TEST_SET_=${__NO}
if [[ ${_RUN_TEST_SET_} -eq ${__YES} || ${_FORCE_RUNNING_ALL_TESTS_} ]]
then

  function fn__CreateDockerComposeFile_test_001 {
    local -r lGitClientContainerName="testapp"
    local -r lGitClientHostName="testapp"
    local -r lDecCiCdNetDCInternal="docker_devcicd_net"
    local -r lDebminSourceImageName="gitclient:1.0.0"
    local -r lDockerBoundVolumeSpec="d:/tmp/testapp/testapp/backups:/home/gitclient/backups"
    local -r lDockerComposeFileWSL="/mnt/d/tmp/testapp/docker-compose.yml_testapp"

    # echo "${__GIT_CLIENT_CONTAINER_NAME}"
    # echo "${__GIT_CLIENT_HOST_NAME}"
    # echo "${__DEVCICD_NET}"
    # echo "${__DEBMIN_SOURCE_IMAGE_NAME}"
    # echo "${__DEBMIN_HOME_WSD}/${__GIT_CLIENT_CONTAINER_NAME}/backups:${__GIT_CLIENT_GUEST_HOME}/backups"
    # echo "${__DOCKER_COMPOSE_FILE_WLS}"

    testIntent="${functionName} function will return __FAILURE status, insufficient number of arguments and Usage message"
    functionInputs=""
    expectedStringResult="${__INSUFFICIENT_ARGS}"
    expectedStatusResult=${__FAILED}
    actualStringResult=$( ${functionName} ${functionInputs} ) && actualStatusResult=$? || actualStatusResult=$? 
    # [[ ${actualStringResult} ]] && echo "____ ${LINENO}: ${functionName}: ${actualStringResult}" 
    actualStringResult=${actualStringResult:0:${#expectedStringResult}}
    [[ "${actualStringResult}" == "${expectedStringResult}" && ${actualStatusResult} -eq ${expectedStatusResult} ]] && {
        # echo "PASS ${LINENO}: ${functionName}: ${functionInputs} => ${expectedStringResult} == ${actualStringResult} (${actualStatusResult} -eq ${expectedStatusResult})" 
        echo "PASS ${LINENO}: ${testIntent}" 
        ((iSuccessResults++)); true
      } || {
        echo "FAIL ${LINENO}: ${functionName}: ${functionInputs} => ${expectedStringResult} != ${actualStringResult} (${actualStatusResult} -ne ${expectedStatusResult})" 
        ((iFailureResults++)); true
      }
  }
  fn__CreateDockerComposeFile_test_001


  function fn__CreateDockerComposeFile_test_002 {
    local -r TS=$(date '+%Y%m%d_%H%M%S')

    local -r lGitClientContainerName="testapp"
    local -r lGitClientHostName="${lGitClientContainerName}"
    local -r lDevCiCdNetDCInternal="devcicd_net"
    local -r lDebminSourceImageName="gitclient:1.0.0"
    local -r lDockerBoundVolumeSpec="d:/tmp/${lGitClientContainerName}/backups:/home/gitclient/backups"
    local -r lDockerComposeFileWSL="${_DOCKER_COMPOSE_ACTUAL_}${TS}"

    testIntent="${functionName} will return __SUCCESS status and confirm that the file was created"
    expectedStringResult=""
    expectedStatusResult=${__SUCCESS}
    ${functionName} ${lGitClientContainerName} ${lGitClientHostName} ${lDevCiCdNetDCInternal} ${lDebminSourceImageName} ${lDockerBoundVolumeSpec} ${lDockerComposeFileWSL} && actualStatusResult=$? || actualStatusResult=$? 
  
    assessReturnStatusAndStdOut \
      "${functionName}" \
      ${LINENO} \
      "${testIntent}" \
      "${expectedStringResult}" \
      ${expectedStatusResult} \
      "${actualStringResult}" \
      ${actualStatusResult} && { ((iSuccessResults++)); true ; } || { ((iFailureResults++)); true ; }
  }
  fn__CreateDockerComposeFile_test_002


  function fn__CreateDockerComposeFile_test_003 {
    local -r TS=$(date '+%Y%m%d_%H%M%S')

    local -r lGitClientContainerName="testapp"
    local -r lGitClientHostName="${lGitClientContainerName}"
    local -r lDevCiCdNetDCInternal="devcicd_net"
    local -r lDebminSourceImageName="gitclient:1.0.0"
    local -r lDockerBoundVolumeSpec="d:/tmp/${lGitClientContainerName}/backups:/home/gitclient/backups"
    local -r lDockerComposeFileWSL="${_DOCKER_COMPOSE_ACTUAL_}${TS}"

    testIntent="${functionName} function will return __SUCCESS status and will write docker-compose.yml file in the designated directory whose content is identical to the expected content"
    expectedStringResult=""
    expectedStatusResult=${__SUCCESS}
    expectedContentSameResult=${__YES}

    actualStringResult=$( ${functionName} ${lGitClientContainerName} ${lGitClientHostName} ${lDevCiCdNetDCInternal} ${lDebminSourceImageName} ${lDockerBoundVolumeSpec} ${lDockerComposeFileWSL} ) && actualStatusResult=$? || actualStatusResult=$? 
    [[ ${actualStringResult} ]] && echo "____ ${LINENO}: ${functionName}: ${actualStringResult}" 
    actualStringResult=${actualStringResult:0:${#expectedStringResult}}
    [[ "${actualStringResult}" == "${expectedStringResult}" && ${actualStatusResult} -eq ${expectedStatusResult} ]] && {
        diff -swq ${_DOCKER_COMPOSE_EXPECTED_} ${lDockerComposeFileWSL} >/dev/null && STS=$? || STS=$?
        if [[ $STS -ne ${__THE_SAME} ]]
        then
          if [[ expectedContentSameResult -eq ${__YES} ]]
          then
            echo "FAIL ${LINENO}: ${functionName}: ${functionInputs} => ${expectedStringResult} != ${actualStringResult} (${actualStatusResult} -ne ${expectedStatusResult}) - Different file content" 
            ((iFailureResults++)); true
          else
            # echo "PASS ${LINENO}: ${functionName}: ${functionInputs} => ${expectedStringResult} == ${actualStringResult} (${actualStatusResult} -eq ${expectedStatusResult}) - Different file content" 
            echo "PASS ${LINENO}: ${testIntent}" 
            ((iSuccessResults++)); true
          fi
        else 
          # echo "PASS ${LINENO}: ${functionName}: ${functionInputs} => ${expectedStringResult} == ${actualStringResult} (${actualStatusResult} -eq ${expectedStatusResult})" 
        echo "PASS ${LINENO}: ${testIntent}" 
          ((iSuccessResults++)); true
        fi
      } || {
        echo "FAIL ${LINENO}: ${functionName}: ${functionInputs} => ${expectedStringResult} != ${actualStringResult} (${actualStatusResult} -ne ${expectedStatusResult})" 
        ((iFailureResults++)); true
      }
    }
  fn__CreateDockerComposeFile_test_003


  function fn__CreateDockerComposeFile_test_004 {
    local -r TS=TS=$(date '+%Y%m%d_%H%M%S')

    local -r lGitClientContainerName="testappXXX"
    local -r lGitClientHostName="${lGitClientContainerName}"
    local -r lDevCiCdNetDCInternal="devcicd_netYYY"
    local -r lDebminSourceImageName="gitclientZZZ:1.0.0"
    local -r lDockerBoundVolumeSpec="d:/tmp/${lGitClientContainerName}/backups:/home/gitclient/backups"
    local -r lDockerComposeFileWSL="${_DOCKER_COMPOSE_ACTUAL_}${TS}"

    testIntent="${functionName} function will return __SUCCESS status and will write docker-compose.yml file in the designated directory whose content is DIFFERENT fromthe expected content"
    expectedStringResult=""
    expectedStatusResult=${__SUCCESS}
    expectedContentSameResult=${__NO}

    actualStringResult=$( ${functionName} ${lGitClientContainerName} ${lGitClientHostName} ${lDevCiCdNetDCInternal} ${lDebminSourceImageName} ${lDockerBoundVolumeSpec} ${lDockerComposeFileWSL} ) && actualStatusResult=$? || actualStatusResult=$? 
    # [[ ${actualStringResult} ]] && echo "____ ${LINENO}: ${functionName}: ${actualStringResult}" 
    actualStringResult=${actualStringResult:0:${#expectedStringResult}}
    [[ "${actualStringResult}" == "${expectedStringResult}" && ${actualStatusResult} -eq ${expectedStatusResult} ]] && {
        # cat ${_DOCKER_COMPOSE_EXPECTED_} | sed 's|[0-9]\{8\}_[0-9]\{6\}|DDDDDDDD_TTTTTT|g' > ${_DOCKER_COMPOSE_EXPECTED_}.masked
        # cat ${lDockerComposeFileWSL} | sed 's|[0-9]\{8\}_[0-9]\{6\}|DDDDDDDD_TTTTTT|g' > ${lDockerComposeFileWSL}.masked
        # diff -swq ${_DOCKER_COMPOSE_EXPECTED_}.masked ${lDockerComposeFileWSL}.masked 1>/dev/null 2>&1 && STS=$? || STS=$?
        diff -swq ${_DOCKER_COMPOSE_EXPECTED_} ${lDockerComposeFileWSL} 1>/dev/null 2>&1 && STS=$? || STS=$?
        if [[ $STS -ne ${__THE_SAME} ]]
        then
          if [[ expectedContentSameResult -eq ${__YES} ]]
          then
            echo "FAIL ${LINENO}: ${functionName}: ${functionInputs} => ${expectedStringResult} != ${actualStringResult} (${actualStatusResult} -ne ${expectedStatusResult}) - Different file content" 
            ((iFailureResults++)); true
          else
            # echo "PASS ${LINENO}: ${functionName}: ${functionInputs} => ${expectedStringResult} == ${actualStringResult} (${actualStatusResult} -eq ${expectedStatusResult}) - Different file content" 
            echo "PASS ${LINENO}: ${testIntent}" 
            ((iSuccessResults++)); true
          fi
        else 
          # echo "PASS ${LINENO}: ${functionName}: ${functionInputs} => ${expectedStringResult} == ${actualStringResult} (${actualStatusResult} -eq ${expectedStatusResult})" 
          echo "PASS ${LINENO}: ${testIntent}" 
          ((iSuccessResults++)); true
        fi
      } || {
        echo "FAIL ${LINENO}: ${functionName}: ${functionInputs} => ${expectedStringResult} != ${actualStringResult} (${actualStatusResult} -ne ${expectedStatusResult})" 
        ((iFailureResults++)); true
      }
    }
  fn__CreateDockerComposeFile_test_004


else 
  echo "   . Not running test for ${functionName}"
fi



functionName="fn__DeriveContainerName"
:<<-'------------Function_Usage_Note-------------------------------'
  Usage:
    lContainerName=$(fn__DeriveContainerName \
      ${__DEBMIN_HOME})
        returns ${__SUCCESS} and container name or ${__FAILED} if insufficient number of arguments are provided
------------Function_Usage_Note-------------------------------
_RUN_TEST_SET_=${__NO}
if [[ ${_RUN_TEST_SET_} -eq ${__YES} || ${_FORCE_RUNNING_ALL_TESTS_} ]]
then
  testIntent="${functionName} function will return __FAILURE status, insufficient number of arguments and Usage message"
  function fn__DeriveContainerName_test_001 {
    local -r lDebminHome="/mnt/d/tmp/testapp"

    expectedStringResult=${__INSUFFICIENT_ARGS}
    expectedStatusResult=${__FAILED}

    actualStringResult=$( ${functionName} ) && actualStatusResult=$? || actualStatusResult=$?
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
  fn__DeriveContainerName_test_001


  testIntent="${functionName} function will return __SUCCESS status and expected container name"
  function fn__DeriveContainerName_test_002 {
    local -r lDebminHome="/mnt/d/tmp/testapp"

    local -r expectedStringResult="testapp"
    local -r expectedStatusResult=${__SUCCESS}

    local actualStringResult=$( ${functionName} ${lDebminHome}) && actualStatusResult=$? || actualStatusResult=$?
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
  fn__DeriveContainerName_test_002


  testIntent="${functionName} function will return __SUCCESS status and incorrect container name"
  function fn__DeriveContainerName_test_003 {
    local -r lDebminHome="/mnt/d/tmp/testappXX"

    local -r expectedStringResult="testapp"
    local -r expectedStatusResult=${__SUCCESS}

    actualStringResult=$( ${functionName} ${lDebminHome}) && actualStatusResult=$? || actualStatusResult=$?
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
  fn__DeriveContainerName_test_003


  testIntent="${functionName} function will return __SUCCESS status and correct container name"
  function fn__DeriveContainerName_test_004 {
    local -r lDebminHome="/mnt/d/tmp/t@e^sT-a#p+p_%X!_X"  ## regex that cleans the name is [a-zA-Z-9_]

    local -r expectedStringResult="tesTapp_X_X"
    local -r expectedStatusResult=${__SUCCESS}

    actualStringResult=$( ${functionName} ${lDebminHome}) && actualStatusResult=$? || actualStatusResult=$?
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
  fn__DeriveContainerName_test_004



else 
  echo "   . Not running test for ${functionName}"
fi



functionName="fn__GetProjectName"
:<<-'------------Function_Usage_Note-------------------------------'
  Usage:
      fn__GetProjectName \
        "__DEBMIN_HOME"   # in/out
  Returns:
    __SUCCESS and the Name path conforms to the expectation and Name path
    __FAILED if there were insufficient arguments or the Name path does not conform to expectations
------------Function_Usage_Note-------------------------------
_RUN_TEST_SET_=${__NO}
if [[ ${_RUN_TEST_SET_} -eq ${__YES} || ${_FORCE_RUNNING_ALL_TESTS_} ]]
then

  # prepapre directory for testing structure and presence
  #
  declare lProjectName="testproject"
  declare lProjectDirectory="${_TEMP_DIR_}/${lProjectName}"
  mkdir -p ${lProjectDirectory}/${__SCRIPTS_DIRECTORY_NAME}

  testIntent="${functionName} function will return __FAILURE status, insufficient number of arguments and Usage message"
  function fn__GetProjectName_test_001 {
    local lDebminHome_inout=""

    expectedStringResult=${__INSUFFICIENT_ARGS}
    expectedStatusResult=${__FAILED}

    actualStringResult=$( ${functionName} ) && actualStatusResult=$? || actualStatusResult=$?
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
  fn__GetProjectName_test_001
  

  testIntent="${functionName} function will return __SUCCESS status"
  function fn__GetProjectName_test_002 {
    local lDebminHome_inout="${lProjectDirectory}"

    expectedStringResult="$(basename ${lProjectDirectory})"
    expectedStatusResult=${__SUCCESS}
    ${functionName} "lDebminHome_inout" && actualStatusResult=$? || actualStatusResult=$?
    # [[ ${lDebminHome_inout} ]] && echo "____ ${LINENO}: ${functionName}: ${lDebminHome_inout}" 
    actualStringResult="${lDebminHome_inout}"

    assessReturnStatusAndStdOut \
      "${functionName}" \
      ${LINENO} \
      "${testIntent}" \
      "${expectedStringResult}" \
      ${expectedStatusResult} \
      "${actualStringResult}" \
      ${actualStatusResult} && { ((iSuccessResults++)); true ; } || { ((iFailureResults++)); true ; }
  }
  fn__GetProjectName_test_002
  

  testIntent="${functionName} function will return __FAILED status if project structure is as expected but project directory hierarchy does not exists"
  function fn__GetProjectName_test_003 {
    local lDebminHome_inout="${lProjectDirectory}XX/${__SCRIPTS_DIRECTORY_NAME}"

    expectedStringResult="Directory hierarchy '${lDebminHome_inout}' does not exist"
    expectedStatusResult=${__FAILED}
    ${functionName} "lDebminHome_inout" && actualStatusResult=$? || actualStatusResult=$?
    # [[ ${lDebminHome_inout} ]] && echo "____ ${LINENO}: ${functionName}: ${lDebminHome_inout}" 
    
    actualStringResult="${lDebminHome_inout}"
    assessReturnStatusAndStdOut \
      "${functionName}" \
      ${LINENO} \
      "${testIntent}" \
      "${expectedStringResult}" \
      ${expectedStatusResult} \
      "${actualStringResult}" \
      ${actualStatusResult} && { ((iSuccessResults++)); true ; } || { ((iFailureResults++)); true ; }
  }
  fn__GetProjectName_test_003


  testIntent="${functionName} function will return __SUCCESS status if project structure is as expected and directory hierarchy exists"
  function fn__GetProjectName_test_005 {
    local lDebminHome_inout="${lProjectDirectory}/${__SCRIPTS_DIRECTORY_NAME}"

    expectedStringResult="${lProjectName}"
    expectedStatusResult=${__SUCCESS}
    ${functionName} "lDebminHome_inout" && actualStatusResult=$? || actualStatusResult=$?
    # [[ ${lDebminHome_inout} ]] && echo "____ ${LINENO}: ${functionName}: ${lDebminHome_inout}" 
    actualStringResult="${lDebminHome_inout}"

    assessReturnStatusAndStdOut \
      "${functionName}" \
      ${LINENO} \
      "${testIntent}" \
      "${expectedStringResult}" \
      ${expectedStatusResult} \
      "${actualStringResult}" \
      ${actualStatusResult} && { ((iSuccessResults++)); true ; } || { ((iFailureResults++)); true ; }
  }
  fn__GetProjectName_test_005


  testIntent="${functionName} function will return __SUCCESS status if project structure is as expected and directory hierarchy exists"
  function fn__GetProjectName_test_006 {
    local lDebminHome_inout="${lProjectDirectory}"

    expectedStringResult="${lProjectName}"
    expectedStatusResult=${__SUCCESS}
    ${functionName} "lDebminHome_inout" && actualStatusResult=$? || actualStatusResult=$?
    # [[ ${lDebminHome_inout} ]] && echo "____ ${LINENO}: ${functionName}: ${lDebminHome_inout}" 

    actualStringResult="${lDebminHome_inout}"
    assessReturnStatusAndStdOut \
      "${functionName}" \
      ${LINENO} \
      "${testIntent}" \
      "${expectedStringResult}" \
      ${expectedStatusResult} \
      "${actualStringResult}" \
      ${actualStatusResult} && { ((iSuccessResults++)); true ; } || { ((iFailureResults++)); true ; }
  }
  fn__GetProjectName_test_006

else 
  echo "   . Not running test for ${functionName}"
fi



functionName="fn__GetProjectDirectory"
:<<-'------------Function_Usage_Note-------------------------------'
  Usage:
      fn__GetProjectDirectory \
        "__DEBMIN_HOME"              # in/out
  Returns:
    __SUCCESS and the directory path conforms to the expectation and directory path
    __FAILED if there were insufficient arguments or the directory path does not conform to expectations
------------Function_Usage_Note-------------------------------
_RUN_TEST_SET_=${__NO}
if [[ ${_RUN_TEST_SET_} -eq ${__YES} || ${_FORCE_RUNNING_ALL_TESTS_} ]]
then

  # prepapre directory for testing structure and presence
  #
  declare lProjectDirectory="${_TEMP_DIR_}/testproject"
  mkdir -p ${lProjectDirectory}/${__SCRIPTS_DIRECTORY_NAME}

  testIntent="${functionName} function will return __FAILURE status, insufficient number of arguments and Usage message"
  function fn__GetProjectDirectory_test_001 {
    local lDebminHome_inout=""

    expectedStringResult=${__INSUFFICIENT_ARGS}
    expectedStatusResult=${__FAILED}
    actualStringResult=$( ${functionName} ) && actualStatusResult=$? || actualStatusResult=$?
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
  fn__GetProjectDirectory_test_001
  

  testIntent="${functionName} function will return __FAILURE status and error message if the project directory structure is not as expected"
  function fn__GetProjectDirectory_test_002 {
    local lDebminHome_inout="${lProjectDirectory}"

    expectedStringResult="Invalid project structure - basename of the directory hierarchy is not '${__SCRIPTS_DIRECTORY_NAME}'"
    expectedStatusResult=${__FAILED}
    ${functionName} "lDebminHome_inout" && actualStatusResult=$? || actualStatusResult=$?
    # [[ ${lDebminHome_inout} ]] && echo "____ ${LINENO}: ${functionName}: ${lDebminHome_inout}" 

    actualStringResult="${lDebminHome_inout}"
    assessReturnStatusAndStdOut \
      "${functionName}" \
      ${LINENO} \
      "${testIntent}" \
      "${expectedStringResult}" \
      ${expectedStatusResult} \
      "${actualStringResult}" \
      ${actualStatusResult} && { ((iSuccessResults++)); true ; } || { ((iFailureResults++)); true ; }

  }
  fn__GetProjectDirectory_test_002
  

  testIntent="${functionName} function will return __FAILED status if project structure is as expected but project directory hierarchy does not exists"
  function fn__GetProjectDirectory_test_003 {
    local lDebminHome_inout="${lProjectDirectory}XX/${__SCRIPTS_DIRECTORY_NAME}"

    expectedStringResult="Directory hierarchy '${lDebminHome_inout}' does not exist"
    expectedStatusResult=${__FAILED}
    ${functionName} "lDebminHome_inout" && actualStatusResult=$? || actualStatusResult=$?
    # [[ ${lDebminHome_inout} ]] && echo "____ ${LINENO}: ${functionName}: ${lDebminHome_inout}" 

    actualStringResult="${lDebminHome_inout}"
    assessReturnStatusAndStdOut \
      "${functionName}" \
      ${LINENO} \
      "${testIntent}" \
      "${expectedStringResult}" \
      ${expectedStatusResult} \
      "${actualStringResult}" \
      ${actualStatusResult} && { ((iSuccessResults++)); true ; } || { ((iFailureResults++)); true ; }

  }
  fn__GetProjectDirectory_test_003


  testIntent="${functionName} function will return __SUCCESS status if project structure is as expected and directory hierarchy exists"
  function fn__GetProjectDirectory_test_004 {
    local lDebminHome_inout="${lProjectDirectory}/${__SCRIPTS_DIRECTORY_NAME}"

    expectedStringResult="${lProjectDirectory}"
    expectedStatusResult=${__SUCCESS}
    ${functionName} "lDebminHome_inout" && actualStatusResult=$? || actualStatusResult=$?
    # [[ ${lDebminHome_inout} ]] && echo "____ ${LINENO}: ${functionName}: ${lDebminHome_inout}" 

    actualStringResult="${lDebminHome_inout}"
    assessReturnStatusAndStdOut \
      "${functionName}" \
      ${LINENO} \
      "${testIntent}" \
      "${expectedStringResult}" \
      ${expectedStatusResult} \
      "${actualStringResult}" \
      ${actualStatusResult} && { ((iSuccessResults++)); true ; } || { ((iFailureResults++)); true ; }

  }
  fn__GetProjectDirectory_test_004

else 
  echo "   . Not running test for ${functionName}"
fi



functionName="fn__GetClientContainerName"
:<<-'------------Function_Usage_Note-------------------------------'
  Usage:
    fn__GetClientContainerName
      __DEBMIN_HOME in
      __GIT_CLIENT_CONTAINER_NAME in/out
  Returns:
    __SUCCESS and the chosen name in populated __GIT_CLIENT_CONTAINER_NAME
    __FAILED if there were insufficient arguments, if user requested abort or if all opportunities to choose a name were exhausted without selection
------------Function_Usage_Note-------------------------------
_RUN_TEST_SET_=${__YES}
if [[ ${_RUN_TEST_SET_} -eq ${__YES} || ${_FORCE_RUNNING_ALL_TESTS_} ]]
then

  declare lProjectDirectory="/mnt/d/gitserver/gitclient/_commonUtils"
  declare lProjectName=""

  # fn__GetProjectDirectory "lProjectDirectory" || { echo "Error from fn__GetProjectDirectory at ${0}:${LINENO}"; exit; }
  fn__GetProjectDirectory "lProjectDirectory" && STS=$? || STS=$?
  if [[ ${STS} -eq ${__SUCCESS} ]]
  then
    # echo "lProjectDirectory: ${lProjectDirectory}"
    echo "all is well" >/dev/null
  else
    # echo "lProjectDirectory: ${lProjectDirectory}"
    echo "Error from fn__GetProjectDirectory at ${0}:${LINENO}"
    exit ${__FAILED}
  fi


  lProjectName="${lProjectDirectory}"
  fn__GetProjectName "lProjectName" || { echo "Error from fn__GetProjectName at ${0}:${LINENO}"; exit; }

  testIntent="${functionName} function will return __FAILURE status, insufficient number of arguments and Usage message"
  function fn__GetClientContainerName_test_001 {
    local -r lDebminHome_in="${lProjectDirectory}"
    local inoutValidValue="${__GIT_CLIENT_CONTAINER_NAME}"

    expectedStringResult=${__INSUFFICIENT_ARGS}
    expectedStatusResult=${__FAILED}
    actualStringResult=$( ${functionName} ) && actualStatusResult=$? || actualStatusResult=$?
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
  fn__GetClientContainerName_test_001
  

  testIntent="${functionName} function will return __FAILURE status, 2nd argument value is invalid"
  function fn__GetClientContainerName_test_002 {
    local -r lDebminHome_in="${lProjectDirectory}"
    local inoutValidValue="${__GIT_CLIENT_CONTAINER_NAME}"

    expectedStringResult="2nd Argument value, '', is invalid"
    expectedStatusResult=${__FAILED}
    actualStringResult=$( ${functionName} "${lDebminHome_in}" "" ) && actualStatusResult=$? || actualStatusResult=$?
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
  fn__GetClientContainerName_test_002
  

  testIntent="${functionName} function will return __SUCCESS status and accept pre-defined container name"
  function fn__GetClientContainerName_test_003 {
    local __GIT_CLIENT_CONTAINER_NAME="gitpredefinedcontainername"
    local -r lDebminHome_in="${lProjectDirectory}"
    local inoutValidValue="${__GIT_CLIENT_CONTAINER_NAME}"

    expectedStringResult="${__GIT_CLIENT_CONTAINER_NAME}"
    expectedStatusResult=${__SUCCESS}
    echo -e "Y\nY" | ${functionName} "lProjectDirectory" "inoutValidValue" && actualStatusResult=$? || actualStatusResult=$?
    # [[ ${inoutValidValue} ]] && echo "____ ${LINENO}: ${functionName}: ${inoutValidValue}" 

    actualStringResult="${inoutValidValue}"
    assessReturnStatusAndStdOut \
      "${functionName}" \
      ${LINENO} \
      "${testIntent}" \
      "${expectedStringResult}" \
      ${expectedStatusResult} \
      "${actualStringResult}" \
      ${actualStatusResult} && { ((iSuccessResults++)); true ; } || { ((iFailureResults++)); true ; }
  }
  fn__GetClientContainerName_test_003
  

  testIntent="${functionName} function will return __SUCCESS status and accept derived container name"
  function fn__GetClientContainerName_test_004 {
    local __GIT_CLIENT_CONTAINER_NAME="gitderivedcontainername"
    local -r lDebminHome_in="${lProjectDirectory}"
    local inoutValidValue="${__GIT_CLIENT_CONTAINER_NAME}"

    expectedStringResult="${__GIT_CLIENT_CONTAINER_NAME}"
    expectedStatusResult=${__SUCCESS}
    echo -e "N\nY\nY\nY" | ${functionName} "lProjectDirectory" "inoutValidValue" && actualStatusResult=$? || actualStatusResult=$?
    # [[ ${inoutValidValue} ]] && echo "____ ${LINENO}: ${functionName}: ${inoutValidValue}" 

    actualStringResult="${inoutValidValue}"
    assessReturnStatusAndStdOut \
      "${functionName}" \
      ${LINENO} \
      "${testIntent}" \
      "${expectedStringResult}" \
      ${expectedStatusResult} \
      "${actualStringResult}" \
      ${actualStatusResult} && { ((iSuccessResults++)); true ; } || { ((iFailureResults++)); true ; }

  }
  fn__GetClientContainerName_test_004
  

  testIntent="${functionName} function will return __SUCCESS status and accepts derived container name"
  function fn__GetClientContainerName_test_005 {
    local __GIT_CLIENT_CONTAINER_NAME="gitenteredcontainername"
    local -r lDebminHome_in="${lProjectDirectory}"
    local inoutValidValue="${__GIT_CLIENT_CONTAINER_NAME}"

    expectedStringResult="${__GIT_CLIENT_CONTAINER_NAME}"
    expectedStatusResult=${__SUCCESS}
    echo -e "N\nN\n${__GIT_CLIENT_CONTAINER_NAME}\nY\nY" | ${functionName} "lProjectDirectory" "inoutValidValue" >/dev/null && actualStatusResult=$? || actualStatusResult=$?
    # [[ ${inoutValidValue} ]] && echo "____ ${LINENO}: ${functionName}: ${inoutValidValue}" 

    actualStringResult="${inoutValidValue}"
    assessReturnStatusAndStdOut \
      "${functionName}" \
      ${LINENO} \
      "${testIntent}" \
      "${expectedStringResult}" \
      ${expectedStatusResult} \
      "${actualStringResult}" \
      ${actualStatusResult} && { ((iSuccessResults++)); true ; } || { ((iFailureResults++)); true ; }

  }
  fn__GetClientContainerName_test_005
  

  testIntent="${functionName} function will return __FAILED status and rejects empty entered container name"
  function fn__GetClientContainerName_test_006 {
    local __GIT_CLIENT_CONTAINER_NAME=""
    local -r lDebminHome_in="${lProjectDirectory}"
    local inoutValidValue="${__GIT_CLIENT_CONTAINER_NAME}"

    expectedStringResult="${__GIT_CLIENT_CONTAINER_NAME}"
    expectedStatusResult=${__FAILED}
    echo -e "N\nN\n${__GIT_CLIENT_CONTAINER_NAME}\n" | ${functionName} "lProjectDirectory" "inoutValidValue" >/dev/null && actualStatusResult=$? || actualStatusResult=$?
    # [[ ${inoutValidValue} ]] && echo "____ ${LINENO}: ${functionName}: ${inoutValidValue}" 

    actualStringResult="${inoutValidValue}"
    assessReturnStatusAndStdOut \
      "${functionName}" \
      ${LINENO} \
      "${testIntent}" \
      "${expectedStringResult}" \
      ${expectedStatusResult} \
      "${actualStringResult}" \
      ${actualStatusResult} && { ((iSuccessResults++)); true ; } || { ((iFailureResults++)); true ; }

  }
  fn__GetClientContainerName_test_006
  


else 
  echo "   . Not running test for ${functionName}"
fi



functionName="fn__GetRemoteGitRepoName"
:<<-'------------Function_Usage_Note-------------------------------'
  Usage:
    fn__GetRemoteGitRepoName
      ${__GIT_CLIENT_REMOTE_REPO_NAME}
      "__GIT_CLIENT_REMOTE_REPO_NAME" out
  Returns:
    __SUCCESS and the chosen name in __GIT_CLIENT_CONTAINER_NAME ref variable
    __FAILED if there were insufficient arguments, all opportunities to choose a name were exhausted or other unrecoverable errors occured
------------Function_Usage_Note-------------------------------

_RUN_TEST_SET_=${__YES}
if [[ ${_RUN_TEST_SET_} -eq ${__YES} || ${_FORCE_RUNNING_ALL_TESTS_} ]]
then

  testIntent="${functionName} function will return __FAILURE status, insufficient number of arguments and Usage message"
  function fn__GetRemoteGitRepoName_test_001 {
    local -r lDefaultGitRepoName="${__GIT_CLIENT_REMOTE_REPO_NAME}"
    local outValidValue=""

    expectedStringResult=${__INSUFFICIENT_ARGS}
    expectedStatusResult=${__FAILED}
    actualStringResult=$( ${functionName} ) && actualStatusResult=$? || actualStatusResult=$?
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
  fn__GetRemoteGitRepoName_test_001
  

  testIntent="${functionName} function will return __FAILURE status, 2nd argument value is invalid"
  function fn__GetRemoteGitRepoName_test_002 {
    local -r lDefaultGitRepoName="${__GIT_CLIENT_REMOTE_REPO_NAME}"
    local outValidValue=""

    expectedStringResult="2nd Argument value, '', is invalid"
    expectedStatusResult=${__FAILED}
    actualStringResult=$( ${functionName} "${lDefaultGitRepoName}" "" ) && actualStatusResult=$? || actualStatusResult=$?
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
  fn__GetRemoteGitRepoName_test_002
  

  testIntent="${functionName} function will return __YES status and accept default repository name"
  function fn__GetRemoteGitRepoName_test_003 {
    local -r lDefaultGitRepoName="${__GIT_CLIENT_REMOTE_REPO_NAME}XX"
    local outValidValue="a"

    expectedStringResult="${__GIT_CLIENT_REMOTE_REPO_NAME}XX"
    expectedStatusResult=${__YES}

    ${functionName} "${lDefaultGitRepoName}" "outValidValue" <<<"Y\nY\n" && actualStatusResult=$? || actualStatusResult=$?
    # [[ ${outValidValue} ]] && echo "____ ${LINENO}: ${functionName}: ${outValidValue}" 

    actualStringResult="${outValidValue}"
    assessReturnStatusAndStdOut \
      "${functionName}" \
      ${LINENO} \
      "${testIntent}" \
      "${expectedStringResult}" \
      ${expectedStatusResult} \
      "${actualStringResult}" \
      ${actualStatusResult} && { ((iSuccessResults++)); true ; } || { ((iFailureResults++)); true ; }

  }
  fn__GetRemoteGitRepoName_test_003
  

  testIntent="${functionName} function will return __SUCCESS status and will not accept default repository name"
  function fn__GetRemoteGitRepoName_test_004 {
    local -r lDefaultGitRepoName="${__GIT_CLIENT_REMOTE_REPO_NAME}AAA"
    local outValidValueBack=""

    expectedStringResult=""
    expectedStatusResult=${__NO}

    ${functionName} "${lDefaultGitRepoName}" "outValidValueBack" <<<"N\n\nN\n" >/dev/null && actualStatusResult=$? || actualStatusResult=$?
    # [[ ${outValidValueBack} ]] && echo "____ ${LINENO}: ${functionName}: ${outValidValueBack}" 

    actualStringResult="${outValidValueBack}"
    assessReturnStatusAndStdOut \
      "${functionName}" \
      ${LINENO} \
      "${testIntent}" \
      "${expectedStringResult}" \
      ${expectedStatusResult} \
      "${actualStringResult}" \
      ${actualStatusResult} && { ((iSuccessResults++)); true ; } || { ((iFailureResults++)); true ; }
  }
  fn__GetRemoteGitRepoName_test_004


else 
  echo "   . Not running test for ${functionName}"
fi


# clean up
# rm -rfv ${_TEMP_DIR_PREFIX}[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]
rm -Rf ${_TEMP_DIR_}

echo "____ Executed $((iSuccessResults+iFailureResults)) tests"
echo "____ ${iSuccessResults} tests were successful"
echo "____ ${iFailureResults} tests failed"

exit ${iFailureResults}
