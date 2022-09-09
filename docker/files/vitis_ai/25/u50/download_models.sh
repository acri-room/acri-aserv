#!/usr/bin/env bash
set -e

t=$1

VAI_MODELS=/usr/share/vitis_ai_library/models
DPU=${t}
LIST=/tmp/models_${t}.txt

mkdir -p $VAI_MODELS/$DPU

while read -r link ; do
  file=/root/downloads/$(echo $link | sed 's/^.*=//')
  if [[ ! -e $file ]] ; then
    echo "$link"
    echo "$file"
    wget "$link" -O $file
  fi
  cd $VAI_MODELS/$DPU
  # some links are broken...
  tar xf $file || true
done < $LIST
