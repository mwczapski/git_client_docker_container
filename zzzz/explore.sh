
:<<-'COMMENT-------------------'
  type -a, 
  declare -a, declare -f, declare -p, 
  memtop, 
  man builtin, 
  fc, 
  help xx,
  caller builtin,
  BASH_COMMAND, HOSTFILE, PROMPT_DIRTRIM, 

set -x
set +x
COMMENT-------------------

: '
COMMENT - works as long as there is at least one space between : and single quote
'
:        "
COMMENT - works as long as there is at least one space between : and double quote
"
:        "COMMENT
 - works as long as there is at least one space between : and double quote
COMMENT"


set -o pipefail
set -o errexit

function traperr() {
  echo "ERROR: ------------------------------------------------"
  echo "ERROR: ${BASH_SOURCE[1]} at about ${BASH_LINENO[0]}"
  echo "ERROR: ------------------------------------------------"
}
set -o errtrace
trap traperr ERR

  # declare -a __PORT_MAPPINGS
  # __PORT_MAPPINGS[0]=3101:3100
  # __PORT_MAPPINGS[1]=5001:5000
  # __PORT_MAPPINGS[2]=48080:8080
  # echo ${__PORT_MAPPINGS[0]}
  # echo ${__PORT_MAPPINGS[1]}
  # echo ${__PORT_MAPPINGS[2]}
  # echo ${#__PORT_MAPPINGS}

  echo '=========================================='
  declare -a __PORT_MAPPINGS=(
    127.0.0.1:3101:3100/tcp
    127.0.0.1:5001:5000/tcp
    127.0.0.1:48080:8080/tcp
  )
  declare -i __PORT_MAPPINGS_LEN=${#__PORT_MAPPINGS[@]}
  # for ((i=0; i<${__PORT_MAPPINGS_LEN}; i++)) {
  #   echo ${__PORT_MAPPINGS[${i}]};
  # }

  cat <<-EOF > aa.txt
  # this is a test
  $( for ((i=0; i<${__PORT_MAPPINGS_LEN}; i++)) { echo ${__PORT_MAPPINGS[${i}]}; })
  # this is a test
EOF

  # __MAPPED_HOST_PORTS=3101
  # __MAPPED_GUEST_PORTS=3100
  # __CONTAINER_MAPPED_PORTS="127.0.0.1:${__MAPPED_HOST_PORT_1}:${__MAPPED_GUEST_PORT_1}/tcp"





function fn__FuncLine {
  local callerShellLine=${1?"${FUNCNAME} requires LINENO as the first argument"}
  local callerEntryPointLine=${2?"${FUNCNAME} requires line number of the calling function's name line as the second argument (entryPoint)"}
  local __fnLine=0
  let __fnLine=${callerShellLine}-${callerEntryPointLine}
  echo ${__fnLine}
  return 0
}

function fn__Test {
  return 12
}

function fn__DumpInfo {
  local entryPoint=$((${LINENO}-1))
  echo "--------- ${FUNCNAME}:${entryPoint} --------------"
  echo "\$#: |$#|"
  echo "\$@: |$@|"
  echo "\$*: |$*|"
  echo "BASH_SUBSHELL: |${BASH_SUBSHELL}|"
  echo "SHLVL: |${SHLVL}|"
  # echo "DIRSTACK: |${DIRSTACK}|"
  # echo "GROUPS: |${GROUPS}|"
  # echo "PIPESTATUS: |${PIPESTATUS}|"
  echo -n "caller: " && caller

  echo $(fn__FuncLine $LINENO $entryPoint)  # this line number from the top of this function
  # fn__Test
  echo "______Done____ in ${FUNCNAME}"  
echo
}

# # declare -a
# echo "--------- top level --------------"
# echo "\$#: |$#|"
# echo "\$@: |$@|"
# echo "\$*: |$*|"
# echo "\$\$: |$$|"
# echo "\$_: |$_|"
# echo "BASH_SUBSHELL: |${BASH_SUBSHELL}|"
# echo "EUID: |${EUID}|"
# echo "PPID: |${PPID}|"
# echo "SHLVL: |${SHLVL}|"
# echo "BASH_ARGC: |${BASH_ARGC}|"
# echo "BASH_ARGV: |${BASH_ARGV}|"
# echo "BASH_LINENO: |${BASH_LINENO}|"
# echo "BASH_SOURCE: |${BASH_SOURCE}|"
# echo "BASH_VERSINFO: |${BASH_VERSINFO}|"
# # echo "GROUPS: |${GROUPS}|"
# # echo "PIPESTATUS: |${PIPESTATUS}|"
# # echo -n "caller: " && caller

# echo "______Done____ in ${SHELL}"
# echo

# fn__DumpInfo -c -d "Hello" "Two" "Three"
