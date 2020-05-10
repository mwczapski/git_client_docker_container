#!/bin/bash
# #############################################
# The MIT License (MIT)
#
# Copyright © 2020 Michael Czapski
# #############################################


[[ ${__env_YesNoSuccessFailureContants} ]] || source ./utils/__env_YesNoSuccessFailureContants.sh
[[ ${fn__UtilityGeneric} ]] || source ./utils/fn__UtilityGeneric.sh


[[ ${_01_create_git_client_baseline_image_utils} ]] || source ./01_create_git_client_baseline_image_utils.sh


#_FORCE_RUNNING_ALL_TESTS_=${__YES}


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

## Dockerfile Version: 20200507_184625
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


#_FORCE_RUNNING_ALL_TESTS_=${__YES} # undefined 

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

if [[ ${_RUN_TEST_SET_} -eq ${__NO} || ${_FORCE_RUNNING_ALL_TESTS_} ]]; then

  testIntent="${functionName} function will return __FAILURE status, insufficient number of arguments and Usage message"
  functionInputs=""
  expectedStringResult="${__INSUFFICIENT_ARGS}"
  expectedStatusResult=${__FAILED}
  actualStringResult=$( ${functionName} ${functionInputs} ) && actualStatusResult=$? || actualStatusResult=$? 
  # [[ ${actualStringResult} ]] && echo "________ ${LINENO}: ${functionName}: ${actualStringResult}" 
  actualStringResult=${actualStringResult:0:${#expectedStringResult}}
  [[ "${actualStringResult}" == "${expectedStringResult}" && ${actualStatusResult} -eq ${expectedStatusResult} ]] && {
      echo "SUCCESS  ${LINENO}: ${functionName}: ${functionInputs} => ${expectedStringResult} == ${actualStringResult} (${actualStatusResult} -eq ${expectedStatusResult})" 
      ((iSuccessResults++)); true
    } || {
      echo "FAILURE ${LINENO}: ${functionName}: ${functionInputs} => ${expectedStringResult} != ${actualStringResult} (${actualStatusResult} -ne ${expectedStatusResult})" 
      ((iFailureResults++)); true
    }


  testIntent="${functionName} function will return __FAILURE status, insufficient number of arguments and Usage message"
  functionInputs="${_TEMP_DIR_}"
  expectedStringResult="${__INSUFFICIENT_ARGS}"
  expectedStatusResult=${__FAILED}
  actualStringResult=$( ${functionName} ${functionInputs} ) && actualStatusResult=$? || actualStatusResult=$? 
  # [[ ${actualStringResult} ]] && echo "________ ${LINENO}: ${functionName}: ${actualStringResult}" 
  actualStringResult=${actualStringResult:0:${#expectedStringResult}}
  [[ "${actualStringResult}" == "${expectedStringResult}" && ${actualStatusResult} -eq ${expectedStatusResult} ]] && {
      echo "SUCCESS  ${LINENO}: ${functionName}: ${functionInputs} => ${expectedStringResult} == ${actualStringResult} (${actualStatusResult} -eq ${expectedStatusResult})" 
      ((iSuccessResults++)); true
    } || {
      echo "FAILURE ${LINENO}: ${functionName}: ${functionInputs} => ${expectedStringResult} != ${actualStringResult} (${actualStatusResult} -ne ${expectedStatusResult})" 
      ((iFailureResults++)); true
    }


  testIntent="${functionName} function will return __SUCCESS status and will write docker-entrypoint.sh in the designated directory whose content is identical to the expected content"
  functionInputs="${_TEMP_DIR_} /bin/bash"
  expectedStringResult=""
  expectedStatusResult=${__SUCCESS}
  expectedContentSameResult=${__NO}
  actualStringResult=$( ${functionName} ${functionInputs} ) && actualStatusResult=$? || actualStatusResult=$? 
  [[ ${actualStringResult} ]] && echo "________ ${LINENO}: ${functionName}: ${actualStringResult}" 
  actualStringResult=${actualStringResult:0:${#expectedStringResult}}
  [[ "${actualStringResult}" == "${expectedStringResult}" && ${actualStatusResult} -eq ${expectedStatusResult} ]] && {
      cat ${_DOCKER_ENTRYPOINT_EXPECTED_} | sed 's|[0-9]\{8\}_[0-9]\{6\}|DDDDDDDD_TTTTTT|g' > ${_DOCKER_ENTRYPOINT_EXPECTED_}.masked
      cat ${_DOCKER_ENTRYPOINT_ACTUAL_} | sed 's|[0-9]\{8\}_[0-9]\{6\}|DDDDDDDD_TTTTTT|g' > ${_DOCKER_ENTRYPOINT_ACTUAL_}.masked
      diff -swq ${_DOCKER_ENTRYPOINT_EXPECTED_}.masked ${_DOCKER_ENTRYPOINT_ACTUAL_}.masked 1>/dev/null 2>&1 && STS=$? || STS=$?
      if [[ $STS -ne ${__THE_SAME} ]]
      then
        if [[ expectedContentSameResult -eq ${__YES} ]]
        then
          echo "FAILURE ${LINENO}: ${functionName}: ${functionInputs} => ${expectedStringResult} != ${actualStringResult} (${actualStatusResult} -ne ${expectedStatusResult}) - Different file content" 
          ((iFailureResults++)); true
        else
          echo "SUCCESS  ${LINENO}: ${functionName}: ${functionInputs} => ${expectedStringResult} == ${actualStringResult} (${actualStatusResult} -eq ${expectedStatusResult}) - Different file content" 
          ((iSuccessResults++)); true
        fi
      else 
        echo "SUCCESS  ${LINENO}: ${functionName}: ${functionInputs} => ${expectedStringResult} == ${actualStringResult} (${actualStatusResult} -eq ${expectedStatusResult})" 
        ((iSuccessResults++)); true
      fi
    } || {
      echo "FAILURE ${LINENO}: ${functionName}: ${functionInputs} => ${expectedStringResult} != ${actualStringResult} (${actualStatusResult} -ne ${expectedStatusResult})" 
      ((iFailureResults++)); true
    }

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

if [[ ${_RUN_TEST_SET_} -eq ${__NO} || ${_FORCE_RUNNING_ALL_TESTS_} ]]; then
  testIntent="${functionName} function will return __FAILURE status, insufficient number of arguments and Usage message"
  functionInputs=""
  expectedStringResult="${__INSUFFICIENT_ARGS}"
  expectedStatusResult=${__FAILED}
  actualStringResult=$( ${functionName} ${functionInputs} ) && actualStatusResult=$? || actualStatusResult=$? 
  actualStringResult=${actualStringResult:0:${#expectedStringResult}}
  # [[ ${actualStringResult} ]] && echo "________ ${LINENO}: ${functionName}: ${actualStringResult}" 
  [[ "${actualStringResult}" == "${expectedStringResult}" && ${actualStatusResult} -eq ${expectedStatusResult} ]] && {
      echo "SUCCESS  ${LINENO}: ${functionName}: ${functionInputs} => ${expectedStringResult} == ${actualStringResult} (${actualStatusResult} -eq ${expectedStatusResult})" 
      ((iSuccessResults++)); true
    } || {
      echo "FAILURE ${LINENO}: ${functionName}: ${functionInputs} => ${expectedStringResult} != ${actualStringResult} (${actualStatusResult} -ne ${expectedStatusResult})" 
      ((iFailureResults++)); true
    }


  testIntent="${functionName} function will return __FAILURE status, and a filure to match expected content"
  functionInputs="${_DOCKERFILE_ACTUAL_} img:1.0.0 gitx /bin/bashx .bashx_profile profilex /tmpx /opt/gitreposx Canada/Sydney Canada/Sydney"
  expectedStringResult=""
  expectedStatusResult=${__FAILED}
  expectedContentSameResult=${__NO}
  actualStringResult=$( ${functionName} ${functionInputs} ) && actualStatusResult=$? || actualStatusResult=$? 
  actualStringResult=${actualStringResult:0:${#expectedStringResult}}
  [[ ${actualStringResult} ]] && echo "________ ${LINENO}: ${functionName}: ${actualStringResult}" 
  [[ "${actualStringResult}" == "${expectedStringResult}" && ${actualStatusResult} -eq ${expectedStatusResult} ]] && {
      cat ${_DOCKERFILE_EXPECTED_} | sed 's|[0-9]\{8\}_[0-9]\{6\}|DDDDDDDD_TTTTTT|g' > ${_DOCKERFILE_EXPECTED_}.masked
      cat ${_DOCKERFILE_ACTUAL_} | sed 's|[0-9]\{8\}_[0-9]\{6\}|DDDDDDDD_TTTTTT|g' > ${_DOCKERFILE_ACTUAL_}.masked
      diff -swq ${_DOCKERFILE_EXPECTED_}.masked ${_DOCKERFILE_ACTUAL_}.masked 1>/dev/null 2>&1 && STS=$? || STS=$?
      if [[ $STS -ne ${__THE_SAME} ]]
      then
        if [[ expectedContentSameResult -eq ${__YES} ]]
        then
          echo "FAILURE ${LINENO}: ${functionName}: ${functionInputs} => ${expectedStringResult} != ${actualStringResult} (${actualStatusResult} -ne ${expectedStatusResult}) - Different file content" 
          ((iFailureResults++)); true
        else
          echo "SUCCESS  ${LINENO}: ${functionName}: ${functionInputs} => ${expectedStringResult} == ${actualStringResult} (${actualStatusResult} -eq ${expectedStatusResult}) - Different file content" 
          ((iSuccessResults++)); true
        fi
      else 
        echo "SUCCESS  ${LINENO}: ${functionName}: ${functionInputs} => ${expectedStringResult} == ${actualStringResult} (${actualStatusResult} -eq ${expectedStatusResult})" 
        ((iSuccessResults++)); true
      fi
    } || {
      echo "FAILURE ${LINENO}: ${functionName}: ${functionInputs} => ${expectedStringResult} != ${actualStringResult} (${actualStatusResult} -ne ${expectedStatusResult})" 
      ((iFailureResults++)); true
    }


  testIntent="${functionName} function will return __FAILURE status, and a filure to match expected content"
  functionInputs="${_DOCKERFILE_ACTUAL_} bitnami/minideb:jessie gitclient /bin/bash .bash_profile /etc/profile /home/gitclient /opt/gitrepos Australia/Sydney Australia/Sydney"
  expectedStringResult=""
  expectedStatusResult=${__SUCCESS}
  expectedContentSameResult=${__YES}
  actualStringResult=$( ${functionName} ${functionInputs} ) && actualStatusResult=$? || actualStatusResult=$? 
  # echo "actualStringResult:${actualStringResult}"
  # actualStringResult=${actualStringResult:0:${#expectedStringResult}}
  # echo "actualStringResult:${actualStringResult}"
  [[ ${actualStringResult} ]] && echo "________ ${LINENO}: ${functionName}: ${actualStringResult}" 
  [[ "${actualStringResult}" == "${expectedStringResult}" && ${actualStatusResult} -eq ${expectedStatusResult} ]] && {
      cat ${_DOCKERFILE_EXPECTED_} | sed 's|[0-9]\{8\}_[0-9]\{6\}|DDDDDDDD_TTTTTT|g' > ${_DOCKERFILE_EXPECTED_}.masked
      cat ${_DOCKERFILE_ACTUAL_} | sed 's|[0-9]\{8\}_[0-9]\{6\}|DDDDDDDD_TTTTTT|g' > ${_DOCKERFILE_ACTUAL_}.masked
      diff -swq ${_DOCKERFILE_EXPECTED_}.masked ${_DOCKERFILE_ACTUAL_}.masked 1>/dev/null 2>&1 && STS=$? || STS=$?
      if [[ $STS -ne ${__THE_SAME} ]]
      then
        if [[ expectedContentSameResult -eq ${__YES} ]]
        then
          echo "FAILURE ${LINENO}: ${functionName}: ${functionInputs} => ${expectedStringResult} != ${actualStringResult} (${actualStatusResult} -ne ${expectedStatusResult}) - Different file content" 
          ((iFailureResults++)); true
        else
          echo "SUCCESS  ${LINENO}: ${functionName}: ${functionInputs} => ${expectedStringResult} == ${actualStringResult} (${actualStatusResult} -eq ${expectedStatusResult}) - Different file content" 
          ((iSuccessResults++)); true
        fi
      else 
        echo "SUCCESS  ${LINENO}: ${functionName}: ${functionInputs} => ${expectedStringResult} == ${actualStringResult} (${actualStatusResult} -eq ${expectedStatusResult})" 
        ((iSuccessResults++)); true
      fi
    } || {
      echo "FAILURE ${LINENO}: ${functionName}: ${functionInputs} => ${expectedStringResult} != ${actualStringResult} (${actualStatusResult} -ne ${expectedStatusResult})" 
      ((iFailureResults++)); true
    }

else 
  echo "Not running test for ${functionName}"
fi

# clean up
rm -Rf ${_TEMP_DIR_}

echo "______ Executed $((iSuccessResults+iFailureResults)) tests"
echo "______ ${iSuccessResults} tests were successful"
echo "______ ${iFailureResults} tests failed"

exit ${iFailureResults}
