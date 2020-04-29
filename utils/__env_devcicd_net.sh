
_DOCKER_NO_EXT="docker"
_DOCKER_EXE="docker.exe"

readonly __DEVCICD_NET_DC_INTERNAL="devcicd_net"
readonly __DEVCICD_NET="docker_${__DEVCICD_NET_DC_INTERNAL}"
readonly __DEVCICD_SUBNET_ADDRESS="$(${_DOCKER_EXE} network inspect ${__DEVCICD_NET} | grep 'Subnet' | sed 's|"Subnet": "||;s|",$||')"
readonly __DEVCICD_NET_PREFIX=$(${_DOCKER_EXE} network inspect ${__DEVCICD_NET} | grep 'Gateway' | sed 's/^.*: .//;s/.[0-9].1$//;s|.1"||' )
readonly __DEVCICD_SUBNET_GATEWAY=${__DEVCICD_NET_PREFIX}.1
readonly GITSERVER_STATIC_SERVER_IP=${__DEVCICD_NET_PREFIX}.250

# echo $__DEVCICD_NET_DC_INTERNAL
# echo $__DEVCICD_NET
# echo $__DEVCICD_SUBNET_ADDRESS
# echo $__DEVCICD_NET_PREFIX
# echo $__DEVCICD_SUBNET_GATEWAY
# echo $GITSERVER_STATIC_SERVER_IP
