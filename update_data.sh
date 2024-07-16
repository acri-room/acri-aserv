#!/usr/bin/env bash
set -e

repo_dir=/tools/repo
data_dir=/tools/data

function make_dir {
  local dir=$1
  if [ ! -e $dir ] ; then
    mkdir -p $dir
  fi
}

function update_repo {
  local site=$1
  local user=$2
  local repo=$3
  local branch=$4
  local u_dir=$repo_dir/$user
  local r_dir=$repo_dir/$user/$repo
  echo Updating repo $user/$repo...
  make_dir $u_dir
  if [ ! -e $r_dir ] ; then
    git clone https://${site}/${user}/${repo}.git $r_dir
  else
    pushd $r_dir > /dev/null
    echo -n "  "
    git pull --all
    if [[ -n $branch ]] ; then
      git checkout $branch
    fi
    popd > /dev/null
  fi
}

function download_data {
  local url="$1"
  local file="$2"
  if [ ! -e "$data_dir/$file" ] ; then
    make_dir $(dirname $data_dir/$file)
    echo Downloading data $file...
    wget -O "$data_dir/$file" "$url"
  fi
}

make_dir $repo_dir
make_dir $data_dir

update_repo github.com Xilinx Vitis_Libraries
update_repo github.com Xilinx Vitis-Tutorials 2022.2
update_repo github.com Xilinx Vitis-In-Depth-Tutorial
update_repo github.com Xilinx Vitis_Accel_Examples
update_repo github.com Xilinx Vitis-AI-Tutorials
update_repo github.com Xilinx Vitis-AI
update_repo github.com Xilinx HLS
update_repo github.com Xilinx HLS-Tiny-Tutorials
update_repo github.com Xilinx PYNQ
update_repo github.com Xilinx Alveo-PYNQ
update_repo github.com Xilinx Vitis-HLS-Introductory-Examples
update_repo github.com Xilinx inference-server
update_repo github.com Xilinx rt-engine
update_repo github.com Xilinx pyxir
update_repo github.com Xilinx finn-base
update_repo github.com Xilinx finn
update_repo github.com Xilinx finn-hlslib
update_repo github.com Xilinx brevitas
update_repo github.com Xilinx HPC
update_repo github.com Xilinx ACCL

update_repo github.com acri-room aie-tutorial
update_repo github.com acri-room hls-challenge-labs
update_repo github.com anjn vlib-deflate-benchmark
update_repo github.com kkos oniguruma
update_repo github.com FPGAtestbed vck5000_sum_example

download_data http://sun.aei.polsl.pl/~sdeor/corpus/silesia.zip silesia.zip
download_data https://www.cs.toronto.edu/~kriz/cifar-10-python.tar.gz cifar-10-python.tar.gz
download_data https://storage.googleapis.com/tensorflow/tf-keras-datasets/mnist.npz tf-keras-datasets/mist.npz

download_data https://acri-room.web.app/vadd.hw_emu.xilinx_vck5000_gen4x8_qdma_2_202220_1.xclbin acri-room/aie-tutorial/vadd.hw_emu.xilinx_vck5000_gen4x8_qdma_2_202220_1.xclbin
download_data https://acri-room.web.app/vadd.hw.xilinx_vck5000_gen4x8_qdma_2_202220_1.xclbin acri-room/aie-tutorial/vadd.hw.xilinx_vck5000_gen4x8_qdma_2_202220_1.xclbin

