set -e

demo=$(echo "\
VART | resnet50 | DPUCAHX8H
VART | resnet50_pt | DPUCAHX8H
VART | resnet50_ext | DPUCAHX8H
VART | resnet50_mt_py | DPUCAHX8H
VART | inception_v1_mt_py | DPUCAHX8H
VART | pose_detection | DPUCAHX8H
VART | video_analysis | DPUCAHX8H
VART | adas_detection | DPUCAHX8H
VART | segmentation | DPUCAHX8H
VART | squeezenet_pytorch | DPUCAHX8H
Vitis-AI-Library | apps/seg_and_pose_detect | DPUCAHX8H
Vitis-AI-Library | samples/classification:resnet50 | DPUCAHX8H
Vitis-AI-Library | samples/classification:resnet18 | DPUCAHX8H
Vitis-AI-Library | samples/classification:inception_v1 | DPUCAHX8H
Vitis-AI-Library | samples/classification:squeezenet | DPUCAHX8H
Vitis-AI-Library | samples/facelandmark:face_landmark | DPUCAHX8H
Vitis-AI-Library | samples/facedetect:densebox_320_320 | DPUCAHX8H
Vitis-AI-Library | samples/facedetect:densebox_640_360 | DPUCAHX8H
Vitis-AI-Library | samples/posedetect:sp_net | DPUCAHX8H
Vitis-AI-Library | samples/yolov2:yolov2_voc | DPUCAHX8H
Vitis-AI-Library | samples/yolov3:yolov3_voc | DPUCAHX8H
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
    key=${1:-"q"}
    sleep 1
    echo
    message_bold "To quit, type '$key' on a window"
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
source /opt/vitis_ai/select-dpu-vck5000.sh $dpu
#source select-dpu-vck5000.sh $dpu

function run() {
    echo Command : $*
    $*
}

# Workaround for "Too many open files"
ulimit -n 32768

if [[ $cat == "VART" ]] ; then
    # VART
    
    message "Move to demo directory"
    echo Directory : /opt/vitis_ai/workspace/examples/VART/$app
    cd /opt/vitis_ai/workspace/examples/VART/$app
    
    if [[ ! -e ./$app ]] && [[ -e ./build.sh ]] ; then
        message "Build demo"
        ./build.sh
    fi
    
    message "Run demo"
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

 elif [[ $cat == "Vitis-AI-Library" ]] ; then

    opt=$(echo "$app" | awk -F ':' '{print $2}')
    app=$(echo "$app" | awk -F ':' '{print $1}')

    message "Move to demo directory"
    echo Directory : /opt/vitis_ai/workspace/examples/$cat/$app
    cd /opt/vitis_ai/workspace/examples/$cat/$app
    
    case $app in
        apps/seg_and_pose_detect )
            message "Build demo"
	    bash ./build.sh
            message "Run demo"
            info_gui_quit ESC &
            run ./seg_and_pose_detect_x seg_960_540.avi pose_960_540.avi -t 3 -t 3 >& /dev/null
        ;;
        apps/segs_and_roadline_detect )
            message "Build demo"
	    bash ./build.sh
            message "Run demo"
            info_gui_quit ESC &
            run ./segs_and_lanedetect_detect_x seg_512_288.avi seg_512_288.avi seg_512_288.avi seg_512_288.avi \
                lane_640_480.avi -t 2 -t 2 -t 2 -t 2 -t 2 >& /dev/null
        ;;
        samples/classification )
            if [[ ! -e ./test_performance_classification ]] ; then
                message "Build demo"
	        bash ./build.sh
            fi
            message "Run demo"
	    run ./test_performance_classification $opt ./test_performance_classification.list -s 10 -t 4
        ;;
        samples/facedetect )
            if [[ ! -e ./test_performance_facedetect ]] ; then
                message "Build demo"
	        bash ./build.sh
            fi
            message "Run demo"
	    run ./test_performance_facedetect $opt ./test_performance_facedetect.list -s 10 -t 8
        ;;
        samples/facelandmark )
            if [[ ! -e ./test_performance_facelandmark ]] ; then
                message "Build demo"
	        bash ./build.sh
            fi
            message "Run demo"
	    run ./test_performance_facelandmark $opt ./test_performance_facelandmark.list -s 10 -t 4
        ;;
        samples/posedetect )
            if [[ ! -e ./test_performance_posedetect ]] ; then
                message "Build demo"
	        bash ./build.sh
            fi
            message "Run demo"
	    run ./test_performance_posedetect $opt ./test_performance_posedetect.list -s 10 -t 8
        ;;
        samples/yolov2 )
            if [[ ! -e ./test_performance_yolov2 ]] ; then
                message "Build demo"
	        bash ./build.sh
            fi
            message "Run demo"
	    run ./test_performance_yolov2 $opt ./test_performance_yolov2.list -s 10 -t 4
        ;;
        samples/yolov3 )
            if [[ ! -e ./test_performance_yolov3 ]] ; then
                message "Build demo"
	        bash ./build.sh
            fi
            message "Run demo"
	    run ./test_performance_yolov3 $opt ./test_performance_yolov3.list -s 10 -t 4
        ;;
        samples/yolov4 )
            if [[ ! -e ./test_performance_yolov4 ]] ; then
                message "Build demo"
	        bash ./build.sh
            fi
            message "Run demo"
	    run ./test_performance_yolov4 $opt ./test_performance_yolov4.list -s 10 -t 4
        ;;
    esac

 fi
