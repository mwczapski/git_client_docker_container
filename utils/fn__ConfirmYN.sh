
source ./utils/__env_YesNoSuccessFailureContants.sh

function fn__ConfirmYN() {
  pPrompt=${1?"Usage: $0 requires the prompt string and will return 0 if response is Yes, and 1 if it is No"}
  echo && read -p "______ ${pPrompt} (y/N) " -i 'No' -r RESP
  RESP=${RESP^^}; RESP=${RESP:0:1}
  [[ $RESP == 'Y' ]] && return ${__YES} || return ${__NO}
}