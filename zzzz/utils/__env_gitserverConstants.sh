
readonly __GIT_USERNAME="git"
readonly __GITSERVER_USERNAME="gitserver"
readonly __GITSERVER_NAME="gitserver"
readonly __GITSERVER_SHELL="/bin/bash"
readonly __GITSERVER_IMAGE_VERSION="1.0.0"
readonly __GITSERVER_CONTAINER_NAME=${GITSERVER_USERNAME}
readonly __GITSERVER_MAPPED_PORTS="--publish=127.0.0.1:50022:22/tcp"
readonly __GITSERVER_ADDHOST="--add-host=${__GITSERVER_NAME}:${GITSERVER_STATIC_SERVER_IP}"
readonly __GITSERVER_REPOS_ROOT="/opt/gitrepos"
readonly __GITSERVER_REM_TEST_REPO_NAME="gittest"
