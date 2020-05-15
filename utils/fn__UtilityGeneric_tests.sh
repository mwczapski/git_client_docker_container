# #############################################
# The MIT License (MIT)
#
# Copyright © 2020 Michael Czapski
# #############################################

declare -u fn__UtilityGeneric_tests="SOURCED"

[[ ${__env_GlobalConstants} ]] || source ./utils/__env_GlobalConstants.sh
[[ ${fn__UtilityGeneric} ]] || source ./utils/fn__UtilityGeneric.sh

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


functionName="fn__IsValidRegEx"
:<<-'------------Function_Usage_Note-------------------------------'
  Usage:
    fn__IsValidRegEx \
      ${ShellRegEx} \
  Returns:
    ${__SUCCESS}
    ${__FAILED}
  Expects in environment:
    Constants from __env_GlobalConstants
------------Function_Usage_Note-------------------------------

_RUN_TEST_SET_=${__NO}
if [[ ${_RUN_TEST_SET_} -eq ${__YES} || ${_FORCE_RUNNING_ALL_TESTS_} ]]
then

  testIntent="${functionName} function will return __FAILED and 'Requires a shell regex to validate'"
  function fn__IsValidRegEx_test_001 {

    expectedStringResult="______ Requires a shell regex to validate"
    expectedStatusResult=${__FAILED}

    actualStringResult=$( ${functionName} ) && actualStatusResult=$? || actualStatusResult=$?
    # [[ ${actualStringResult} ]] && echo "______ ${LINENO}: ${functionName}: ${actualStringResult}" 

    assessReturnStatusAndStdOut \
      "${functionName}" \
      ${LINENO} \
      "${testIntent}" \
      "${expectedStringResult}" \
      ${expectedStatusResult} \
      "${actualStringResult}" \
      ${actualStatusResult} && { ((iSuccessResults++)); true ; } || { ((iFailureResults++)); true ; }
  }
  fn__IsValidRegEx_test_001


  testIntent="${functionName} will return __SUCCESS and string literal 'VALID'"
  function fn__IsValidRegEx_test_002 {
    local -r lrRegEx="[a-zA-Z]"

    expectedStringResult="VALID"
    expectedStatusResult=${__SUCCESS}

    actualStringResult=$( ${functionName} "${lrRegEx}" ) && actualStatusResult=$? || actualStatusResult=$?
    # [[ ${actualStringResult} ]] && echo "______ ${LINENO}: ${functionName}: ${actualStringResult}" 

    assessReturnStatusAndStdOut \
      "${functionName}" \
      ${LINENO} \
      "${testIntent}" \
      "${expectedStringResult}" \
      ${expectedStatusResult} \
      "${actualStringResult}" \
      ${actualStatusResult} && { ((iSuccessResults++)); true ; } || { ((iFailureResults++)); true ; }

  }
  fn__IsValidRegEx_test_002


  testIntent="${functionName} will return __SUCCESS and string literal 'VALID'"
  function fn__IsValidRegEx_test_003 {
    local -r lrRegEx="[a-z A-Z]"

    expectedStringResult="VALID"
    expectedStatusResult=${__SUCCESS}

    actualStringResult=$( ${functionName} "${lrRegEx}" ) && actualStatusResult=$? || actualStatusResult=$?
    # [[ ${actualStringResult} ]] && echo "______ ${LINENO}: ${functionName}: ${actualStringResult}" 

    assessReturnStatusAndStdOut \
      "${functionName}" \
      ${LINENO} \
      "${testIntent}" \
      "${expectedStringResult}" \
      ${expectedStatusResult} \
      "${actualStringResult}" \
      ${actualStatusResult} && { ((iSuccessResults++)); true ; } || { ((iFailureResults++)); true ; }

  }
  fn__IsValidRegEx_test_003


  testIntent="${functionName} will return __SUCCESS and string literal 'VALID'"
  function fn__IsValidRegEx_test_004 {
    local -r lrRegEx="[a-z]"

    expectedStringResult="VALID"
    expectedStatusResult=${__SUCCESS}

    actualStringResult=$( ${functionName} "${lrRegEx}" ) && actualStatusResult=$? || actualStatusResult=$?
    # [[ ${actualStringResult} ]] && echo "______ ${LINENO}: ${functionName}: ${actualStringResult}" 

    assessReturnStatusAndStdOut \
      "${functionName}" \
      ${LINENO} \
      "${testIntent}" \
      "${expectedStringResult}" \
      ${expectedStatusResult} \
      "${actualStringResult}" \
      ${actualStatusResult} && { ((iSuccessResults++)); true ; } || { ((iFailureResults++)); true ; }

  }
  fn__IsValidRegEx_test_004


  testIntent="${functionName} will return __FAILED and '______ Alleged regular expression '[a-z' must start with [ and end with ]'"
  function fn__IsValidRegEx_test_005 {
    local -r lrRegEx="[a-z"

    expectedStringResult="______ Alleged regular expression '[a-z' must start with [ and end with ]"
    expectedStatusResult=${__FAILED}

    actualStringResult=$( ${functionName} "${lrRegEx}" ) && actualStatusResult=$? || actualStatusResult=$?
    # [[ ${actualStringResult} ]] && echo "______ ${LINENO}: ${functionName}: ${actualStringResult}" 

    assessReturnStatusAndStdOut \
      "${functionName}" \
      ${LINENO} \
      "${testIntent}" \
      "${expectedStringResult}" \
      ${expectedStatusResult} \
      "${actualStringResult}" \
      ${actualStatusResult} && { ((iSuccessResults++)); true ; } || { ((iFailureResults++)); true ; }

  }
  fn__IsValidRegEx_test_005


  testIntent="${functionName} will return __FAILED and '______ Alleged regular expression 'a-z]' must start with [ and end with ]'"
  function fn__IsValidRegEx_test_006 {
    local -r lrRegEx="a-z]"

    expectedStringResult="______ Alleged regular expression 'a-z]' must start with [ and end with ]"
    expectedStatusResult=${__FAILED}

    actualStringResult=$( ${functionName} "${lrRegEx}" ) && actualStatusResult=$? || actualStatusResult=$?
    # [[ ${actualStringResult} ]] && echo "______ ${LINENO}: ${functionName}: ${actualStringResult}" 

    assessReturnStatusAndStdOut \
      "${functionName}" \
      ${LINENO} \
      "${testIntent}" \
      "${expectedStringResult}" \
      ${expectedStatusResult} \
      "${actualStringResult}" \
      ${actualStatusResult} && { ((iSuccessResults++)); true ; } || { ((iFailureResults++)); true ; }

  }
  fn__IsValidRegEx_test_006


  testIntent="${functionName} will return __FAILED and '______ Alleged regular expression 'a-z' must start with [ and end with ]'"
  function fn__IsValidRegEx_test_007 {
    local -r lrRegEx="a-z"

    expectedStringResult="______ Alleged regular expression 'a-z' must start with [ and end with ]"
    expectedStatusResult=${__FAILED}

    actualStringResult=$( ${functionName} "${lrRegEx}" ) && actualStatusResult=$? || actualStatusResult=$?
    # [[ ${actualStringResult} ]] && echo "______ ${LINENO}: ${functionName}: ${actualStringResult}" 

    assessReturnStatusAndStdOut \
      "${functionName}" \
      ${LINENO} \
      "${testIntent}" \
      "${expectedStringResult}" \
      ${expectedStatusResult} \
      "${actualStringResult}" \
      ${actualStatusResult} && { ((iSuccessResults++)); true ; } || { ((iFailureResults++)); true ; }

  }
  fn__IsValidRegEx_test_007


  testIntent="${functionName} will return __FAILED and '______ Alleged regular expression 'a-' must be at least 3 characters long'"
  function fn__IsValidRegEx_test_008 {
    local -r lrRegEx="a-"

    expectedStringResult="______ Alleged regular expression 'a-' must be at least 3 characters long"
    expectedStatusResult=${__FAILED}

    actualStringResult=$( ${functionName} "${lrRegEx}" ) && actualStatusResult=$? || actualStatusResult=$?
    # [[ ${actualStringResult} ]] && echo "______ ${LINENO}: ${functionName}: ${actualStringResult}" 

    assessReturnStatusAndStdOut \
      "${functionName}" \
      ${LINENO} \
      "${testIntent}" \
      "${expectedStringResult}" \
      ${expectedStatusResult} \
      "${actualStringResult}" \
      ${actualStatusResult} && { ((iSuccessResults++)); true ; } || { ((iFailureResults++)); true ; }

  }
  fn__IsValidRegEx_test_008


  testIntent="${functionName} will return __SUCCESS and a string literal 'VALID'"
  function fn__IsValidRegEx_test_009 {
    local -r lrRegEx="[this is a test]"

    expectedStringResult="VALID"
    expectedStatusResult=${__SUCCESS}

    actualStringResult=$( ${functionName} "${lrRegEx}" ) && actualStatusResult=$? || actualStatusResult=$?
    # [[ ${actualStringResult} ]] && echo "______ ${LINENO}: ${functionName}: ${actualStringResult}" 

    assessReturnStatusAndStdOut \
      "${functionName}" \
      ${LINENO} \
      "${testIntent}" \
      "${expectedStringResult}" \
      ${expectedStatusResult} \
      "${actualStringResult}" \
      ${actualStatusResult} && { ((iSuccessResults++)); true ; } || { ((iFailureResults++)); true ; }

  }
  fn__IsValidRegEx_test_009


  testIntent="${functionName} will return __SUCCESS and a string literal 'VALID'"
  function fn__IsValidRegEx_test_010 {
    local -r lrRegEx="[a-zA-Z0-9]"

    expectedStringResult="VALID"
    expectedStatusResult=${__SUCCESS}

    actualStringResult=$( ${functionName} "${lrRegEx}" ) && actualStatusResult=$? || actualStatusResult=$?
    # [[ ${actualStringResult} ]] && echo "______ ${LINENO}: ${functionName}: ${actualStringResult}" 

    assessReturnStatusAndStdOut \
      "${functionName}" \
      ${LINENO} \
      "${testIntent}" \
      "${expectedStringResult}" \
      ${expectedStatusResult} \
      "${actualStringResult}" \
      ${actualStatusResult} && { ((iSuccessResults++)); true ; } || { ((iFailureResults++)); true ; }

  }
  fn__IsValidRegEx_test_010


  testIntent="${functionName} will return __SUCCESS and a string literal 'VALID'"
  function fn__IsValidRegEx_test_011 {
    local -r lrRegEx="[a-zA-]"

    expectedStringResult="VALID"
    expectedStatusResult=${__SUCCESS}

    actualStringResult=$( ${functionName} "${lrRegEx}" ) && actualStatusResult=$? || actualStatusResult=$?
    # [[ ${actualStringResult} ]] && echo "______ ${LINENO}: ${functionName}: ${actualStringResult}" 

    assessReturnStatusAndStdOut \
      "${functionName}" \
      ${LINENO} \
      "${testIntent}" \
      "${expectedStringResult}" \
      ${expectedStatusResult} \
      "${actualStringResult}" \
      ${actualStatusResult} && { ((iSuccessResults++)); true ; } || { ((iFailureResults++)); true ; }

  }
  fn__IsValidRegEx_test_011

else 
  echo "     . Not running test for ${functionName}"
fi



functionName="fn__SanitizeInput"
:<<-'------------Function_Usage_Note-------------------------------'
  Usage:
    fn__SanitizeInput \
      "${ShellRegEx}" \
      "${StringToSanitize}" \
  Returns:
    ${__SUCCESS}
    ${__FAILED}
  Expects in environment:
    Constants from __env_GlobalConstants
------------Function_Usage_Note-------------------------------

_RUN_TEST_SET_=${__NO}
if [[ ${_RUN_TEST_SET_} -eq ${__YES} || ${_FORCE_RUNNING_ALL_TESTS_} ]]
then

  testIntent="${functionName} function will return __FAILED and '______ Requires shell regex to use to determine valid characters and eliminate all that do not match'"
  function fn__SanitizeInput_test_001 {

    expectedStringResult="______ Requires shell regex to use to determine valid characters and eliminate all that do not match"
    expectedStatusResult=${__FAILED}

    actualStringResult=$( ${functionName} ) && actualStatusResult=$? || actualStatusResult=$?
    # [[ ${actualStringResult} ]] && echo "______ ${LINENO}: ${functionName}: ${actualStringResult}" 

    assessReturnStatusAndStdOut \
      "${functionName}" \
      ${LINENO} \
      "${testIntent}" \
      "${expectedStringResult}" \
      ${expectedStatusResult} \
      "${actualStringResult}" \
      ${actualStatusResult} && { ((iSuccessResults++)); true ; } || { ((iFailureResults++)); true ; }
  }
  fn__SanitizeInput_test_001


  testIntent="${functionName} function will return __FAILED and '______ Require string to sanitize'"
  function fn__SanitizeInput_test_002 {
    local -r lrRegEx="[a-zA-Z]"

    expectedStringResult="______ Require string to sanitize"
    expectedStatusResult=${__FAILED}

    actualStringResult=$( ${functionName} "${lrRegEx}" ) && actualStatusResult=$? || actualStatusResult=$?
    # [[ ${actualStringResult} ]] && echo "______ ${LINENO}: ${functionName}: ${actualStringResult}" 

    assessReturnStatusAndStdOut \
      "${functionName}" \
      ${LINENO} \
      "${testIntent}" \
      "${expectedStringResult}" \
      ${expectedStatusResult} \
      "${actualStringResult}" \
      ${actualStatusResult} && { ((iSuccessResults++)); true ; } || { ((iFailureResults++)); true ; }
  }
  fn__SanitizeInput_test_002


  testIntent="${functionName} function will return __SUCCESS and sanitized string"
  function fn__SanitizeInput_test_003 {
    local -r lrRegEx="[a-zA-Z]"
    local -r lrInputStr="ala_ma_kota"

    expectedStringResult="alamakota"
    expectedStatusResult=${__SUCCESS}

    actualStringResult=$( ${functionName} "${lrRegEx}" "${lrInputStr}" ) && actualStatusResult=$? || actualStatusResult=$?
    # [[ ${actualStringResult} ]] && echo "______ ${LINENO}: ${functionName}: ${actualStringResult}" 

    assessReturnStatusAndStdOut \
      "${functionName}" \
      ${LINENO} \
      "${testIntent}" \
      "${expectedStringResult}" \
      ${expectedStatusResult} \
      "${actualStringResult}" \
      ${actualStatusResult} && { ((iSuccessResults++)); true ; } || { ((iFailureResults++)); true ; }
  }
  fn__SanitizeInput_test_003


  testIntent="${functionName} function will return __SUCCESS and sanitized string"
  function fn__SanitizeInput_test_004 {
    local -r lrRegEx="[a-zA-Z]"
    local -r lrInputStr="ala ma kota"

    expectedStringResult="alamakota"
    expectedStatusResult=${__SUCCESS}

    actualStringResult=$( ${functionName} "${lrRegEx}" "${lrInputStr}" ) && actualStatusResult=$? || actualStatusResult=$?
    # [[ ${actualStringResult} ]] && echo "______ ${LINENO}: ${functionName}: ${actualStringResult}" 

    assessReturnStatusAndStdOut \
      "${functionName}" \
      ${LINENO} \
      "${testIntent}" \
      "${expectedStringResult}" \
      ${expectedStatusResult} \
      "${actualStringResult}" \
      ${actualStatusResult} && { ((iSuccessResults++)); true ; } || { ((iFailureResults++)); true ; }
  }
  fn__SanitizeInput_test_004


  testIntent="${functionName} function will return __SUCCESS and sanitized string"
  function fn__SanitizeInput_test_005 {
    local -r lrRegEx="[a-z]"
    local -r lrInputStr="'This is A Test'"

    expectedStringResult="hisisest"
    expectedStatusResult=${__SUCCESS}

    actualStringResult=$( ${functionName} "${lrRegEx}" "${lrInputStr}" ) && actualStatusResult=$? || actualStatusResult=$?
    # [[ ${actualStringResult} ]] && echo "______ ${LINENO}: ${functionName}: ${actualStringResult}" 

    assessReturnStatusAndStdOut \
      "${functionName}" \
      ${LINENO} \
      "${testIntent}" \
      "${expectedStringResult}" \
      ${expectedStatusResult} \
      "${actualStringResult}" \
      ${actualStatusResult} && { ((iSuccessResults++)); true ; } || { ((iFailureResults++)); true ; }
  }
  fn__SanitizeInput_test_005


  testIntent="${functionName} function will return __SUCCESS and sanitized string"
  function fn__SanitizeInput_test_006 {
    local -r lrRegEx="[a-zA-Z _]"
    local -r lrInputStr="'This_is\ A Test'"

    expectedStringResult="This_is A Test"
    expectedStatusResult=${__SUCCESS}

    actualStringResult=$( ${functionName} "${lrRegEx}" "${lrInputStr}" ) && actualStatusResult=$? || actualStatusResult=$?
    # [[ ${actualStringResult} ]] && echo "______ ${LINENO}: ${functionName}: ${actualStringResult}" 

    assessReturnStatusAndStdOut \
      "${functionName}" \
      ${LINENO} \
      "${testIntent}" \
      "${expectedStringResult}" \
      ${expectedStatusResult} \
      "${actualStringResult}" \
      ${actualStatusResult} && { ((iSuccessResults++)); true ; } || { ((iFailureResults++)); true ; }
  }
  fn__SanitizeInput_test_006


  testIntent="${functionName} function will return __SUCCESS and sanitized string"
  function fn__SanitizeInput_test_007 {
    local -r lrRegEx="[a-zA-Z ]"
    local -r lrInputStr="'This_is\ A Test'"

    expectedStringResult="Thisis A Test"
    expectedStatusResult=${__SUCCESS}

    actualStringResult=$( ${functionName} "${lrRegEx}" "${lrInputStr}" ) && actualStatusResult=$? || actualStatusResult=$?
    # [[ ${actualStringResult} ]] && echo "______ ${LINENO}: ${functionName}: ${actualStringResult}" 

    assessReturnStatusAndStdOut \
      "${functionName}" \
      ${LINENO} \
      "${testIntent}" \
      "${expectedStringResult}" \
      ${expectedStatusResult} \
      "${actualStringResult}" \
      ${actualStatusResult} && { ((iSuccessResults++)); true ; } || { ((iFailureResults++)); true ; }
  }
  fn__SanitizeInput_test_007


  testIntent="${functionName} function will return __SUCCESS and sanitized string"
  function fn__SanitizeInput_test_008 {
    local -r lrRegEx="[a-zA-Z_]"
    local -r lrInputStr="'This_is\ A Test'"

    expectedStringResult="This_isATest"
    expectedStatusResult=${__SUCCESS}

    actualStringResult=$( ${functionName} "${lrRegEx}" "${lrInputStr}" ) && actualStatusResult=$? || actualStatusResult=$?
    # [[ ${actualStringResult} ]] && echo "______ ${LINENO}: ${functionName}: ${actualStringResult}" 

    assessReturnStatusAndStdOut \
      "${functionName}" \
      ${LINENO} \
      "${testIntent}" \
      "${expectedStringResult}" \
      ${expectedStatusResult} \
      "${actualStringResult}" \
      ${actualStatusResult} && { ((iSuccessResults++)); true ; } || { ((iFailureResults++)); true ; }
  }
  fn__SanitizeInput_test_008

else 
  echo "     . Not running test for ${functionName}"
fi



functionName="fn__SanitizeInputAlphaNum"
:<<-'------------Function_Usage_Note-------------------------------'
  Usage:
    fn__SanitizeInputAlphaNum \
      "${StringToSanitize}" \
  Returns:
    ${__SUCCESS}
    ${__FAILED}
  Expects in environment:
    Constants from __env_GlobalConstants
------------Function_Usage_Note-------------------------------

_RUN_TEST_SET_=${__NO}
if [[ ${_RUN_TEST_SET_} -eq ${__YES} || ${_FORCE_RUNNING_ALL_TESTS_} ]]
then

  testIntent="${functionName} function will return __FAILED and '______ Require string which to sanitize'"
  function fn__SanitizeInputAlphaNum_test_001 {

    expectedStringResult="______ Require string which to sanitize"
    expectedStatusResult=${__FAILED}

    actualStringResult=$( ${functionName} ) && actualStatusResult=$? || actualStatusResult=$?
    # [[ ${actualStringResult} ]] && echo "______ ${LINENO}: ${functionName}: ${actualStringResult}" 

    assessReturnStatusAndStdOut \
      "${functionName}" \
      ${LINENO} \
      "${testIntent}" \
      "${expectedStringResult}" \
      ${expectedStatusResult} \
      "${actualStringResult}" \
      ${actualStatusResult} && { ((iSuccessResults++)); true ; } || { ((iFailureResults++)); true ; }
  }
  fn__SanitizeInputAlphaNum_test_001


  testIntent="${functionName} function will return __SUCCESS and sanitized string"
  function fn__SanitizeInputAlphaNum_test_002 {
    local -r lrInputStr="ala_ma_kota"

    expectedStringResult="alamakota"
    expectedStatusResult=${__SUCCESS}

    actualStringResult=$( ${functionName} "${lrInputStr}" ) && actualStatusResult=$? || actualStatusResult=$?
    # [[ ${actualStringResult} ]] && echo "______ ${LINENO}: ${functionName}: ${actualStringResult}" 

    assessReturnStatusAndStdOut \
      "${functionName}" \
      ${LINENO} \
      "${testIntent}" \
      "${expectedStringResult}" \
      ${expectedStatusResult} \
      "${actualStringResult}" \
      ${actualStatusResult} && { ((iSuccessResults++)); true ; } || { ((iFailureResults++)); true ; }
  }
  fn__SanitizeInputAlphaNum_test_002

  
  testIntent="${functionName} function will return __SUCCESS and sanitized string"
  function fn__SanitizeInputAlphaNum_test_003 {
    local -r lrInputStr="ala ma kota_1234"

    expectedStringResult="alamakota1234"
    expectedStatusResult=${__SUCCESS}

    actualStringResult=$( ${functionName} "${lrInputStr}" ) && actualStatusResult=$? || actualStatusResult=$?
    # [[ ${actualStringResult} ]] && echo "______ ${LINENO}: ${functionName}: ${actualStringResult}" 

    assessReturnStatusAndStdOut \
      "${functionName}" \
      ${LINENO} \
      "${testIntent}" \
      "${expectedStringResult}" \
      ${expectedStatusResult} \
      "${actualStringResult}" \
      ${actualStatusResult} && { ((iSuccessResults++)); true ; } || { ((iFailureResults++)); true ; }
  }
  fn__SanitizeInputAlphaNum_test_003


  testIntent="${functionName} function will return __SUCCESS and sanitized string"
  function fn__SanitizeInputAlphaNum_test_004 {
    local -r lrInputStr="Z me@this+Place&'ala ma kota'"

    expectedStringResult="ZmethisPlacealamakota"
    expectedStatusResult=${__SUCCESS}

    actualStringResult=$( ${functionName} "${lrInputStr}" ) && actualStatusResult=$? || actualStatusResult=$?
    # [[ ${actualStringResult} ]] && echo "______ ${LINENO}: ${functionName}: ${actualStringResult}" 

    assessReturnStatusAndStdOut \
      "${functionName}" \
      ${LINENO} \
      "${testIntent}" \
      "${expectedStringResult}" \
      ${expectedStatusResult} \
      "${actualStringResult}" \
      ${actualStatusResult} && { ((iSuccessResults++)); true ; } || { ((iFailureResults++)); true ; }
  }
  fn__SanitizeInputAlphaNum_test_004

else 
  echo "     . Not running test for ${functionName}"
fi



functionName="fn__SanitizeInputAlpha"
:<<-'------------Function_Usage_Note-------------------------------'
  Usage:
    fn__SanitizeInputAlpha \
      "${StringToSanitize}" \
  Returns:
    ${__SUCCESS}
    ${__FAILED}
  Expects in environment:
    Constants from __env_GlobalConstants
------------Function_Usage_Note-------------------------------

_RUN_TEST_SET_=${__NO}
if [[ ${_RUN_TEST_SET_} -eq ${__YES} || ${_FORCE_RUNNING_ALL_TESTS_} ]]
then

  testIntent="${functionName} function will return __FAILED and '______ Require string which to sanitize'"
  function fn__SanitizeInputAlpha_test_001 {

    expectedStringResult="______ Require string which to sanitize"
    expectedStatusResult=${__FAILED}

    actualStringResult=$( ${functionName} ) && actualStatusResult=$? || actualStatusResult=$?
    # [[ ${actualStringResult} ]] && echo "______ ${LINENO}: ${functionName}: ${actualStringResult}" 

    assessReturnStatusAndStdOut \
      "${functionName}" \
      ${LINENO} \
      "${testIntent}" \
      "${expectedStringResult}" \
      ${expectedStatusResult} \
      "${actualStringResult}" \
      ${actualStatusResult} && { ((iSuccessResults++)); true ; } || { ((iFailureResults++)); true ; }
  }
  fn__SanitizeInputAlpha_test_001


  testIntent="${functionName} function will return __SUCCESS and sanitized string"
  function fn__SanitizeInputAlpha_test_002 {
    local -r lrInputStr="ala_ma_kota"

    expectedStringResult="alamakota"
    expectedStatusResult=${__SUCCESS}

    actualStringResult=$( ${functionName} "${lrInputStr}" ) && actualStatusResult=$? || actualStatusResult=$?
    # [[ ${actualStringResult} ]] && echo "______ ${LINENO}: ${functionName}: ${actualStringResult}" 

    assessReturnStatusAndStdOut \
      "${functionName}" \
      ${LINENO} \
      "${testIntent}" \
      "${expectedStringResult}" \
      ${expectedStatusResult} \
      "${actualStringResult}" \
      ${actualStatusResult} && { ((iSuccessResults++)); true ; } || { ((iFailureResults++)); true ; }
  }
  fn__SanitizeInputAlpha_test_002


  testIntent="${functionName} function will return __SUCCESS and sanitized string"
  function fn__SanitizeInputAlpha_test_003 {
    local -r lrInputStr="ala ma kota_1234"

    expectedStringResult="alamakota"
    expectedStatusResult=${__SUCCESS}

    actualStringResult=$( ${functionName} "${lrInputStr}" ) && actualStatusResult=$? || actualStatusResult=$?
    # [[ ${actualStringResult} ]] && echo "______ ${LINENO}: ${functionName}: ${actualStringResult}" 

    assessReturnStatusAndStdOut \
      "${functionName}" \
      ${LINENO} \
      "${testIntent}" \
      "${expectedStringResult}" \
      ${expectedStatusResult} \
      "${actualStringResult}" \
      ${actualStatusResult} && { ((iSuccessResults++)); true ; } || { ((iFailureResults++)); true ; }
  }
  fn__SanitizeInputAlpha_test_003


  testIntent="${functionName} function will return __SUCCESS and sanitized string"
  function fn__SanitizeInputAlpha_test_004 {
    local -r lrInputStr="Z me@this+Place&'ala ma kota'"

    expectedStringResult="ZmethisPlacealamakota"
    expectedStatusResult=${__SUCCESS}

    actualStringResult=$( ${functionName} "${lrInputStr}" ) && actualStatusResult=$? || actualStatusResult=$?
    # [[ ${actualStringResult} ]] && echo "______ ${LINENO}: ${functionName}: ${actualStringResult}" 

    assessReturnStatusAndStdOut \
      "${functionName}" \
      ${LINENO} \
      "${testIntent}" \
      "${expectedStringResult}" \
      ${expectedStatusResult} \
      "${actualStringResult}" \
      ${actualStatusResult} && { ((iSuccessResults++)); true ; } || { ((iFailureResults++)); true ; }
  }
  fn__SanitizeInputAlpha_test_004

else 
  echo "     . Not running test for ${functionName}"
fi



functionName="fn__SanitizeInputNumeric"
:<<-'------------Function_Usage_Note-------------------------------'
  Usage:
    fn__SanitizeInputNumeric \
      "${StringToSanitize}" \
  Returns:
    ${__SUCCESS}
    ${__FAILED}
  Expects in environment:
    Constants from __env_GlobalConstants
------------Function_Usage_Note-------------------------------

_RUN_TEST_SET_=${__NO}
if [[ ${_RUN_TEST_SET_} -eq ${__YES} || ${_FORCE_RUNNING_ALL_TESTS_} ]]
then

  testIntent="${functionName} function will return __FAILED and '______ Require string which to sanitize'"
  function fn__SanitizeInputNumeric_test_001 {

    expectedStringResult="______ Require string which to sanitize"
    expectedStatusResult=${__FAILED}

    actualStringResult=$( ${functionName} ) && actualStatusResult=$? || actualStatusResult=$?
    # [[ ${actualStringResult} ]] && echo "______ ${LINENO}: ${functionName}: ${actualStringResult}" 

    assessReturnStatusAndStdOut \
      "${functionName}" \
      ${LINENO} \
      "${testIntent}" \
      "${expectedStringResult}" \
      ${expectedStatusResult} \
      "${actualStringResult}" \
      ${actualStatusResult} && { ((iSuccessResults++)); true ; } || { ((iFailureResults++)); true ; }
  }
  fn__SanitizeInputNumeric_test_001


  testIntent="${functionName} function will return __SUCCESS and sanitized string"
  function fn__SanitizeInputNumeric_test_002 {
    local -r lrInputStr="ala_ma_kota"

    expectedStringResult=""
    expectedStatusResult=${__SUCCESS}

    actualStringResult=$( ${functionName} "${lrInputStr}" ) && actualStatusResult=$? || actualStatusResult=$?
    # [[ ${actualStringResult} ]] && echo "______ ${LINENO}: ${functionName}: ${actualStringResult}" 

    assessReturnStatusAndStdOut \
      "${functionName}" \
      ${LINENO} \
      "${testIntent}" \
      "${expectedStringResult}" \
      ${expectedStatusResult} \
      "${actualStringResult}" \
      ${actualStatusResult} && { ((iSuccessResults++)); true ; } || { ((iFailureResults++)); true ; }
  }
  fn__SanitizeInputNumeric_test_002


  testIntent="${functionName} function will return __SUCCESS and sanitized string"
  function fn__SanitizeInputNumeric_test_003 {
    local -r lrInputStr="ala ma kota_1234"

    expectedStringResult="1234"
    expectedStatusResult=${__SUCCESS}

    actualStringResult=$( ${functionName} "${lrInputStr}" ) && actualStatusResult=$? || actualStatusResult=$?
    # [[ ${actualStringResult} ]] && echo "______ ${LINENO}: ${functionName}: ${actualStringResult}" 

    assessReturnStatusAndStdOut \
      "${functionName}" \
      ${LINENO} \
      "${testIntent}" \
      "${expectedStringResult}" \
      ${expectedStatusResult} \
      "${actualStringResult}" \
      ${actualStatusResult} && { ((iSuccessResults++)); true ; } || { ((iFailureResults++)); true ; }
  }
  fn__SanitizeInputNumeric_test_003


  testIntent="${functionName} function will return __SUCCESS and sanitized string"
  function fn__SanitizeInputNumeric_test_004 {
    local -r lrInputStr="Z me@this+2Place3&'4ala _\5ma k6ota'"

    expectedStringResult="23456"
    expectedStatusResult=${__SUCCESS}

    actualStringResult=$( ${functionName} "${lrInputStr}" ) && actualStatusResult=$? || actualStatusResult=$?
    # [[ ${actualStringResult} ]] && echo "______ ${LINENO}: ${functionName}: ${actualStringResult}" 

    assessReturnStatusAndStdOut \
      "${functionName}" \
      ${LINENO} \
      "${testIntent}" \
      "${expectedStringResult}" \
      ${expectedStatusResult} \
      "${actualStringResult}" \
      ${actualStatusResult} && { ((iSuccessResults++)); true ; } || { ((iFailureResults++)); true ; }
  }
  fn__SanitizeInputNumeric_test_004

else 
  echo "     . Not running test for ${functionName}"
fi



functionName="fn__FileSameButForDate"
:<<-'------------Function_Usage_Note-------------------------------'
  Usage: 
    fn__FileSameButForDate 
      ${__FIRST_FILE_PATH} 
      ${__SECOND_FILE_PATH}
  Returns:
    ${__THE_SAME}
    ${__DIFFERENT}
    ${__FAILED}
  Expects in environment:
    Constants from __env_GlobalConstants
------------Function_Usage_Note-------------------------------

_RUN_TEST_SET_=${__NO}
if [[ ${_RUN_TEST_SET_} -eq ${__YES} || ${_FORCE_RUNNING_ALL_TESTS_} ]]
then

  mkdir -p ${_TEMP_DIR_}

  testIntent="${functionName} function will return __FAILED and '______ Insufficient number of arguments'"
  function fn__FileSameButForDate_test_000 {

    expectedStringResult="______ Insufficient number of arguments"
    expectedStatusResult=${__FAILED}

    actualStringResult=$( ${functionName} ) && actualStatusResult=$? || actualStatusResult=$?
    # [[ ${actualStringResult} ]] && echo "______ ${LINENO}: ${functionName}: ${actualStringResult}" 

    assessReturnStatusAndStdOut \
      "${functionName}" \
      ${LINENO} \
      "${testIntent}" \
      "${expectedStringResult}" \
      ${expectedStatusResult} \
      "${actualStringResult}" \
      ${actualStatusResult} && { ((iSuccessResults++)); true ; } || { ((iFailureResults++)); true ; }
  }
  fn__FileSameButForDate_test_000


  testIntent="${functionName} function will return __FAILED and '______ Insufficient number of arguments'"
  function fn__FileSameButForDate_test_001 {
    local -r lrFirstFilePath="${_TEMP_DIR_}/tmp_first_file"

    expectedStringResult="______ Insufficient number of arguments"
    expectedStatusResult=${__FAILED}

    actualStringResult=$( ${functionName} "${lrFirstFilePath}" ) && actualStatusResult=$? || actualStatusResult=$?
    # [[ ${actualStringResult} ]] && echo "______ ${LINENO}: ${functionName}: ${actualStringResult}" 

    assessReturnStatusAndStdOut \
      "${functionName}" \
      ${LINENO} \
      "${testIntent}" \
      "${expectedStringResult}" \
      ${expectedStatusResult} \
      "${actualStringResult}" \
      ${actualStatusResult} && { ((iSuccessResults++)); true ; } || { ((iFailureResults++)); true ; }
  }
  fn__FileSameButForDate_test_001


  testIntent="${functionName} function will return __SUCCESS - files have the same content"
  function fn__FileSameButForDate_test_002 {
    local -r lrFirstFilePath="${_TEMP_DIR_}/tmp_first_file"
    local -r lrSecondFilePath="${_TEMP_DIR_}/tmp_second_file"

    echo "Ala ma kota" > ${lrFirstFilePath}
    echo "Ala ma kota" > ${lrSecondFilePath}

    expectedStringResult=""
    expectedStatusResult=${__SUCCESS}

    actualStringResult=$( ${functionName} ${lrFirstFilePath} ${lrSecondFilePath} ) && actualStatusResult=$? || actualStatusResult=$?
    # [[ ${actualStringResult} ]] && echo "______ ${LINENO}: ${functionName}: ${actualStringResult}" 

    assessReturnStatusAndStdOut \
      "${functionName}" \
      ${LINENO} \
      "${testIntent}" \
      "${expectedStringResult}" \
      ${expectedStatusResult} \
      "${actualStringResult}" \
      ${actualStatusResult} && { ((iSuccessResults++)); true ; } || { ((iFailureResults++)); true ; }
  }
  fn__FileSameButForDate_test_002


  testIntent="${functionName} function will return __FAILED - files have different content"
  function fn__FileSameButForDate_test_003 {
    local -r lrFirstFilePath="${_TEMP_DIR_}/tmp_first_file"
    local -r lrSecondFilePath="${_TEMP_DIR_}/tmp_second_file"

    echo "Ala ma kota" > ${lrFirstFilePath}
    echo "Ala ma kota a kot ma ale" > ${lrSecondFilePath}

    expectedStringResult=""
    expectedStatusResult=${__FAILED}

    actualStringResult=$( ${functionName} ${lrFirstFilePath} ${lrSecondFilePath} ) && actualStatusResult=$? || actualStatusResult=$?
    # [[ ${actualStringResult} ]] && echo "______ ${LINENO}: ${functionName}: ${actualStringResult}" 

    assessReturnStatusAndStdOut \
      "${functionName}" \
      ${LINENO} \
      "${testIntent}" \
      "${expectedStringResult}" \
      ${expectedStatusResult} \
      "${actualStringResult}" \
      ${actualStatusResult} && { ((iSuccessResults++)); true ; } || { ((iFailureResults++)); true ; }
  }
  fn__FileSameButForDate_test_003

else 
  echo "     . Not running test for ${functionName}"
fi



# functionName="fn__GetValidIdentifierInput"
# :<<-'------------Function_Usage_Note-------------------------------'
#   Usage:
#     fn__GetValidIdentifierInput \
#       "inPromptString"  \
#       "inMaxLength"  \
#       "inTimeoutSecs" \
#       "outValidValue"
#   Returns 
#     ${__SUCCESS} and the vaid value in the output argument
#     ${__FAILED} if insufficient number of arguments are provided
# ------------Function_Usage_Note-------------------------------
# _RUN_TEST_SET_=${__YES}
# if [[ ${_RUN_TEST_SET_} -eq ${__YES} || ${_FORCE_RUNNING_ALL_TESTS_} ]]
# then

#   testIntent="${functionName} function will return __FAILURE status, insufficient number of arguments and Usage message"
#   function fn__GetValidIdentifierInput_test_001 {
#       local -r linPromptString="Please enter a valid identifier"
#       local -r linMaxLength=${__IDENTIFIER_MAX_LEN}
#       local -r linTimeoutSecs=20
#       local outValidValue=""

#     expectedStringResult=${__INSUFFICIENT_ARGS}
#     expectedStatusResult=${__FAILED}
#     actualStringResult=$( ${functionName} "linPromptString" "linMaxLength" "linTimeoutSecs" ) && actualStatusResult=$? || actualStatusResult=$?
#     # [[ ${actualStringResult} ]] && echo "______ ${LINENO}: ${functionName}: ${actualStringResult}" 

#     assessReturnStatusAndStdOut \
#       "${functionName}" \
#       ${LINENO} \
#       "${testIntent}" \
#       "${expectedStringResult}" \
#       ${expectedStatusResult} \
#       "${actualStringResult}" \
#       ${actualStatusResult} && { ((iSuccessResults++)); true ; } || { ((iFailureResults++)); true ; }
#   }
#   fn__GetValidIdentifierInput_test_001
  

#   testIntent="${functionName} function will return __FAILURE status when 3rd argument is an empty strings"
#   function fn__GetValidIdentifierInput_test_002 {
#       local -r inPromptString="Please enter a valid identifier"
#       local -r inMaxLength=${__IDENTIFIER_MAX_LEN}
#       local -r inTimeoutSecs=20
#       local -u outValidValue="test"

#     expectedStringResult="3rd Argument value, '', is invalid"
#     expectedStatusResult=${__FAILED}
#     actualStringResult=$( ${functionName} "linPromptString" "linMaxLength" "" "" ) && actualStatusResult=$? || actualStatusResult=$?
#     # [[ ${actualStringResult} ]] && echo "______ ${LINENO}: ${functionName}: ${actualStringResult}" 
#     # actualStringResult=${actualStringResult:0:${#expectedStringResult}}
#     assessReturnStatusAndStdOut \
#       "${functionName}" \
#       ${LINENO} \
#       "${testIntent}" \
#       "${expectedStringResult}" \
#       ${expectedStatusResult} \
#       "${actualStringResult}" \
#       ${actualStatusResult} && { ((iSuccessResults++)); true ; } || { ((iFailureResults++)); true ; }
#  }
#   fn__GetValidIdentifierInput_test_002
  

#   testIntent="${functionName} function will return __FAILURE status when 4th argument is an empty strings"
#   function fn__GetValidIdentifierInput_test_003 {
#       local -r inPromptString="Please enter a valid identifier"
#       local -r inMaxLength=${__IDENTIFIER_MAX_LEN}
#       local -r inTimeoutSecs=20
#       local -u outValidValue="test"

#     expectedStringResult="4th Argument value, '', is invalid"
#     expectedStatusResult=${__FAILED}
#     actualStringResult=$( ${functionName} "linPromptString" "linMaxLength" "inTimeoutSecs" "" ) && actualStatusResult=$? || actualStatusResult=$?
#     # [[ ${actualStringResult} ]] && echo "______ ${LINENO}: ${functionName}: ${actualStringResult}" 
#     # actualStringResult=${actualStringResult:0:${#expectedStringResult}}
#     assessReturnStatusAndStdOut \
#       "${functionName}" \
#       ${LINENO} \
#       "${testIntent}" \
#       "${expectedStringResult}" \
#       ${expectedStatusResult} \
#       "${actualStringResult}" \
#       ${actualStatusResult} && { ((iSuccessResults++)); true ; } || { ((iFailureResults++)); true ; }
#   }
#   fn__GetValidIdentifierInput_test_003
  

#   testIntent="${functionName} function will return __SUCCESS and the sanitised version of the input, not excceeding given length"
#   function fn__GetValidIdentifierInput_test_004 {
#     local -r inPromptString="Please enter a valid identifier"
#     local -r inMaxLength=${__IDENTIFIER_MAX_LEN}
#     local -r inTimeoutSecs=5
#     declare outValidValue

#     local -r testValue='This Is A_Test$%@ 0123456789'
#     expectedStringResult="ThisIsA_Test0123456789 ThisIsA_Test0123456789 ThisIsA_Test0123456789 ThisIsA_Test0123456789 ThisIsA_Test0123456789 "
#     expectedStatusResult=${__SUCCESS}

#     ${functionName} "inPromptString" "inMaxLength" "inTimeoutSecs" "outValidValue" <<<"${testValue}" && actualStatusResult=$? || actualStatusResult=$?
#     # [[ ${outValidValue} ]] && echo "______ ${LINENO}: ${functionName}: ${outValidValue}" 
#     assessReturnStatusAndStdOut \
#       "${functionName}" \
#       ${LINENO} \
#       "${testIntent}" \
#       "${expectedStringResult}" \
#       ${expectedStatusResult} \
#       "${actualStringResult}" \
#       ${actualStatusResult} && { ((iSuccessResults++)); true ; } || { ((iFailureResults++)); true ; }
#   }
#   fn__GetValidIdentifierInput_test_004
  

#   testIntent="${functionName} function will return __FAILURE because test string contains only characters which are not valid in an identifier"
#   function fn__GetValidIdentifierInput_test_005 {
#     local -r inPromptString="Please enter a valid identifier"
#     local -r inMaxLength=${__IDENTIFIER_MAX_LEN}
#     local -r inTimeoutSecs=5
#     declare outValidValue=""

#     local -r testValue='%#@$!&*^%$#@#$%@&^&%$&&*&(*(***&&^^%&&*'
#     expectedStringResult=""
#     expectedStatusResult=${__FAILED}

#     ${functionName} "inPromptString" "inMaxLength" "inTimeoutSecs" "outValidValue" <<<"${testValue}" && actualStatusResult=$? || actualStatusResult=$?
#     # [[ ${outValidValue} ]] && echo "______ ${LINENO}: ${functionName}: ${outValidValue}" 
#     [[ "${outValidValue}" == "${expectedStringResult}" && ${actualStatusResult} -eq ${expectedStatusResult} ]] && {
#         # echo "PASS ${LINENO}: ${functionName}: ${functionInputs} => ${expectedStringResult} == ${outValidValue} (${actualStatusResult} -eq ${expectedStatusResult})" 
#         echo "PASS ${LINENO}: ${testIntent}" 
#         ((iSuccessResults++)); true
#       } || {
#         echo "FAIL ${LINENO}: ${functionName}: ${functionInputs} => ${expectedStringResult} != ${outValidValue} (${actualStatusResult} -ne ${expectedStatusResult})" 
#         ((iFailureResults++)); true
#       }
#   }
#   # fn__GetValidIdentifierInput_test_005


#   testIntent="${functionName} function will return __SUCCESS and the value provided to it in the outValidValue argument"
#   function fn__GetValidIdentifierInput_test_006 {
#     local -r inPromptString="Please enter a valid identifier: "
#     local -r inMaxLength=${__IDENTIFIER_MAX_LEN}
#     local -r inTimeoutSecs=0.1
#     declare outValidValue="gitclient" # provide default

#     expectedStringResult="gitclient"
#     expectedStatusResult=${__SUCCESS}

#     ${functionName} "inPromptString" "inMaxLength" "inTimeoutSecs" "outValidValue" 1>&2 2>/dev/null && actualStatusResult=$? || actualStatusResult=$?
#     # [[ ${outValidValue} ]] && echo "______ ${LINENO}: ${functionName}: ${outValidValue}" 
#     [[ "${outValidValue}" == "${expectedStringResult}" && ${actualStatusResult} -eq ${expectedStatusResult} ]] && {
#         # echo "PASS ${LINENO}: ${functionName}: ${functionInputs} => ${expectedStringResult} == ${outValidValue} (${actualStatusResult} -eq ${expectedStatusResult})" 
#         echo "PASS ${LINENO}: ${testIntent}" 
#         ((iSuccessResults++)); true
#       } || {
#         echo "FAIL ${LINENO}: ${functionName}: ${functionInputs} => ${expectedStringResult} != ${outValidValue} (${actualStatusResult} -ne ${expectedStatusResult})" 
#         ((iFailureResults++)); true
#       }
#   }
#   # fn__GetValidIdentifierInput_test_006


#   testIntent="${functionName} function will return __SUCCESS and the value provided to it in the outValidValue argument"
#   function fn__GetValidIdentifierInput_test_007 {
#     local -r inPromptString="Please enter a valid identifier: "
#     local -r inMaxLength=${__IDENTIFIER_MAX_LEN}
#     local -r inTimeoutSecs=0.1
#     declare outValidValue=""

#     expectedStringResult=""
#     expectedStatusResult=${__FAILED}

#     ${functionName} "inPromptString" "inMaxLength" "inTimeoutSecs" "outValidValue" 1>&2 2>/dev/null && actualStatusResult=$? || actualStatusResult=$?
#     # [[ ${outValidValue} ]] && echo "______ ${LINENO}: ${functionName}: ${outValidValue}" 
#     [[ "${outValidValue}" == "${expectedStringResult}" && ${actualStatusResult} -eq ${expectedStatusResult} ]] && {
#         # echo "PASS ${LINENO}: ${functionName}: ${functionInputs} => ${expectedStringResult} == ${outValidValue} (${actualStatusResult} -eq ${expectedStatusResult})" 
#         echo "PASS ${LINENO}: ${testIntent}" 
#         ((iSuccessResults++)); true
#       } || {
#         echo "FAIL ${LINENO}: ${functionName}: ${functionInputs} => ${expectedStringResult} != ${outValidValue} (${actualStatusResult} -ne ${expectedStatusResult})" 
#         ((iFailureResults++)); true
#       }
#   }
#   # fn__GetValidIdentifierInput_test_007


# else 
#   echo "     . Not running test for ${functionName}"
# fi


## ############################################
## TODO - tests for fn__ConfirmYN
## TODO - move fn__GetValidIdentifierInput to fn__UtilityGeneric
## ############################################


# clean up
# rm -rfv ${_TEMP_DIR_PREFIX}[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]
rm -Rf ${_TEMP_DIR_}

echo "______ Executed $((iSuccessResults+iFailureResults)) tests"
echo "______ ${iSuccessResults} tests were successful"
echo "______ ${iFailureResults} tests failed"

# echo ${_TEMP_DIR_}

exit ${iFailureResults}
