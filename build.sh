#!/usr/bin/env bash
set -e

cur=$(dirname $(readlink -f $0))
host=$(hostname -s)

cd $cur/docker

args=$*

function build() {
  set -x
  docker buildx build \
    --build-arg CARD=$card \
    --build-arg ENABLE_VAI=$vai \
    --build-arg ACRI=$acri \
    --build-arg XRT_PACKAGE_URL="$xrt" \
    --build-arg XRT_APU_PACKAGE_URL="$xrt_apu" \
    --build-arg PLATFORM_TAR_GZ_URL="$platform_tgz" \
    --build-arg PLATFORM_DEB_URL="$platform_deb" \
    --target user \
    -t $tag \
    -f Dockerfile . \
    $args \
    --load
  set +x
}

###############################
## Build Alveo container image
###############################

tag=acri-as:latest
acri=yes

xrt_apu=
platform_tgz=
platform_deb=

case $host in
  aserv1 | gserv1 )
    echo U200
    card=u200
    vai=no
    xrt="https://www.xilinx.com/bin/public/openDownload?filename=xrt_202220.2.14.354_20.04-amd64-xrt.deb"
    platform_tgz="https://www.xilinx.com/bin/public/openDownload?filename=xilinx-u200-gen3x16-xdma_2022.2_2022_1015_0317-all.deb.tar.gz"
    build
    ;;
  aserv2 )
    echo U250
    card=u250
    vai=no
    xrt="https://www.xilinx.com/bin/public/openDownload?filename=xrt_202220.2.14.354_20.04-amd64-xrt.deb"
    platform_tgz="https://www.xilinx.com/bin/public/openDownload?filename=xilinx-u250-gen3x16-xdma_2022.2_2022_1015_0317-all.deb.tar.gz"
    build
    ;;
  aserv3 )
    echo U280-ES1
    card=u280es1
    vai=no
    xrt="https://www.xilinx.com/bin/public/openDownload?filename=xrt_202010.2.7.766_18.04-amd64-xrt.deb"
    platform_deb="https://www.xilinx.com/bin/public/openDownload?filename=xilinx-u280-es1-xdma-201910.1-2579327_18.04.deb"
    build
    ;;
  aserv4 )
    echo U50
    card=u50
    vai=no
    xrt="https://www.xilinx.com/bin/public/openDownload?filename=xrt_202220.2.14.354_20.04-amd64-xrt.deb"
    platform_tgz="https://www.xilinx.com/bin/public/openDownload?filename=xilinx-u50-gen3x16-xdma_2022.2_2022_1015_0317-all.deb.tar.gz"
    build
    ;;
  aserv5 )
    echo VCK5000
    card=vck5000
    vai=no
    xrt="https://www.xilinx.com/bin/public/openDownload?filename=xrt_202220.2.14.384_20.04-amd64-xrt.deb"
    xrt_apu="https://www.xilinx.com/bin/public/openDownload?filename=xrt-apu-vck5000_202220.2.14.384_petalinux_all.deb"
    platform_tgz="https://www.xilinx.com/bin/public/openDownload?filename=xilinx-vck5000-gen4x8-qdma_2022.2_2022_1212_1124-all.deb.tar.gz"
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
xrt=
xrt_apu=
platform_tgz=
platform_deb=

case $host in
  aserv1 | aserv2 | aserv3 | aserv4 | aserv5)
    echo Tool
    xrt="https://www.xilinx.com/bin/public/openDownload?filename=xrt_202220.2.14.354_20.04-amd64-xrt.deb"
    build
    ;;
esac
