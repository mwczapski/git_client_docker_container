
declare -u __env_gitTestClientConstants="SOURCED"

[[ ${__env_devcicd_net} ]] || source __env_devcicd_net.sh
[[ ${__env_gitserverConstants} ]] || source ./utils/__env_gitserverConstants.sh

#readonly _GIT_HOST_PPORT_=50022
#readonly _GIT_GUEST_PPORT_=22

#readonly __GIT_USERNAME="git"
readonly __GIT_TEST_CLIENT_USERNAME="gittest"
readonly __GIT_TEST_CLIENT_NAME="gittestclient"
readonly __GIT_TEST_CLIENT_SHELL="/bin/bash"
readonly __GIT_TEST_CLIENT_SHELL_GLOBAL_PROFILE="/etc/profile"
readonly __GIT_TEST_CLIENT_SHELL_PROFILE=".bash_profile"
readonly __GIT_TEST_CLIENT_IMAGE_NAME="gittestclient"
readonly __GIT_TEST_CLIENT_IMAGE_VERSION="1.0.0"
readonly __GIT_TEST_CLIENT_HOST_NAME="gittestclient"
readonly __GIT_TEST_CLIENT_CONTAINER_NAME="gittestclient"
readonly __GIT_TEST_CLIENT_GUEST_HOME="/home/${__GIT_TEST_CLIENT_USERNAME}"
#readonly __GITSERVER_MAPPED_PORTS="--publish=127.0.0.1:${_GIT_HOST_PPORT_}:${_GIT_GUEST_PPORT_}/tcp"
#         __GITSERVER_PORT_MAPPINGS[0]="127.0.0.1:${_GIT_HOST_PPORT_}:${_GIT_GUEST_PPORT_}/tcp"  # can't be readonly - gives exception
#readonly __GITSERVER_ADDHOST="--add-host=${__GITSERVER_NAME}:${GITSERVER_STATIC_SERVER_IP}"
#readonly __GITSERVER_REPOS_ROOT="/opt/gitrepos"
#readonly __GITSERVER_GUEST_HOME="/home/${__GIT_USERNAME}"
#readonly __GITSERVER_HOST_BACKUP_DIR="${__GITSERVER_GUEST_HOME}/backups"
#readonly __GITSERVER_REM_TEST_REPO_NAME="gittest"
