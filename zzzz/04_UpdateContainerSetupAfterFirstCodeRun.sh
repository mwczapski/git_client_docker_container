#!/bin/bash

set -o pipefail
set -o errexit

traperr() {
  echo "ERROR: ------------------------------------------------"
  echo "ERROR: ${BASH_SOURCE[1]} at about ${BASH_LINENO[0]}"
  echo "ERROR: ------------------------------------------------"
}
set -o errtrace
trap traperr ERR


source ./utils/__env_YesNoSuccessFailureContants.sh
source ./utils/fn__WSLPathToDOSandWSDPaths.sh
source ./utils/fn__ConfirmYN.sh
source ./utils/fn__CreateWindowsShortcut.sh


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
__DEBMIN_HOME=$(pwd)
readonly __CWD_NAME=$(basename ${__DEBMIN_HOME})
[[ "${__CWD_NAME}" == "_commonUtils" ]] || {
  echo "${0} must run from directory with name _commonUtils and will use the name of its parent directory as project directory"
  exit
}

cd ${__DEBMIN_HOME}

__DEBMIN_HOME=${__DEBMIN_HOME%%/_commonUtils} # strip _commonUtils
__DEBMIN_HOME_DOS=$(fn__WSLPathToRealDosPath ${__DEBMIN_HOME})
__DEBMIN_HOME_WSD=$(fn__WSLPathToWSDPath ${__DEBMIN_HOME})

__DEBMIN_PPROJECT_NAME=${__DEBMIN_HOME##*/} # strip directory hierarchy before parent of _commonUtils
__DEBMIN_PPROJECT_NAME=${__DEBMIN_PPROJECT_NAME//[ _^%@-]/}  # remove special characters, if any, from project name

if [ -f ${__DEBMIN_HOME}/dev/__h.containerUri ]; then 
  mv ${__DEBMIN_HOME}/dev/__h.containerUri ${__DEBMIN_HOME}/dev/__h.containerUri_$(date +%Y%m%d_%H%M%S)
fi

folderLines=$(grep '"folder": "vscode-remote' /mnt/c/Users/${USER}/AppData/Roaming/Code/storage.json)
lastSts=$?

if [ ${lastSts} -ne ${__SUCCESS} ]; then
  echo "____________No running running containers - cannot find container id for use with vscode-remote"
  echo "____________Start the container, use vscode to connect to the container and let this install what it wants"
  echo "____________Try getting Container Id again"
  exit
fi

folderUri=$(echo ${folderLines} | sed 's|^.*\"folder\": ||;s|,$||;s|/home/node||')
folderUri=$(echo ${folderUri} | sed 's|^.*\"folder\": ||;s|,$||;s|/dev||;')
folderUri=$(echo ${folderUri} | sed 's|^.*\"folder\": ||;s|,$||;s|/root$||')
folderUri=${folderUri%\"}
folderUri="${folderUri}/home/node/dev\""
lastSts=$?

if [ ${lastSts} -ne ${__SUCCESS} ]; then
  echo "____________Error getting folderUri"
  echo "____________Have:"
  echo ${folderUri}
  echo "____________Investigate the issue then try getting Container Id again"
  exit
fi

echo ${folderUri} > ${__DEBMIN_HOME}/dev/__h.containerUri

echo "'/mnt/c/Program Files/Microsoft VS Code/Code.exe'" --folder-uri $(cat ${__DEBMIN_HOME}/dev/__h.containerUri) > ${__DEBMIN_HOME}/dev/10_code_in_remote_container.sh
chmod u+x ${__DEBMIN_HOME}/dev/10_code_in_remote_container.sh

powershell.exe "
  \$s=(New-Object -COM WScript.Shell).CreateShortcut('${__DEBMIN_HOME_DOS}\dev\10 code in remote container.lnk');\
  \$s.TargetPath='wsl.exe';\
  \$s.WorkingDirectory='%~dp0';\
  \$s.Arguments=' ${__DEBMIN_HOME}/dev/10_code_in_remote_container.sh ';\
  \$s.WindowStyle=${fn__CreateWindowsShortcut__RUN_MINIMISED};\
  \$s.IconLocation='C:\Program Files\Microsoft VS Code\Code.exe';\

  \$s.Save()\
"
echo "____________Created/Updated Container Id and Links to Remote Development"
