dpu=

if [[ ! -n $VAI_ROOT ]] ; then
    echo VAI_ROOT is not set!
    exit
fi

if [ $# -ge 1 ] ; then
    case $1 in
        DPUCVDX8H_8pe_normal | DPUCVDX8H_6pe_dwc | DPUCVDX8H_6pe_misc | DPUCVDX8H_4pe_miscdwc )
            dpu=$1
        ;;
    esac
fi

if [[ $dpu == "" ]] ; then
#    dpu=$(echo "DPUCVDX8H_8pe_normal
#DPUCVDX8H_6pe_dwc
#DPUCVDX8H_6pe_misc
#DPUCVDX8H_4pe_miscdwc" | peco --prompt "Select DPU >" --on-cancel error)
    dpu=DPUCVDX8H_8pe_normal
fi

if [ $? -eq 0 ] ; then
    # Setup env for selected DPU
    echo "$dpu is selected"
    source $VAI_ROOT/workspace/setup/vck5000/setup.sh $dpu > /dev/null

    if [[ $dpu == "DPUCVDX8H_8pe_normal" ]] ; then
        export VAI_LIBRARY_MODELS_DIR=/usr/share/vitis_ai_library/models/vck5000-DPUCVDX8H-8pe
    elif [[ $dpu == "DPUCVDX8H_6pe_dwc" ]] ; then
        export VAI_LIBRARY_MODELS_DIR=/usr/share/vitis_ai_library/models/vck5000-DPUCVDX8H-6pe-aieDWC
    elif [[ $dpu == "DPUCVDX8H_6pe_misc" ]] ; then
        export VAI_LIBRARY_MODELS_DIR=/usr/share/vitis_ai_library/models/vck5000-DPUCVDX8H-6pe-aieMISC
    elif [[ $dpu == "DPUCVDX8H_4pe_miscdwc" ]] ; then
        export VAI_LIBRARY_MODELS_DIR=/usr/share/vitis_ai_library/models/vck5000-DPUCVDX8H-4pe
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

    # Show progress
    #while jobs %% >& /dev/null ; do
    #    status=$(dmesg | grep xfer_versal | tail -n 1 | grep write | grep remain || true)
    #    if [[ -n $status ]] ; then
	  #  write=$(echo $status | sed -r 's/^.*write\s+([0-9]+).*$/\1/')
	  #  remain=$(echo $status | sed -r 's/^.*remain\s+([0-9]+).*$/\1/')
	  #  echo -n -e "\r  Progress : $((100*$write/($write+$remain)))%"
    #    fi
    #    sleep 0.5
    #done
fi
