# #############################################
# The MIT License (MIT)
#
# Copyright © 2020 Michael Czapski
# #############################################

declare -u fn__UtilityGeneric="SOURCED"

[[ ${__env_GlobalConstants} ]] || source __env_GlobalConstants.sh


_PROMPTS_TIMEOUT_SECS_=${_PROMPTS_TIMEOUT_SECS_:-15.5}

function fn__ConfirmYN() {
  pPrompt=${1?"Usage: $0 requires the prompt string and will return 0 if response is Yes, and 1 if it is No"}
  read -t ${_PROMPTS_TIMEOUT_SECS_} -p "______ ${pPrompt} (y/N) " -i 'No' -r RESP || echo
  RESP=${RESP^^}; RESP=${RESP:0:1}
  [[ $RESP == 'Y' ]] && return ${__YES} || return ${__NO}
}


function fn__FileSameButForDate() {
  local lUsage='
      Usage: 
        fn__FileSameButForDate 
          ${__FIRST_FILE_PATH} 
          ${__SECOND_FILE_PATH}
      '
  [[ $# -lt  2 || ${0^^} == "HELP" ]] && {
    echo ${lUsage}
    return ${__FAILED}
  }

  local pFile1=${1?"${lUsage}"}
  local pFile2=${2?"${lUsage}"}

  diff -s --ignore-matching-lines='202[0-9][0-1][0-9][0-3][0-9]' \
    ${pFile1} \
    ${pFile2} \
    >/dev/null \
      && return ${__THE_SAME} \
      || return ${__DIFFERENT}
}


function fn__IsValidRegEx() {
  [[ $# -lt 1 ]] && {
    echo "______ Requires a shell regex to validate"
    return ${__FAILED}
  }
  local pRegEx="$@"
  [[ ${#pRegEx} -ge 3 ]] || {
    echo "______ Alleged regular expression '${pRegEx}' must be at least 3 characters long"
    return ${__FAILED}
  }
  [[ "${pRegEx:0:1}" == "[" ]] && [[ "${pRegEx:${#pRegEx}-1}" == "]" ]] \
    || {
      echo "______ Alleged regular expression '${pRegEx}' must start with [ and end with ]"
      return ${__FAILED}
    }
  
  echo "VALID"
  return ${__SUCCESS}
}


function fn__SanitizeInput() {
  [[ $# -lt 1 ]] && { echo "______ Requires shell regex to use to determine valid characters and eliminate all that do not match"; exit ; }
  [[ $# -lt 2 ]] && { echo "______ Require string to sanitize"; exit ; }
  local pRegEx="${@}"
  pRegEx="${pRegEx%%]*}]"
  local lMsg=$(fn__IsValidRegEx "${pRegEx}")
  [[ ${lMsg} != "VALID" ]] && {
    echo ${lMsg}
    return ${__FAILED}
  }
  local pInput="${@}"
  local -r lLenRegEx=${#pRegEx}
  pInput="${pInput:${lLenRegEx}}"
  local -r lRegEx="${pRegEx:0:1}^${pRegEx:1}"  # regex must be inverted to eliminate all character except these which match the original expression
  local lOutput="${pInput//${lRegEx}/}"
  local lOutputLen=${#pInput}
  echo ${lOutput}
  return ${__SUCCESS}
}

function fn__SanitizeInputAlphaNum() {
  [[ $# -lt 1 ]] && { echo "______ Require string which to sanitize"; exit ; }
  local pInput="$@"
  local pOutput=$(fn__SanitizeInput "[a-zA-Z0-9]" ${pInput}) && STS=$?|| STS=$?
  echo ${pOutput}
  return ${STS}
}

function fn__SanitizeInputIdentifier() {
  [[ $# -lt 1 ]] && { echo "______ Require string which to sanitize"; exit ; }
  local pInput="$@"
  local pOutput=$(fn__SanitizeInput "[a-zA-Z0-9_]" ${pInput}) && STS=$?|| STS=$?
  echo ${pOutput}
  return ${STS}
}

function fn__SanitizeInputAlpha() {
  [[ $# -lt 1 ]] && { echo "______ Require string which to sanitize"; exit ; }
  local pInput="$@"
  local pOutput=$(fn__SanitizeInput "[a-zA-Z]" ${pInput}) && STS=$?|| STS=$?
  echo ${pOutput}
  return ${STS}
}

function fn__SanitizeInputNumeric() {
  [[ $# -lt 1 ]] && { echo "______ Require string which to sanitize"; exit ; }
  local pInput="$@"
  local pOutput=$(fn__SanitizeInput "[0-9]" ${pInput}) && STS=$?|| STS=$?
  echo ${pOutput}
  return ${STS}
}
