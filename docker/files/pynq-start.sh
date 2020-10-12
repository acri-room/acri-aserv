#!/usr/bin/env bash
set -e
source /tools/Xilinx/Vitis/2019.2/settings64.sh
source /opt/xilinx/xrt/setup.sh

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/opt/vitis_ai/conda/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/opt/vitis_ai/conda/etc/profile.d/conda.sh" ]; then
        . "/opt/vitis_ai/conda/etc/profile.d/conda.sh"
    else
        export PATH="/opt/vitis_ai/conda/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

conda activate pynq

rsync -ahvu --progress /opt/pynq-notebooks /scratch
cd /scratch/pynq-notebooks

jupyter lab --ip 0.0.0.0
