set -e

demo=$(echo "\
VART | resnet50 | DPUCVDX8H
VART | resnet50 | DPUCVDX8H-DWC
VART | resnet50_pt | DPUCVDX8H
VART | resnet50_pt | DPUCVDX8H-DWC
VART | resnet50_ext | DPUCVDX8H
VART | resnet50_ext | DPUCVDX8H-DWC
VART | resnet50_mt_py | DPUCVDX8H
VART | resnet50_mt_py | DPUCVDX8H-DWC
VART | inception_v1_mt_py | DPUCVDX8H
VART | inception_v1_mt_py | DPUCVDX8H-DWC
VART | pose_detection | DPUCVDX8H
VART | pose_detection | DPUCVDX8H-DWC
VART | video_analysis | DPUCVDX8H
VART | video_analysis | DPUCVDX8H-DWC
VART | adas_detection | DPUCVDX8H
VART | adas_detection | DPUCVDX8H-DWC
VART | segmentation | DPUCVDX8H
VART | segmentation | DPUCVDX8H-DWC
VART | squeezenet_pytorch | DPUCVDX8H
VART | squeezenet_pytorch | DPUCVDX8H-DWC
" | peco --prompt "Select Demo >")

if [[ -z $demo ]] ; then
    echo Canceled
    exit
fi

function message() {
    echo -e "\e[32m$1\e[m"
}
function message_bold() {
    echo -e "\e[1;32m$1\e[m"
}

function info_gui_quit() {
    sleep 1
    echo
    message_bold "To quit, type 'q' on the window"
    echo
}

cat=$(echo "$demo" | awk -F '|' '{print $1}' | tr -d ' ')
app=$(echo "$demo" | awk -F '|' '{print $2}' | tr -d ' ')
dpu=$(echo "$demo" | awk -F '|' '{print $3}' | tr -d ' ')

if [[ -z $VAI_ROOT ]] ; then
    message "Setup Vitis AI"
    source /opt/vitis_ai/setup.sh > /dev/null
fi

message "Program DPU"
#source /opt/vitis_ai/select-dpu-vck5000.sh $dpu
source select-dpu-vck5000.sh $dpu

# VART

message "Move to demo directory"
echo Directory : /opt/vitis_ai/workspace/demo/VART/$app
cd /opt/vitis_ai/workspace/demo/VART/$app

if [[ ! -e ./$app ]] && [[ -e ./build.sh ]] ; then
    message "Build demo"
    ./build.sh
fi

message "Run demo"
function run() {
    echo Command : $*
    $*
}
case $app in
    resnet50 )
        info_gui_quit &
        run ./resnet50 \
            $VAI_LIBRARY_MODELS_DIR/resnet50/resnet50.xmodel
    ;;
    resnet50_pt )
        run ./resnet50_pt \
            $VAI_LIBRARY_MODELS_DIR/resnet50_pt/resnet50_pt.xmodel \
            ../images/001.jpg
    ;;
    resnet50_ext )
        run ./resnet50_ext \
            $VAI_LIBRARY_MODELS_DIR/resnet50/resnet50.xmodel \
            ../images/001.jpg
    ;;
    resnet50_mt_py )
        run /usr/bin/python3 resnet50.py 1 \
            $VAI_LIBRARY_MODELS_DIR/resnet50/resnet50.xmodel
    ;;
    inception_v1_mt_py )
        run /usr/bin/python3 inception_v1.py 1 \
            $VAI_LIBRARY_MODELS_DIR/inception_v1_tf/inception_v1_tf.xmodel
    ;;
    pose_detection )
        info_gui_quit &
        run ./pose_detection video/pose.webm \
            $VAI_LIBRARY_MODELS_DIR/sp_net/sp_net.xmodel \
            $VAI_LIBRARY_MODELS_DIR/ssd_pedestrian_pruned_0_97/ssd_pedestrian_pruned_0_97.xmodel
    ;;
    video_analysis )
        info_gui_quit &
        run ./video_analysis video/structure.webm \
            $VAI_LIBRARY_MODELS_DIR/ssd_traffic_pruned_0_9/ssd_traffic_pruned_0_9.xmodel
    ;;
    adas_detection )
        info_gui_quit &
        run ./adas_detection \
            video/adas.webm \
            $VAI_LIBRARY_MODELS_DIR/yolov3_adas_pruned_0_9/yolov3_adas_pruned_0_9.xmodel
    ;;
    segmentation )
        info_gui_quit &
        run ./segmentation video/traffic.webm \
            $VAI_LIBRARY_MODELS_DIR/fpn/fpn.xmodel
    ;;
    squeezenet_pytorch )
        info_gui_quit &
        run ./squeezenet_pytorch \
            $VAI_LIBRARY_MODELS_DIR/squeezenet_pt/squeezenet_pt.xmodel
    ;;
esac
