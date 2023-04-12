#!/usr/bin/env bash
set -e
source /tools/Xilinx/Vitis/2022.2/settings64.sh
source /opt/xilinx/xrt/setup.sh

scratch=
if [[ -e /scratch/$USER ]] ; then
    scratch=/scratch/$USER
else
    scratch=/scratch
fi 

rsync -ahvu --progress /tools/repo/Xilinx/Alveo-PYNQ/pynq_alveo_examples/notebooks $scratch/pynq-notebooks
cd $scratch/pynq-notebooks/notebooks

jupyter lab --ip 127.0.0.1

