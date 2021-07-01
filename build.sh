#!/usr/bin/env bash
set -e

cur=$(dirname $(readlink -f $0))
host=$(hostname -s)

cd $cur/docker

case $host in
  aserv1 | gserv1 )
    echo U200
    docker build -t acri-as:latest -f Dockerfile .
    ;;
  aserv2 )
    echo U250
    docker build -t acri-as:latest -f Dockerfile --build-arg PLATFORM="xilinx_u250_xdma_201830_2" .
    ;;
  aserv3 )
    echo U280-ES1
    docker build -t acri-as:latest -f Dockerfile.u280-es1 .
    ;;
  aserv4 )
    echo U50
    docker build -t acri-as:latest -f Dockerfile.u50 .
    ;;
esac

case $host in
  aserv1 | aserv2 | aserv3 | aserv4 )
    echo Tool
    docker build -t acri-as-tool:latest -f Dockerfile.tool .
    ;;
esac
