#!/usr/bin/env bash

pushd docker

card=vck5000
vai=25

#card=no
#vai=no

#xrt="https://www.xilinx.com/bin/public/openDownload?filename=xrt_202120.2.12.427_18.04-amd64-xrt.deb"
#platform="https://www.xilinx.com/bin/public/openDownload?filename=xilinx-vck5000-prod-gen3x16-platform-1-0_all.deb.tar.gz"
#xrt="https://www.xilinx.com/bin/public/openDownload?filename=xrt_202120.2.12.427_18.04-amd64-xrt.deb"
#xrt_apu=
#platform_tgz="https://www.xilinx.com/bin/public/openDownload?filename=xilinx-vck5000-prod-gen3x16-platform-1-0_all.deb.tar.gz"
#platform_deb=

xrt="https://www.xilinx.com/bin/public/openDownload?filename=xrt_202210.2.13.478_18.04-amd64-xrt.deb"
xrt_apu="https://www.xilinx.com/bin/public/openDownload?filename=xrt-apu_202210.2.13.0_all.deb"
platform_tgz=
platform_deb="https://www.xilinx.com/bin/public/openDownload?filename=xilinx-vck5000-gen4x8-xdma-base_2-20220513_all.deb"

opts=
opts="$opts --cache-from=type=local,src=/tmp/buildx-cache"
opts="$opts --cache-to=type=local,dest=/tmp/buildx-cache"
opts="$opts --build-arg http_proxy=http://192.168.1.200:3128"
opts="$opts --build-arg https_proxy=http://192.168.1.200:3128"
opts="$opts --build-arg HTTP_PROXY=http://192.168.1.200:3128"
opts="$opts --build-arg HTTPS_PROXY=http://192.168.1.200:3128"

set -x

docker buildx build \
  $opts \
  --build-arg CARD=$card \
  --build-arg ENABLE_VAI=$vai \
  --build-arg ACRI=no \
  --build-arg XRT_PACKAGE_URL="$xrt" \
  --build-arg XRT_APU_PACKAGE_URL="$xrt_apu" \
  --build-arg PLATFORM_TAR_GZ_URL="$platform_tgz" \
  --build-arg PLATFORM_DEB_URL="$platform_deb" \
  --target user \
  -t acri-as:latest \
  -f Dockerfile . \
  --load

popd

