#!/usr/bin/env/bash
image=$1
tag=$2

mkdir -p /tools/docker/$image

docker save $image:$tag > /tools/docker/$image/$tag.tar

