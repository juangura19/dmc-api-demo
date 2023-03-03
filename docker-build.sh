#!/bin/bash
# ejemplo latest: ./docker-build.sh
# ejemplo con v13: ./docker-build.sh v13
set -x

TAG="latest"
if [ ! -z $1 ]; then
    TAG=$1
fi

docker build -t francisjosue/dmc-api:$TAG ./
