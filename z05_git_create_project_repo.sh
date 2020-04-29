#!/bin/bash

set -o pipefail
set -o errexit

traperr() {
  echo "ERROR: -------------------------------------------------"
  echo "ERROR: ${BASH_SOURCE[1]} at about ${BASH_LINENO[0]}"
  echo "ERROR: -------------------------------------------------"
}
set -o errtrace
trap traperr ERR

# validate input - must be non-empty, and if ends in .git drop .git and validate again
#
GIT_REM_REPO_NAME=${1?"01:Usage: $0 requires Value of project-based remote Git repository name, without .git extension, as its only argument"}
GIT_REM_REPO_NAME=${GIT_REM_REPO_NAME%.git}
[[ ${#GIT_REM_REPO_NAME} -eq 0 ]] && unset GIT_REM_REPO_NAME
GIT_REM_REPO_NAME=${GIT_REM_REPO_NAME?"02:Usage: $0 requires Value of project-based remote Git repository name, without .git extension, as its only argument"}

# GIT_REM_REPO_NAME=gittest ## for debugging purposes


export GITSERVER_USERNAME=gitserver
export GITSERVER_NAME=gitserver
export GITSERVER_CONTAINER_NAME=${GITSERVER_USERNAME}
export GITSERVER_REPOS_ROOT=/opt/gitrepos
export GIT_REM_REPO_NAME

docker container ls | grep ${GITSERVER_CONTAINER_NAME} >/dev/null 
if [[ $? -ne 0 ]]; then 
  echo "Container ${GITSERVER_CONTAINER_NAME} not running" 
  exit
fi

echo '---------------------------------------------------------------------------------------';
echo "------ As root on ${GITSERVER_USERNAME}, determine whether remote repository '${GIT_REM_REPO_NAME}' exists";
echo '---------------------------------------------------------------------------------------';
EXISTS=0
DOESNOTEXIST=1
STS=${DOESNOTEXIST}
docker container exec -itu git ${GITSERVER_CONTAINER_NAME} bash -c "
  if [[ -e ${GITSERVER_REPOS_ROOT}/${GIT_REM_REPO_NAME}.gitx ]]; then exit ${EXISTS}; else exit ${DOESNOTEXIST}; fi
" && STS=${DOESNOTEXIST} || STS=0 # prevent non-zero return triggering error handling and abort

if [[ ${STS} -eq ${EXISTS} ]]; then
  echo    "------ Remote git repository ${GIT_REM_REPO_NAME} already exists!"
  read -p "------ Do you with to delete this repository and re-create is as an empty repository? (y/N) " -i 'No' -r RESP
  RESP="${RESP}N" # make sure that there is a default of N if the response if not actually entered - not strictly needed
  RESP=$(tr '[a-z]' '[A-Z]' <<<${RESP:0:1})
  if [ "$RESP" != "Y" ]; then
      echo "------ Not deleting remote git repository ${GIT_REM_REPO_NAME} - aborting script"
      exit
  fi
fi

echo '---------------------------------------------------------------------------------------';
echo "------ As root on ${GITSERVER_USERNAME}, creating remote repository ${GIT_REM_REPO_NAME}";
echo '---------------------------------------------------------------------------------------';
docker container exec -itu root ${GITSERVER_CONTAINER_NAME} bash -c "
  if [[ -d ${GITSERVER_REPOS_ROOT}/${GIT_REM_REPO_NAME}.git ]]; then rm -R ${GITSERVER_REPOS_ROOT}/${GIT_REM_REPO_NAME}.git; fi
  mkdir -p ${GITSERVER_REPOS_ROOT}/${GIT_REM_REPO_NAME}.git
  chown -R git:developers ${GITSERVER_REPOS_ROOT}/${GIT_REM_REPO_NAME}.git 
  chmod -R g+s ${GITSERVER_REPOS_ROOT}/${GIT_REM_REPO_NAME}.git 
  cd ${GITSERVER_REPOS_ROOT}/${GIT_REM_REPO_NAME}.git
  git init --bare
  chown -R git:developers ${GITSERVER_REPOS_ROOT}/${GIT_REM_REPO_NAME}.git 
  chmod -R g+s ${GITSERVER_REPOS_ROOT}/${GIT_REM_REPO_NAME}.git 
"

echo '---------------------------------------------------------------------------------------';
echo "------ Git repository ${GIT_REM_REPO_NAME} created..."; 
echo '---------------------------------------------------------------------------------------';

echo '---------------------------------------------------------------------------------------';
echo "
# Following are the commands to set up links and use the remote repository
git remote remove origin
# git remote add origin ssh://git@localhost:50022/opt/gitrepos/gitserver.git # from host
git remote add origin ssh://git@${GITSERVER_NAME}/opt/gitrepos/${GIT_REM_REPO_NAME}.git
git remote -v show origin
git remote -v
git push origin master
"
echo '---------------------------------------------------------------------------------------';



:<<-'EOF------- for setting up docker host -----------------------------------'

export GITSERVER_CONTAINER_NAME=gitserver
export GITSERVER_NAME=gitserver

cat ${HOME}/.ssh/id_rsa.pub >/dev/null && 
echo already exists - not generating new || 
ssh-keygen -f ${HOME}/.ssh/id_rsa -t rsa -b 4096 -q -N "" 

cat ${HOME}/.ssh/id_rsa.pub 

docker cp ${HOME}/.ssh/id_rsa.pub ${GITSERVER_CONTAINER_NAME}:/home/git/.ssh/${HOSTNAME}_id_rsa.pub

docker container exec -itu git -w /home/git ${GITSERVER_CONTAINER_NAME} bash -c "

export TS=$(date +%Y%m%d_%H%M%S%s)
mv -v ~/.ssh/authorized_keys ~/.ssh/authorized_keys_previous_${TS}
chmod 0600 ~/.ssh/authorized_keys_previous

test -e ~/.ssh/authorized_keys \
  && cp -v ~/.ssh/authorized_keys ~/.ssh/authorized_keys_previous_${TS} \
  || touch ~/.ssh/authorized_keys ~/.ssh/authorized_keys_previous_${TS} 

sed \"/${HOSTNAME}/d\" ~/.ssh/authorized_keys_previous_${TS} > ~/.ssh/authorized_keys

cat /home/git/.ssh/${HOSTNAME}_id_rsa.pub >> ~/.ssh/authorized_keys

echo 'authorized_keys after append'
cat ~/.ssh/authorized_keys 
"

ssh git@localhost -p 50022 list

echo '---------------------------------------------------------------------------------------';
echo "------ add gitserver ssh fingerprint to known_hosts and test access to git repository";
echo '---------------------------------------------------------------------------------------';
# https://www.techrepublic.com/article/how-to-easily-add-an-ssh-fingerprint-to-your-knownhosts-file-in-linux/
docker exec -itu git ${GITSERVER_CONTAINER_NAME} sh -c "
ssh-keyscan -H ${GITSERVER_NAME} > ~/.ssh/known_hosts_for_${HOSTNAME}
"
docker cp ${GITSERVER_CONTAINER_NAME}:/home/git/.ssh/known_hosts_for_${HOSTNAME} ./

EOF------- for setting up docker host -----------------------------------
