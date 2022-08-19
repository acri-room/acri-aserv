#!/usr/bin/env bash
set -e

cur=$(dirname $(readlink -f $0))
host=$(hostname -s)

cd $cur/docker

function build() {
#  --cache-from=type=local,src=/tmp/buildx-cache \
#  --cache-to=type=local,dest=/tmp/buildx-cache \
#  --build-arg http_proxy=http://192.168.1.200:3128 \
#  --build-arg https_proxy=http://192.168.1.200:3128 \
#  --build-arg HTTP_PROXY=http://192.168.1.200:3128 \
#  --build-arg HTTPS_PROXY=http://192.168.1.200:3128 \

  docker buildx build \
    --build-arg CARD=$card \
    --build-arg ENABLE_VAI=$vai \
    --build-arg ACRI=$acri \
    --build-arg XRT_PACKAGE_URL="$xrt" \
    --build-arg PLATFORM_TAR_GZ_URL="$platform_tgz" \
    --build-arg PLATFORM_DEB_URL="$platform_deb" \
    --target user \
    -t $tag \
    -f Dockerfile.vck5000 . \
    --load
}

###############################
## Build Alveo container image
###############################

tag=acri-as:latest
acri=yes
platform_tgz=
platform_deb=

case $host in
  aserv1 | gserv1 )
    echo U200
    card=u200
    vai=no
    xrt="https://www.xilinx.com/bin/public/openDownload?filename=xrt_202120.2.12.427_18.04-amd64-xrt.deb"
    platform_deb="https://www.xilinx.com/bin/public/openDownload?filename=xilinx-u200-xdma-201830.2-2580015_18.04.deb"
    build
    ;;
  aserv2 )
    echo U250
    card=u250
    vai=no
    xrt="https://www.xilinx.com/bin/public/openDownload?filename=xrt_202120.2.12.427_18.04-amd64-xrt.deb"
    platform_deb="https://www.xilinx.com/bin/public/openDownload?filename=xilinx-u250-xdma-201830.2-2580015_18.04.deb"
    build
    ;;
  aserv3 )
    echo U280-ES1
    card=u280es1
    vai=no
    xrt="https://www.xilinx.com/bin/public/openDownload?filename=xrt_202120.2.12.427_18.04-amd64-xrt.deb"
    platform_deb="https://www.xilinx.com/bin/public/openDownload?filename=xilinx-u280-es1-xdma-201910.1-2579327_18.04.deb"
    build
    ;;
  aserv4 )
    echo U50
    card=u50
    vai=no
    xrt="https://www.xilinx.com/bin/public/openDownload?filename=xrt_202120.2.12.427_18.04-amd64-xrt.deb"
    platform_tgz="https://www.xilinx.com/bin/public/openDownload?filename=xilinx-u50_2021.2_2021_1021_1001-all.deb.tar.gz"
    build
    ;;
  aserv5 )
    echo VCK5000
    card=vck5000
    vai=20
    xrt="https://www.xilinx.com/bin/public/openDownload?filename=xrt_202120.2.12.427_18.04-amd64-xrt.deb"
    platform_tgz="https://www.xilinx.com/bin/public/openDownload?filename=xilinx-vck5000-prod-gen3x16-platform-1-0_all.deb.tar.gz"
    build
    ;;
esac

###############################
## Build tool container image
###############################

tag=acri-as-tool:latest
card=no
vai=no
acri=yes
platform_tgz=
platform_deb=

case $host in
  aserv1 | aserv2 | aserv3 | aserv4 | aserv5 )
    echo Tool
    xrt="https://www.xilinx.com/bin/public/openDownload?filename=xrt_202120.2.12.427_18.04-amd64-xrt.deb"
    build
    ;;
esac
