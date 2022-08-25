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
    # Setup env for selected DPU
    echo "$dpu was selected"
    source $VAI_ROOT/workspace/setup/vck5000/setup.sh $dpu > /dev/null

    if [[ $dpu == "DPUCVDX8H" ]] ; then
        export VAI_LIBRARY_MODELS_DIR=/usr/share/vitis_ai_library/models/vck50008pe-DPUCVDX8H
    elif [[ $dpu == "DPUCVDX8H-DWC" ]] ; then
        export VAI_LIBRARY_MODELS_DIR=/usr/share/vitis_ai_library/models/vck50006pe-DPUCVDX8H-DWC
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
    /opt/xilinx/xrt/bin/xbutil program --user $XLNX_VART_FIRMWARE --device $dev &

    # Show progress
    while jobs %% >& /dev/null ; do
        status=$(dmesg | grep xfer_versal | tail -n 1 | grep write | grep remain || true)
        if [[ -n $status ]] ; then
	    write=$(echo $status | sed -r 's/^.*write\s+([0-9]+).*$/\1/')
	    remain=$(echo $status | sed -r 's/^.*remain\s+([0-9]+).*$/\1/')
	    echo -n -e "\r  Progress : $((100*$write/($write+$remain)))%"
        fi
        sleep 0.5
    done
fi
