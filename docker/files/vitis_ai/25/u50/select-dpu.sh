dpu=

if [[ ! -n $VAI_ROOT ]] ; then
    echo VAI_ROOT is not set!
    exit
fi

if [ $# -ge 1 ] ; then
    case $1 in
        DPUCAHX8H )
            dpu=$1
        ;;
    esac
fi

if [[ $dpu == "" ]] ; then
    dpu=DPUCAHX8H
fi

if [ $? -eq 0 ] ; then
    # Setup env for selected DPU
    echo "$dpu is selected"
    source $VAI_ROOT/workspace/setup/alveo/setup.sh $dpu > /dev/null

    if [[ $dpu == "DPUCAHX8H" ]] ; then
        export VAI_LIBRARY_MODELS_DIR=/usr/share/vitis_ai_library/models/DPUCAHX8H
    fi

    # Find device
    dev=$(/opt/xilinx/xrt/bin/xbutil examine | grep "xilinx_[uv]" | sed -r 's/.*\[([0-9:.]+).*/\1/')

    # Get current uuid
    tmp=$(mktemp)
    /opt/xilinx/xrt/bin/xbutil examine --device $dev --report dynamic-regions --format JSON --output $tmp --force > /dev/null
    cur_uuid=$(jq -r '.devices[0].dynamic_regions[0].xclbin_uuid' $tmp)
    cur_uuid=$(echo $cur_uuid | sed 's/\(.*\)/\L\1/')
    rm $tmp

    # Get xclbin uuid
    xclbin_uuid=$(/opt/xilinx/xrt/bin/xclbinutil --input $XLNX_VART_FIRMWARE --info | grep "UUID (xclbin):" | awk '{print $3}')

    # Reset device
    if [[ $cur_uuid != 00000000-0000-0000-0000-000000000000 ]] && [[ $cur_uuid != $xclbin_uuid ]] ; then
        echo "Resetting device..."
        /opt/xilinx/xrt/bin/xbutil reset --device $dev --force > /dev/null
    fi

    # Program device
    echo "Programming device..."
    /opt/xilinx/xrt/bin/xbutil program --user $XLNX_VART_FIRMWARE --device $dev
fi
