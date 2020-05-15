# #############################################
# The MIT License (MIT)
#
# Copyright © 2020 Michael Czapski
# #############################################

declare -u fn__WSLPathToDOSandWSDPaths_tests="SOURCED"

[[ ${__env_GlobalConstants} ]] || source ./utils/__env_GlobalConstants.sh
[[ ${fn__WSLPathToDOSandWSDPaths} ]] || source ./utils/fn__WSLPathToDOSandWSDPaths.sh

[[ ${bash_test_utils} ]] || source ./bash_test_utils/bash_test_utils.sh



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

## ############################################################################
## test sets
## ############################################################################


functionName="fn__WSLPathToWSDPath"

:<<-'------------Function_Usage_Note-------------------------------'
  Usage: 
    fn__WSLPathToWSDPath \
      ${WSLPath}
  Returns:
    ${__DONE}
    ${__FAILED}
  Expects in environment:
    Constants from __env_GlobalConstants
------------Function_Usage_Note-------------------------------

_RUN_TEST_SET_=${__YES}
if [[ ${_RUN_TEST_SET_} -eq ${__YES} || ${_FORCE_RUNNING_ALL_TESTS_} ]]
then

  testIntent="${functionName} will return __FAILURE, insufficient number of arguments and Usage message"
  function fn__WSLPathToWSDPath_test_001() {
    expectedStringResult=""
    expectedStatusResult=0

    actualStringResult=$( ${functionName} ) && actualStatusResult=$? || actualStatusResult=$? 
    [[ ${actualStringResult} ]] && echo "________ ${LINENO}: ${functionName}: ${actualStringResult}" 

    assessReturnStatusAndStdOut \
      "${functionName}" \
      ${LINENO} \
      "${testIntent}" \
      "${expectedStringResult}" \
      ${expectedStatusResult} \
      "${actualStringResult}" \
      ${actualStatusResult} && { ((iSuccessResults++)); true ; } || { ((iFailureResults++)); true ; }

    # [[ "${actualStringResult}" == "${expectedStringResult}" && ${actualStatusResult} -eq ${expectedStatusResult} ]] && {
    #     echo "SUCCESS  ${LINENO}: ${functionName}: ${functionInputs} => ${expectedStringResult} == ${actualStringResult} (${actualStatusResult} -eq ${expectedStatusResult})" 
    #     ((iSuccessResults++)); true
    #   } || {
    #     echo "FAILURE ${LINENO}: ${functionName}: ${functionInputs} => ${expectedStringResult} != ${actualStringResult} (${actualStatusResult} -ne ${expectedStatusResult})" 
    #     ((iFailureResults++)); true
    #   }
  }
  fn__WSLPathToWSDPath_test_001

  testIntent="${functionName} will return __SUCCESS and the the pseudo-DOS path"
  function fn__WSLPathToWSDPath_test_002() {
    functionInputs="/mnt/d/gitserver/gitserver/_commonUtils/utils"
    expectedStringResult="d:/gitserver/gitserver/_commonUtils/utils"
    expectedStatusResult=0

    actualStringResult=$( ${functionName} ${functionInputs} ) && actualStatusResult=$? || actualStatusResult=$? 
    [[ ${actualStringResult} ]] && echo "________ ${LINENO}: ${functionName}: ${actualStringResult}" 

    assessReturnStatusAndStdOut \
      "${functionName}" \
      ${LINENO} \
      "${testIntent}" \
      "${expectedStringResult}" \
      ${expectedStatusResult} \
      "${actualStringResult}" \
      ${actualStatusResult} && { ((iSuccessResults++)); true ; } || { ((iFailureResults++)); true ; }

    # [[ "${actualStringResult}" == "${expectedStringResult}" && ${actualStatusResult} -eq ${expectedStatusResult} ]] && {
    #     echo "SUCCESS  ${LINENO}: ${functionName}: ${functionInputs} => ${expectedStringResult} == ${actualStringResult} (${actualStatusResult} -eq ${expectedStatusResult})" 
    #     ((iSuccessResults++)); true
    #   } || {
    #     echo "FAILURE ${LINENO}: ${functionName}: ${functionInputs} => ${expectedStringResult} != ${actualStringResult} (${actualStatusResult} -ne ${expectedStatusResult})" 
    #     ((iFailureResults++)); true
    #   }
  }
  # fn__WSLPathToWSDPath_test_002


  # functionInputs="d:/gitserver/gitserver/_commonUtils/utils"
  # expectedStringResult="d:/gitserver/gitserver/_commonUtils/utils"
  # expectedStatusResult=0
  # actualStringResult=$( ${functionName} ${functionInputs} ) && actualStatusResult=$? || actualStatusResult=$? 
  # # [[ ${actualStringResult} ]] && echo "________ ${LINENO}: ${functionName}: ${actualStringResult}" 
  # [[ "${actualStringResult}" == "${expectedStringResult}" && ${actualStatusResult} -eq ${expectedStatusResult} ]] && {
  #     echo "SUCCESS  ${LINENO}: ${functionName}: ${functionInputs} => ${expectedStringResult} == ${actualStringResult} (${actualStatusResult} -eq ${expectedStatusResult})" 
  #     ((iSuccessResults++)); true
  #   } || {
  #     echo "FAILURE ${LINENO}: ${functionName}: ${functionInputs} => ${expectedStringResult} != ${actualStringResult} (${actualStatusResult} -ne ${expectedStatusResult})" 
  #     ((iFailureResults++)); true
  #   }

  # functionInputs="d:\gitserver\gitserver\_commonUtils\utils"
  # expectedStringResult="d:\gitserver\gitserver\_commonUtils\utils"
  # expectedStatusResult=0
  # actualStringResult=$( ${functionName} ${functionInputs} ) && actualStatusResult=$? || actualStatusResult=$? 
  # # [[ ${actualStringResult} ]] && echo "________ ${LINENO}: ${functionName}: ${actualStringResult}" 
  # [[ "${actualStringResult}" == "${expectedStringResult}" && ${actualStatusResult} -eq ${expectedStatusResult} ]] && {
  #     echo "SUCCESS  ${LINENO}: ${functionName}: ${functionInputs} => ${expectedStringResult} == ${actualStringResult} (${actualStatusResult} -eq ${expectedStatusResult})" 
  #     ((iSuccessResults++)); true
  #   } || {
  #     echo "FAILURE ${LINENO}: ${functionName}: ${functionInputs} => ${expectedStringResult} != ${actualStringResult} (${actualStatusResult} -ne ${expectedStatusResult})" 
  #     ((iFailureResults++)); true
  #   }

  # functionInputs="\gitserver/gitserver\_commonUtils/utils"
  # expectedStringResult="\gitserver/gitserver\_commonUtils/utils"
  # expectedStatusResult=0
  # actualStringResult=$( ${functionName} ${functionInputs} ) && actualStatusResult=$? || actualStatusResult=$? 
  # # [[ ${actualStringResult} ]] && echo "________ ${LINENO}: ${functionName}: ${actualStringResult}" 
  # [[ "${actualStringResult}" == "${expectedStringResult}" && ${actualStatusResult} -eq ${expectedStatusResult} ]] && {
  #     echo "SUCCESS  ${LINENO}: ${functionName}: ${functionInputs} => ${expectedStringResult} == ${actualStringResult} (${actualStatusResult} -eq ${expectedStatusResult})" 
  #     ((iSuccessResults++)); true
  #   } || {
  #     echo "FAILURE ${LINENO}: ${functionName}: ${functionInputs} => ${expectedStringResult} != ${actualStringResult} (${actualStatusResult} -ne ${expectedStatusResult})" 
  #     ((iFailureResults++)); true
  #   }

  # functionInputs=""
  # expectedStringResult=""
  # expectedStatusResult=0
  # actualStringResult=$( ${functionName} ${functionInputs} ) && actualStatusResult=$? || actualStatusResult=$? 
  # # [[ ${actualStringResult} ]] && echo "________ ${LINENO}: ${functionName}: ${actualStringResult}" 
  # [[ "${actualStringResult}" == "${expectedStringResult}" && ${actualStatusResult} -eq ${expectedStatusResult} ]] && {
  #     echo "SUCCESS  ${LINENO}: ${functionName}: ${functionInputs} => ${expectedStringResult} == ${actualStringResult} (${actualStatusResult} -eq ${expectedStatusResult})" 
  #     ((iSuccessResults++)); true
  #   } || {
  #     echo "FAILURE ${LINENO}: ${functionName}: ${functionInputs} => ${expectedStringResult} != ${actualStringResult} (${actualStatusResult} -ne ${expectedStatusResult})" 
  #     ((iFailureResults++)); true
  #   }

else 
  echo "Not running test for ${functionName}"
fi


# functionName="fn__WSLPathToRealDosPath"
# if [[ true -eq true ]]; then
#   echo "Not running test for ${functionName}"
# else 
#   functionInputs="/mnt/d/gitserver/gitserver/_commonUtils/utils"
#   expectedStringResult="d:\gitserver\gitserver\_commonUtils\utils"
#   expectedStatusResult=0
#   actualStringResult=$( ${functionName} ${functionInputs} ) && actualStatusResult=$? || actualStatusResult=$? 
#   # [[ ${actualStringResult} ]] && echo "________ ${LINENO}: ${functionName}: ${actualStringResult}" 
#   [[ "${actualStringResult}" == "${expectedStringResult}" && ${actualStatusResult} -eq ${expectedStatusResult} ]] && {
#       echo "SUCCESS  ${LINENO}: ${functionName}: ${functionInputs} => ${expectedStringResult} == ${actualStringResult} (${actualStatusResult} -eq ${expectedStatusResult})" 
#       ((iSuccessResults++)); true
#     } || {
#       echo "FAILURE ${LINENO}: ${functionName}: ${functionInputs} => ${expectedStringResult} != ${actualStringResult} (${actualStatusResult} -ne ${expectedStatusResult})" 
#       ((iFailureResults++)); true
#     }

#   functionInputs="d:/gitserver/gitserver/_commonUtils/utils"
#   expectedStringResult="d:\gitserver\gitserver\_commonUtils\utils"
#   expectedStatusResult=0
#   actualStringResult=$( ${functionName} ${functionInputs} ) && actualStatusResult=$? || actualStatusResult=$? 
#   # [[ ${actualStringResult} ]] && echo "________ ${LINENO}: ${functionName}: ${actualStringResult}" 
#   [[ "${actualStringResult}" == "${expectedStringResult}" && ${actualStatusResult} -eq ${expectedStatusResult} ]] && {
#       echo "SUCCESS  ${LINENO}: ${functionName}: ${functionInputs} => ${expectedStringResult} == ${actualStringResult} (${actualStatusResult} -eq ${expectedStatusResult})" 
#       ((iSuccessResults++)); true
#     } || {
#       echo "FAILURE ${LINENO}: ${functionName}: ${functionInputs} => ${expectedStringResult} != ${actualStringResult} (${actualStatusResult} -ne ${expectedStatusResult})" 
#       ((iFailureResults++)); true
#     }

#   functionInputs="d:\gitserver\gitserver\_commonUtils\utils"
#   expectedStringResult="d:\gitserver\gitserver\_commonUtils\utils"
#   expectedStatusResult=0
#   actualStringResult=$( ${functionName} ${functionInputs} ) && actualStatusResult=$? || actualStatusResult=$? 
#   # [[ ${actualStringResult} ]] && echo "________ ${LINENO}: ${functionName}: ${actualStringResult}" 
#   [[ "${actualStringResult}" == "${expectedStringResult}" && ${actualStatusResult} -eq ${expectedStatusResult} ]] && {
#       echo "SUCCESS  ${LINENO}: ${functionName}: ${functionInputs} => ${expectedStringResult} == ${actualStringResult} (${actualStatusResult} -eq ${expectedStatusResult})" 
#       ((iSuccessResults++)); true
#     } || {
#       echo "FAILURE ${LINENO}: ${functionName}: ${functionInputs} => ${expectedStringResult} != ${actualStringResult} (${actualStatusResult} -ne ${expectedStatusResult})" 
#       ((iFailureResults++)); true
#     }

#   functionInputs="\gitserver/gitserver\_commonUtils/utils"
#   expectedStringResult="\gitserver\gitserver\_commonUtils\utils"
#   expectedStatusResult=0
#   actualStringResult=$( ${functionName} ${functionInputs} ) && actualStatusResult=$? || actualStatusResult=$? 
#   # [[ ${actualStringResult} ]] && echo "________ ${LINENO}: ${functionName}: ${actualStringResult}" 
#   [[ "${actualStringResult}" == "${expectedStringResult}" && ${actualStatusResult} -eq ${expectedStatusResult} ]] && {
#       echo "SUCCESS  ${LINENO}: ${functionName}: ${functionInputs} => ${expectedStringResult} == ${actualStringResult} (${actualStatusResult} -eq ${expectedStatusResult})" 
#       ((iSuccessResults++)); true
#     } || {
#       echo "FAILURE ${LINENO}: ${functionName}: ${functionInputs} => ${expectedStringResult} != ${actualStringResult} (${actualStatusResult} -ne ${expectedStatusResult})" 
#       ((iFailureResults++)); true
#     }

#   functionInputs=""
#   expectedStringResult=""
#   expectedStatusResult=0
#   actualStringResult=$( ${functionName} ${functionInputs} ) && actualStatusResult=$? || actualStatusResult=$? 
#   # [[ ${actualStringResult} ]] && echo "________ ${LINENO}: ${functionName}: ${actualStringResult}" 
#   [[ "${actualStringResult}" == "${expectedStringResult}" && ${actualStatusResult} -eq ${expectedStatusResult} ]] && {
#       echo "SUCCESS  ${LINENO}: ${functionName}: ${functionInputs} => ${expectedStringResult} == ${actualStringResult} (${actualStatusResult} -eq ${expectedStatusResult})" 
#       ((iSuccessResults++)); true
#     } || {
#       echo "FAILURE ${LINENO}: ${functionName}: ${functionInputs} => ${expectedStringResult} != ${actualStringResult} (${actualStatusResult} -ne ${expectedStatusResult})" 
#       ((iFailureResults++)); true
#     }

# fi

echo "______ Executed $((iSuccessResults+iFailureResults)) tests"
echo "______ ${iSuccessResults} tests were successful"
echo "______ ${iFailureResults} tests failed"

exit ${iFailureResults}
