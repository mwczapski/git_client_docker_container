#!/bin/bash
set -e

# see https://success.docker.com/article/use-a-script-to-initialize-stateful-container-data

# start ssh server each time the entrypoint script runs
service ssh start

# prevent container from exiting after successfull startup
exec /bin/bash -c 'while true; do sleep 100000; done'

