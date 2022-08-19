
pushd docker

tag=acri-as:latest
card=vck5000
vai=20
acri=yes
xrt="https://www.xilinx.com/bin/public/openDownload?filename=xrt_202120.2.12.427_18.04-amd64-xrt.deb"
platform="https://www.xilinx.com/bin/public/openDownload?filename=xilinx-vck5000-prod-gen3x16-platform-1-0_all.deb.tar.gz"

#tag=acri-as-tool:latest
#card=no
#vai=no
#acri=yes
#xrt="https://www.xilinx.com/bin/public/openDownload?filename=xrt_202120.2.12.427_18.04-amd64-xrt.deb"
#platform=

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
  --build-arg XRT_PACKAGE_URL=$xrt \
  --build-arg PLATFORM_TAR_GZ_URL=$platform \
  --target user \
  -t $tag \
  -f Dockerfile.vck5000 . \
  --load

popd

