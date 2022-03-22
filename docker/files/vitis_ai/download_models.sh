#!/usr/bin/env bash
set -e

VAI_MODELS=/usr/share/vitis_ai_library/models
DPU=$1
LIST=$2

mkdir -p $VAI_MODELS/$DPU

while read -r link ; do
  echo "$link"
  wget "$link" -O /tmp/model.tar.gz
  cd $VAI_MODELS/$DPU
  tar xf /tmp/model.tar.gz
  rm /tmp/model.tar.gz
done < $LIST

