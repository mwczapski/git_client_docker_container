

# 20200413_1024 MCz
# 20200427_1230 MCz

$DEVCICD_NET_DC_INTERNAL = "devcicd_net"
$DEVCICD_NET = "docker_" + $DEVCICD_NET_DC_INTERNAL
$DEVCICD_SUBNET_ADDRESS = (docker network inspect $DEVCICD_NET | grep 'Subnet' | sed 's/^.*: .//;s/.[0-9]..$//;s|\",||')
$DEVCICD_NET_PREFIX = (docker network inspect $DEVCICD_NET | grep 'Gateway' | sed 's/^.*: .//;s/.[0-9]..$//' )
$GITSERVER_STATIC_SERVER_IP = $DEVCICD_NET_PREFIX + ".250"


$GITSERVER_USERNAME = "gitserver"
$GITSERVER_IMAGE_VERSION = "1.0.0"
$GITSERVER_CONTAINER_NAME = $GITSERVER_USERNAME
$CONTAINER_MAPPED_PORTS = "--publish=127.0.0.1:50022:22/tcp"
$GITSERVER_REPOS_ROOT = "/opt/gitrepos"
$GITSERVER_REM_TEST_REPO_NAME = "gittest"

Write-Output '-----------------------------------------------------------------'

if (docker container ls | grep $GITSERVER_CONTAINER_NAME) { 
  Write-Output '-----------------------------------------------------------------'
  Write-Output '------ Container already running'; 
  Write-Output '-----------------------------------------------------------------'
  exit 
}

$env:Path = $env:Path + ';C:\Program Files\Docker\Docker\resources\bin'

Write-Output '-----------------------------------------------------------------'

if (docker container ls -a | grep $GITSERVER_CONTAINER_NAME) { 
  Write-Output "------ Container ${GITSERVER_CONTAINER_NAME} stopped - starting it"

  &docker.exe container start ${GITSERVER_CONTAINER_NAME};
}
else {

  # no longer removing - will preserve container accross stop commands
  #   --rm `
  # --ip=$GITSERVER_STATIC_SERVER_IP `
  &docker.exe `
    run `
    --network=${DEVCICD_NET} `
    --hostname "${GITSERVER_USERNAME}" `
    ${CONTAINER_MAPPED_PORTS} `
    -v "d:/gitserver/gitserver:${GITSERVER_REPOS_ROOT}" `
    -itu root `
    --workdir="${GITSERVER_REPOS_ROOT}" `
    --detach `
    --name "${GITSERVER_CONTAINER_NAME}" `
    "${GITSERVER_CONTAINER_NAME}:${GITSERVER_IMAGE_VERSION}"

}
Write-Output '-----------------------------------------------------------------'

Write-Output '-----------------------------------------------------------------'
docker container ls | grep $GITSERVER_CONTAINER_NAME
docker container exec -itu root $GITSERVER_CONTAINER_NAME sh -c "service ssh start"
Write-Output '-----------------------------------------------------------------'

write-output '---------------------------------------------------------------------------------------';
write-output '------ setting ownership on gitrepos to git:developers'; 
write-output '---------------------------------------------------------------------------------------';
docker exec -itu root ${GITSERVER_CONTAINER_NAME} bash -c "
# ls -al ${GITSERVER_REPOS_ROOT}
chmod -R g+sx ${GITSERVER_REPOS_ROOT}
chown -R git:developers ${GITSERVER_REPOS_ROOT}
# ls -al ${GITSERVER_REPOS_ROOT}
"

write-output '---------------------------------------------------------------------------------------';
write-output "------ As root on ${GITSERVER_CONTAINER_NAME}, creating Remote repository to test";
write-output '---------------------------------------------------------------------------------------';
docker container exec -itu root ${GITSERVER_CONTAINER_NAME} bash -c "
[[ -d ${GITSERVER_REPOS_ROOT}/${GITSERVER_REM_TEST_REPO_NAME}.git ]] && rm -Rf ${GITSERVER_REPOS_ROOT}/${GITSERVER_REM_TEST_REPO_NAME}.git
mkdir -p ${GITSERVER_REPOS_ROOT}/${GITSERVER_REM_TEST_REPO_NAME}.git
chown -R git:developers ${GITSERVER_REPOS_ROOT}
chmod +s ${GITSERVER_REPOS_ROOT}
cd ${GITSERVER_REPOS_ROOT}/${GITSERVER_REM_TEST_REPO_NAME}.git
su - -s /bin/bash -c 'git init --bare' git 
# ls -al 
"

# @REM # https://medium.com/@nielssj/docker-volumes-and-file-system-permissions-772c1aee23ca
# @REM # https://github.com/docker/for-win/issues/497
# @REM # add docker-users with full control to host directory to be bound to docker volume
# @REM # 
