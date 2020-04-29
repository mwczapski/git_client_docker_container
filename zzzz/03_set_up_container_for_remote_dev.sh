#!/bin/bash

# #########################################################################################
# 1.0.0   20200420    MCz Initial
# 1.0.1   20200422    MCz refactored - reduced container names
# 1.0.3   20200426    MCz copied, renamed and redeveloped to just set up an existing container
# #########################################################################################

set -o pipefail
set -o errexit

traperr() {
  echo "ERROR: -------------------------------------------------"
  echo "ERROR: ${BASH_SOURCE[1]} at about ${BASH_LINENO[0]}"
  echo "ERROR: -------------------------------------------------"
}
set -o errtrace
trap traperr ERR

source ./utils/__env_devcicd_net.sh
source ./utils/__env_gitserverConstants.sh
source ./utils/__env_YesNoSuccessFailureContants.sh

source ./utils/fn__WSLPathToDOSandWSDPaths.sh
source ./utils/fn__ConfirmYN.sh
source ./utils/fn__DockerGeneric.sh
source ./utils/fn__CreateWindowsShortcut.sh

function fn__SetEnvironmentVariables() {

  # set environment
  #
  mkdir -pv ${__DEBMIN_HOME}
  cd ${__DEBMIN_HOME}

  __DEBMIN_HOME=${__DEBMIN_HOME%%/_commonUtils} # strip _commonUtils
  __DEBMIN_HOME_DOS=$(fn__WSLPathToRealDosPath ${__DEBMIN_HOME})
  __DEBMIN_HOME_WSD=$(fn__WSLPathToWSDPath ${__DEBMIN_HOME})

  __DEBMIN_PPROJECT_NAME=${__DEBMIN_HOME##*/} # strip directory hierarchy before parent of _commonUtils
  __DEBMIN_PPROJECT_NAME=${__DEBMIN_PPROJECT_NAME//[ _^%@-]/}  # remove special characters, if any, from project name

  # reduce project name to no more than __MaxNameLen__ characters
  local -ri __MaxNameLen__=15
  local -ri nameLen=${#__DEBMIN_PPROJECT_NAME}
  local startPos=$((${nameLen}-${__MaxNameLen__})) 
  startPos=${startPos//-*/0} 
  __DEBMIN_PPROJECT_NAME=${__DEBMIN_PPROJECT_NAME:${startPos}}

  readonly __DEBMIN_USERNAME=node
  readonly __DEBMIN_GUEST_HOME=/home/${__DEBMIN_USERNAME}

  readonly __DEBMIN_SHELL="/bin/bash"

  readonly __DOCKER_REPOSITORY_HOST="mcz11.czapski.id.au"
  readonly __DEBMIN_SOURCE_IMAGE_NAME="${__DOCKER_REPOSITORY_HOST}/nodejs_baseline:1.0.0"

  readonly __CONTAINER_NAME="${__DEBMIN_PPROJECT_NAME}"
  readonly __HOST_NAME="${__DEBMIN_PPROJECT_NAME}"

  __PORT_MAPPINGS[0]=127.0.0.1:3101:3100/tcp
  __PORT_MAPPINGS[1]=127.0.0.1:5001:5000/tcp
  __PORT_MAPPINGS[2]=127.0.0.1:48080:8080/tcp

  readonly __DOCKER_COMPOSE_FILE_WLS="${__DEBMIN_HOME}/docker-compose.yml_${__CONTAINER_NAME}"
  readonly __DOCKER_COMPOSE_FILE_DOS="${__DEBMIN_HOME_DOS}\\docker-compose.yml_${__CONTAINER_NAME}"

  readonly __GIT_REMOTE_REPO_NAME=${__DEBMIN_PPROJECT_NAME}

}

## ###############################################################################################
## local functions
## ###############################################################################################

function fn_SetUpStarterJSProjectDirectory() {
    echo '_______ As node, creating starter project';
    pContainerName=${1?"Usage: ${FUNCNAME} requires Value of __DEBMIN_PPROJECT_NAME as its only argument"}
	${__DOCKER_EXE} exec -itu root -w /home/node/dev ${pContainerName} ${__DEBMIN_SHELL} -c "
cd /home/node/dev
chown -R node:node /home/node/dev
" && return ${__SUCCESS} || return ${__FAILED}
}


function fnInstallProjectLocalNodePackages() {
    echo '---------------------------------------------------------------------------------------';
    echo '_______ As node, installing lint-related packages' ;
    echo '---------------------------------------------------------------------------------------';
    pContainerName=${1?"Usage: $0 requires Value of __DEBMIN_PPROJECT_NAME as its only argument"}
	${__DOCKER_EXE}  exec -itu root -w /home/node/dev ${pContainerName} ${__DEBMIN_SHELL} -c "
chown -R node:node /home/node
"
	${__DOCKER_EXE}  exec -itu node -w /home/node/dev ${pContainerName} ${__DEBMIN_SHELL} -c '
if [[ ! -e ./node_modules ]]; then
    npm install --save-dev \
        prettier \
        eslint \
        eslint-plugin-prettier \
        eslint-config-prettier \
        eslint-plugin-node \
        eslint-config-node
    chown -R node:node /home/node/dev
fi
'
}


function fnCreateDotGitignore() {
    echo '_______ As node, creating .gitignore';
    pContainerName=${1?"Usage: $0 requires Value of __DEBMIN_PPROJECT_NAME as its only argument"}
	${__DOCKER_EXE} exec -itu node -w /home/node/dev ${pContainerName} ${__DEBMIN_SHELL} -c '
    cat <<-EOF > /home/node/dev/.gitignore
Downloads
*.tgz
*.zip
*.lnk
node_modules
dist
logs
.npm
.vscode-server
out
.cache
/.pnp
.pnp.js
/coverage
/build
 
# local env files
.DS_Store
.env.local
.env.development.local
.env.test.local
.env.production.local
 
# Log files
npm-debug.log*
yarn-debug.log*
yarn-error.log*
 
# Editor directories and files
.vscode
EOF
'
}


function fnCreateDotJsconfig() {
    echo '_______ As node, creating .jsconfig';
    pContainerName=${1?"Usage: $0 requires Value of __DEBMIN_PPROJECT_NAME as its only argument"}
	${__DOCKER_EXE}  exec -itu node -w /home/node/dev ${pContainerName} ${__DEBMIN_SHELL} -c "
    cd /home/node/dev
    cat <<-EOF > /home/node/dev/.jsconfig
{
    \"esversion\": 9,
    \"eqeqeq\": true,
    \"trailingcomma\": true,
    \"unused\": true,
    \"varstmt\": true
}
EOF
"
}


function fnCreateDotPrettierrc() {
    echo '_______ As node, creating .prettierrc';
    pContainerName=${1?"Usage: $0 requires Value of __DEBMIN_PPROJECT_NAME as its only argument"}
	${__DOCKER_EXE}  exec -itu node -w /home/node/dev ${pContainerName} ${__DEBMIN_SHELL} -c '
    cat <<-EOF > /home/node/dev/.prettierrc
{
  "singleQuote": true,
  "semi": true,
  "endOfLine": "lf",
  "tabWidth": 2,
  "useTabs": false,
  "bracketSpacing": true,
  "arrowParens": "always"
}
EOF
'
}


function fnCreateDotEslintDotJson() {
    echo '_______ As node, creating .eslintrc.json';
    pContainerName=${1?"Usage: $0 requires Value of __DEBMIN_PPROJECT_NAME as its only argument"}
	${__DOCKER_EXE}  exec -itu node -w /home/node/dev ${pContainerName} ${__DEBMIN_SHELL} -c '
    cat <<-EOF > /home/node/dev/.eslintrc.json
{
    "parserOptions": {
        "ecmaVersion": 11,
        "sourceType": "script",
        "ecmaFeatures": {}
    },
    "extends": [
        "prettier",
        "plugin:node/recommended"
    ],
    "plugins": [
        "prettier"
    ],
    "rules": {
        "prettier/prettier": "error",
        "no-unused-vars": "warn",
        "no-console": "off",
        "func-names": "off"
    }
}
EOF
'
}


function fnInitLocalGitEnvironment() {
    echo '_______ As node, initialising local git environment';
    pContainerName=${1?"Usage: $0 requires Value of __DEBMIN_PPROJECT_NAME as its only argument"}
	${__DOCKER_EXE}  exec -itu root -w /home/node/dev ${pContainerName} ${__DEBMIN_SHELL} -c '
git init
chown -R node:node .git 
chmod -R g+s .git 
'
	${__DOCKER_EXE}  exec -itu node -w /home/node/dev ${pContainerName} ${__DEBMIN_SHELL} -c '
git config --global core.editor nano
git config --global user.name "MCz"
git config --global user.email "postmaster@czapski.id.au"
git add . 
git commit -m "initial commit"
git config --list
'
}


function fnGenerateRSAKeys() {
    echo '_______ As node, generating RSA keys' ;
    pContainerName=${1?"Usage: $0 requires Value of __DEBMIN_PPROJECT_NAME as its only argument"}
    ${__DOCKER_EXE}  exec -itu node -w /home/node/dev ${pContainerName} ${__DEBMIN_SHELL} -c '
rm -vf /home/node/.ssh/id_rsa* || true 
ssh-keygen -f /home/node/.ssh/id_rsa -t rsa -b 2048 -q -N "" 
cat /home/node/.ssh/id_rsa.pub 
'
}


function fnCopyRSAPublicKeyToGITServer() {
    pContainerName=${1?"Usage: $0 requires Value of __DEBMIN_PPROJECT_NAME and __GITSERVER_NAME as its arguments"}
    pGITServerName=${2?"Usage: $0 requires Value of __DEBMIN_PPROJECT_NAME and __GITSERVER_NAME as its arguments"}
    echo "_______ From host, copying guest's id_rsa.pub to ${pGITServerName}'s /tmp/${pContainerName}_id_rsa.pub";
    # copy generated client container public key to host
    # copy generated client public key to __GITSERVERgitserver's git account
    #
    ${__DOCKER_EXE} cp ${pContainerName}:/home/node/.ssh/id_rsa.pub /tmp/${pContainerName}_id_rsa.pub
    ${__DOCKER_EXE} cp /tmp/${pContainerName}_id_rsa.pub ${pGITServerName}:/home/git/.ssh/${pContainerName}_id_rsa.pub

    ${__DOCKER_EXE} container exec -itu root ${pGITServerName} ${__GITSERVER_SHELL} -c "
chown -Rv git:git /home/git/.ssh/${pContainerName}_id_rsa.pub
"
}


function fnUpdateGITServerAuthorized_keys() {
    echo "_______ save original authorized_keys, and update authorized_keys";
    pContainerName=${1?"Usage: $0 requires Value of __DEBMIN_PPROJECT_NAME and __GITSERVER_NAME as its arguments"}
    pGITServerName=${2?"Usage: $0 requires Value of __DEBMIN_PPROJECT_NAME and __GITSERVER_NAME as its arguments"}
    ${__DOCKER_EXE} container exec -itu git -w /home/git ${pGITServerName} ${__GITSERVER_SHELL} -c "
mv -v ~/.ssh/authorized_keys ~/.ssh/authorized_keys_previous
chmod 0600 ~/.ssh/authorized_keys_previous

test -e ~/.ssh/authorized_keys \
  && cp -v ~/.ssh/authorized_keys ~/.ssh/authorized_keys_previous \
  || touch ~/.ssh/authorized_keys ~/.ssh/authorized_keys_previous 

sed \"/${pContainerName}/d\" ~/.ssh/authorized_keys_previous > ~/.ssh/authorized_keys

cat /home/git/.ssh/${pContainerName}_id_rsa.pub >> ~/.ssh/authorized_keys

echo 'authorized_keys after append'
cat ~/.ssh/authorized_keys 
"
}


function fnAddGITServerToLocalKnown_hostsAndTestSshAccess() {
    echo "_______ add __GITSERVER ssh fingerprint to known_hosts and test access to git repository";
    # https://www.techrepublic.com/article/how-to-easily-add-an-ssh-fingerprint-to-your-knownhosts-file-in-linux/
    pContainerName=${1?"Usage: $0 requires Value of __DEBMIN_PPROJECT_NAME and __GITSERVER_NAME as its arguments"}
    pGITServerName=${2?"Usage: $0 requires Value of __DEBMIN_PPROJECT_NAME and __GITSERVER_NAME as its arguments"}
	${__DOCKER_EXE}  exec -itu node -w /home/node/dev ${pContainerName} ${__DEBMIN_SHELL} -c "
ssh-keyscan -H ${pGITServerName} >> ~/.ssh/known_hosts
ssh git@${pGITServerName} list && echo 'Can connect to the remote git repo' || echo 'Cannot connect to the remote git repo'
"
}


function fnCreateRemoteGitRepoForThisProject() {
    pGITServerName=${1?"Usage: $0 requires Values of __GITSERVER_NAME, __GITSERVER_REPOS_ROOT and __GIT_REMOTE_REPO_NAME as its arguments"}
    pGITServerReposRoot=${2?"Usage: $0 requires Values of __GITSERVER_NAME, __GITSERVER_REPOS_ROOT and __GIT_REMOTE_REPO_NAME as its arguments"}
    pGITServerRepoName=${3?"Usage: $0 requires Values of __GITSERVER_NAME, __GITSERVER_REPOS_ROOT and __GIT_REMOTE_REPO_NAME as its arguments"}
    echo "_______ As root on ${pGITServerName}, creating remote repository for this container's project";
    ${__DOCKER_EXE} container exec -itu root ${pGITServerName} ${__GITSERVER_SHELL} -lc "
[[ -d ${pGITServerReposRoot}/${pGITServerRepoName}.git ]] && rm -Rf ${pGITServerReposRoot}/${pGITServerRepoName}.git
mkdir -pv ${pGITServerReposRoot}/${pGITServerRepoName}.git
cd ${pGITServerReposRoot}/${pGITServerRepoName}.git
git init --bare
chown -R git:developers ${pGITServerReposRoot}/${pGITServerRepoName}.git 
chmod -R g+s ${pGITServerReposRoot}/${pGITServerRepoName}.git
"
}


function fnPerformGitSetupOnHost() {
# fnPerformGitSetupOnHost ${__DEBMIN_HOME} ${__GITSERVER_NAME} ${__GIT_REMOTE_REPO_NAME}

    echo "_______ initialise host git repository for this project";
    local pDebminHome=${1?"Usage: $0 requires __DEBMIN_HOME, __DEBMIN_PPROJECT_NAME, __GITSERVER_NAME and __GIT_REMOTE_REPO_NAME as its arguments"}
    local pGitServerName=${2?"Usage: $0 requires __DEBMIN_HOME, __DEBMIN_PPROJECT_NAME, __GITSERVER_NAME and __GIT_REMOTE_REPO_NAME as its arguments"}
    local pGITServerRepoName=${3?"Usage: $0 requires __DEBMIN_HOME, __DEBMIN_PPROJECT_NAME, __GITSERVER_NAME and __GIT_REMOTE_REPO_NAME as its arguments"}

# ${__DEBMIN_HOME}/dev is bind mounted in the container
# certain operations are not permitted from within the container
# they need to be performed on the host
#
    cd ${pDebminHome}/dev
    rm -Rf .git
    git init
    git remote remove origin 2>/dev/null || true
    git remote add origin ssh://git@${pGitServerName}/opt/gitrepos/${pGITServerRepoName}.git
    cd -
}


function fnTestRemoteGitRepoOperation() {
#
# fnTestRemoteGitRepoOperation \
#     ${__DEBMIN_HOME} \
#     ${__DEBMIN_PPROJECT_NAME}  \
#     ${__GITSERVER_NAME} \
#     ${__GIT_REMOTE_REPO_NAME}
#
    echo "_______ test git repository operations";
    local pContainerName=${1?"Usage: $0 requires __DEBMIN_HOME, __DEBMIN_PPROJECT_NAME, __GITSERVER_NAME and __GIT_REMOTE_REPO_NAME as its arguments"}
    local pGitServerName=${2?"Usage: $0 requires __DEBMIN_HOME, __DEBMIN_PPROJECT_NAME, __GITSERVER_NAME and __GIT_REMOTE_REPO_NAME as its arguments"}
    local pGITServerRepoName=${3?"Usage: $0 requires __DEBMIN_HOME, __DEBMIN_PPROJECT_NAME, __GITSERVER_NAME and __GIT_REMOTE_REPO_NAME as its arguments"}

# # ${__DEBMIN_HOME}/dev is bind mounted in the container
# # certain operations are not permitted from within the container
# # they need to be performed on the host
# #
# cd ${pDebminHome}/dev
# rm -Rvf .git
# git init
# git remote remove origin
# git remote add origin ssh://git@${pGitServerName}/opt/gitrepos/${pGITServerRepoName}.git
# cd -

	${__DOCKER_EXE}  exec -itu node -w /home/node/dev ${pContainerName} ${__DEBMIN_SHELL} -c "
git add .
git commit -m 'create commit'
#git remote remove origin
#git remote add origin ssh://git@${pGitServerName}/opt/gitrepos/${pGITServerRepoName}.git
git remote -v show origin
git remote -v
git push origin master

mkdir -pv ../${pGITServerRepoName}2
cd ../${pGITServerRepoName}2
git init
git remote add origin ssh://git@${pGitServerName}/opt/gitrepos/${pGITServerRepoName}.git
git remote -v
git pull origin master
cd ..
rm -Rf ./${pGITServerRepoName}2
"
}


function fnCreateWindowsShortcuts() {
    echo "_______ (Re-)create windows shortcuts";

    pContainerName=${1?"Usage: $0 requires Value of __DEBMIN_PPROJECT_NAME as its only argument"}
    powershell.exe "
\$s=(New-Object -COM WScript.Shell).CreateShortcut('${__DEBMIN_SHELL} -l in container as node.lnk');\
\$s.TargetPath='cmd';\
\$s.WorkingDirectory='%~dp0';\
\$s.Arguments=' /c docker.exe container exec -itu node -w /home/node/dev ${pContainerName} ${__DEBMIN_SHELL} -l';\
\$s.Save()"

    powershell.exe "
\$s=(New-Object -COM WScript.Shell).CreateShortcut('${__DEBMIN_SHELL} -l in container as root.lnk');\
\$s.TargetPath='cmd';\
\$s.WorkingDirectory='%~dp0';\
\$s.Arguments=' /c docker.exe container exec -itu root -w /root  ${pContainerName} ${__DEBMIN_SHELL} -l';\
\$s.Save()"

}


fn__CreateWindowsShortcutsForShellInContainer() {
  [[ $# -lt  3 || "${0^^}" == "HELP" ]] && {
    echo '
Usage: 
  fn__CreateWindowsShortcutsForShellInContainer \
    "${__CONTAINER_NAME}" \
    "${__DEBMIN_HOME_DOS}" \
    "${__DEBMIN_SHELL}" && STS=${__DONE} || STS=${__FAILED}
'
    return ${__FAILED}
  }
 
  local -r pContainerName=${1?"Container Name to be assigned to the container"}
  local -r pHomeDosPath=${2?"Host Path, in DOS format, to write shortcuts to"}
  local -r pShellInContainer=${3?"Shell to use on connection to the container"}

  local lDockerComposeCommand=""
  local lARGS=""
  local lDockerContainerCommandLine=""

  # create windows shortcuts for shell in container

  lARGS="/c wsl -d Debian -- bash -lc \"docker.exe container exec -itu node --workdir /home/node/dev ${pContainerName} ${pShellInContainer} -l\" || pause"
  fn__CreateWindowsShortcut \
    "${pHomeDosPath}\dev\dcc exec -itu node ${pContainerName}.lnk" \
    "C:\Windows\System32\cmd.exe" \
    "%~dp0" \
    "${fn__CreateWindowsShortcut__RUN_NORMAL_WINDOW}" \
    "%ProgramFiles%\Docker\Docker\resources\bin\docker.exe" \
    "${lARGS}"

  lARGS="/c wsl -d Debian -- bash -lc \"docker.exe container exec -itu root --workdir / ${pContainerName} ${pShellInContainer} -l\" || pause"
  fn__CreateWindowsShortcut \
    "${pHomeDosPath}\dev\dcc exec -itu root ${pContainerName}.lnk" \
    "C:\Windows\System32\cmd.exe" \
    "%~dp0" \
    "${fn__CreateWindowsShortcut__RUN_NORMAL_WINDOW}" \
    "%ProgramFiles%\Docker\Docker\resources\bin\docker.exe" \
    "${lARGS}"

#"C:\Program Files\Microsoft VS Code\Code.exe" .    

  lARGS="."
  fn__CreateWindowsShortcut \
    "${pHomeDosPath}\dev\run Code here.lnk" \
    "C:\Program Files\Microsoft VS Code\Code.exe" \
    "%~dp0" \
    "${fn__CreateWindowsShortcut__RUN_MINIMISED}" \
    "%ProgramFiles%\Microsoft VS Code\Code.exe" \
    "${lARGS}"

  return ${__DONE}
}

function fnGiveOwnershipToNode() {
#
# fnGiveOwnershipToNode  \
#   ${__CONTAINER_NAME} \
#   ${__DEBMIN_GUEST_HOME}  \
#   ${__DEBMIN_SHELL}
#
    pContainerName=${1?"Usage: $0 requires __CONTAINER_NAME, __DEBMIN_GUEST_HOME and __DEBMIN_SHELL as its arguments"}
    pGuestHome=${2?"Usage: $0 requires __CONTAINER_NAME, __DEBMIN_GUEST_HOME and __DEBMIN_SHELL as its arguments"}
    pContainerShell=${3?"Usage: $0 requires __CONTAINER_NAME, __DEBMIN_GUEST_HOME and __DEBMIN_SHELL as its arguments"}

    echo "______ As root on ${pContainerName}, giving ownership of node_modules directory to node";

    ${__DOCKER_EXE} container exec -itu root -w ${pGuestHome} ${pContainerName} ${pContainerShell} -lc "
chown -R node:node ${pGuestHome}
chmod -R g+s ${pGuestHome}/dev
chmod -R g+s ${pGuestHome}/dev/node_modules
"
}


# function fnBackupLocalEnvToHostSharedDirectory() {
#     echo '_______ As node, backing up to host-shared directory the webapp directory and all its artefacts except the node_modules';
#     pContainerName=${1?"Usage: $0 requires Value of __DEBMIN_PPROJECT_NAME as its only argument"}
#     ${__DOCKER_EXE}  exec -itu node -w /home/node/dev ${pContainerName} ${__DEBMIN_SHELL} -c 'cd /home/node/dev && \
# tar czvf ../windir_$(date +%Y%m%d_%H%M%S).tgz --exclude webapp/node_modules webapp
# '
# }



## ###############################################################################################
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

fn__SetEnvironmentVariables ## && STS=${__SUCCESS} || STS=${__FAILED} # let it fail 

fn__ConfirmYN "Artefact location will be ${__DEBMIN_HOME} - Is this correct?" && true || {
  echo -e "_______ Aborting ...\n"
  exit
}


fn__ContainerExists \
    "${__DEBMIN_PPROJECT_NAME}" && STS=0 || STS=1
[[ $STS -eq ${__NO} ]] && {
    echo "_______ Container ${__DEBMIN_PPROJECT_NAME} does not exist or is not running!"; 
    echo '_______ Aborting ...'; 
    exit
} || {
    echo "_______ Container ${__DEBMIN_PPROJECT_NAME} exists and is running"; 
}


fn_SetUpStarterJSProjectDirectory \
    ${__DEBMIN_PPROJECT_NAME} && {
    echo "_______ Set up startup JavaScript directory"; 
} || {
    echo "_______ Failed to set up startup JavaScript directory"; 
    echo "_______ Investigate the issue..."; 
    exit;
}

fnCreateDotGitignore \
    ${__DEBMIN_PPROJECT_NAME}

fnCreateDotJsconfig \
    ${__DEBMIN_PPROJECT_NAME}

fnCreateDotPrettierrc \
    ${__DEBMIN_PPROJECT_NAME}

fnCreateDotEslintDotJson \
    ${__DEBMIN_PPROJECT_NAME}

fnInitLocalGitEnvironment \
    ${__DEBMIN_PPROJECT_NAME}

fnGiveOwnershipToNode  \
  ${__DEBMIN_PPROJECT_NAME} \
  ${__DEBMIN_GUEST_HOME}  \
  ${__DEBMIN_SHELL}

fnGenerateRSAKeys \
    ${__DEBMIN_PPROJECT_NAME}

fnCopyRSAPublicKeyToGITServer \
    ${__DEBMIN_PPROJECT_NAME} ${__GITSERVER_NAME}

fnUpdateGITServerAuthorized_keys \
    ${__DEBMIN_PPROJECT_NAME} \
    ${__GITSERVER_NAME}

fnAddGITServerToLocalKnown_hostsAndTestSshAccess \
    ${__DEBMIN_PPROJECT_NAME} \
    ${__GITSERVER_NAME}

fnPerformGitSetupOnHost \
    ${__DEBMIN_HOME} \
    ${__GITSERVER_NAME} \
    ${__GIT_REMOTE_REPO_NAME}

fnCreateRemoteGitRepoForThisProject \
    ${__GITSERVER_NAME} \
    ${__GITSERVER_REPOS_ROOT} \
    ${__GIT_REMOTE_REPO_NAME}

fnTestRemoteGitRepoOperation \
    ${__DEBMIN_PPROJECT_NAME}  \
    ${__GITSERVER_NAME} \
    ${__GIT_REMOTE_REPO_NAME}

fn__CreateWindowsShortcutsForShellInContainer \
  "${__DEBMIN_PPROJECT_NAME}" \
  "${__DEBMIN_HOME_DOS}" \
  "${__DEBMIN_SHELL}" && STS=${__DONE} || STS=${__FAILED}

echo '_______ Container set up'; 
