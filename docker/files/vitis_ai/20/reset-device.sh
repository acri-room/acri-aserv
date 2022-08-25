dev=$(/opt/xilinx/xrt/bin/xbutil examine | grep "xilinx_[uv]" | sed -r 's/.*\[([0-9:.]+).*/\1/')
/opt/xilinx/xrt/bin/xbutil reset --device $dev $*
