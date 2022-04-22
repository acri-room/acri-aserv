dpu=

if [ $# -ge 1 ] ; then
    case $1 in
        DPUCVDX8H | DPUCVDX8H-DWC )
            dpu=$1
        ;;
    esac
fi

if [[ $dpu == "" ]] ; then
    dpu=$(echo "DPUCVDX8H
DPUCVDX8H-DWC" | peco --prompt "Select DPU >" --on-cancel error)
fi

if [ $? -eq 0 ] ; then
    echo "$dpu was selected"
    source $VAI_ROOT/workspace/setup/vck5000/setup.sh $dpu > /dev/null
    dev=$(/opt/xilinx/xrt/bin/xbutil examine | grep "xilinx_[uv]" | sed -r 's/.*\[([0-9:.]+).*/\1/')
    echo "Downloading an xclbin to the device..."
    /opt/xilinx/xrt/bin/xbutil program --user $XLNX_VART_FIRMWARE --device $dev \
        || { echo "!!Reset device!!" ; exit 1 ; }
    if [[ $dpu == "DPUCVDX8H" ]] ; then
        export VAI_LIBRARY_MODELS_DIR=/usr/share/vitis_ai_library/models/vck50008pe-DPUCVDX8H
    elif [[ $dpu == "DPUCVDX8H-DWC" ]] ; then
        export VAI_LIBRARY_MODELS_DIR=/usr/share/vitis_ai_library/models/vck50006pe-DPUCVDX8H-DWC
    fi
fi
