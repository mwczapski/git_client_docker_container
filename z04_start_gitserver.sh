#!/bin/bash 

# 20200413_1024 MCz

WSLHERE=$(wslpath -w ./${0})
WSLHERE=${WSLHERE/.sh/.ps1}
powershell.exe "${WSLHERE}"
