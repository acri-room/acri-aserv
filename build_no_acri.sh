#!/usr/bin/env bash

pushd docker

card=vck5000
vai=20

#card=no
#vai=no

docker buildx build \
  --build-arg CARD=$card \
  --build-arg ENABLE_VAI=$vai \
  --build-arg ACRI=no \
  --build-arg XRT_PACKAGE_URL="https://www.xilinx.com/bin/public/openDownload?filename=xrt_202120.2.12.427_18.04-amd64-xrt.deb" \
  --build-arg PLATFORM_TAR_GZ_URL="https://www.xilinx.com/bin/public/openDownload?filename=xilinx-vck5000-prod-gen3x16-platform-1-0_all.deb.tar.gz" \
  --target user \
  -t acri-as:latest \
  -f Dockerfile.vck5000 . \
  --load

popd

