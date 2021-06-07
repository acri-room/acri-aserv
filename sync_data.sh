#!/usr/bin/env bash
set -e

function sync_dir {
  local dir=$1
  mkdir -p $dir
  rsync -ahzv --progress root@aserv1:$dir/* $dir
}

sync_dir /tools/repo
sync_dir /tools/data
