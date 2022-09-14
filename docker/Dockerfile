# syntax=docker/dockerfile:1

ARG ACRI=${ACRI:-no}
ARG ENABLE_VAI=${ENABLE_VAI:-no}
ARG CARD=${CARD:-no}

## ubuntu:18.04
## base
##     vai_base_20
##     vai_base_25
##     vai_base_no
## vai_base
##     dev_base
##         dev_{CARD}
##         dev_no
## vai
##     vai_20
##         vai_20_vck5000
##     vai_25
##         vai_25_u50
##         vai_25_vck5000
##     vai_no_no
## dev
##     user_acri_yes
##     user_acri_no
## user

#RUN --mount=type=cache,target=/root/downloads \
#    if [[ ! -e /root/downloads/ ]] ; then \
#        && wget "" \
#               -O /root/downloads/ ; \
#    fi \
#    && cd /tmp \

##===========================================================================
## ubuntu_base
##===========================================================================

FROM ubuntu:18.04 as base

SHELL ["/bin/bash", "-c"]

ENV DEBIAN_FRONTEND=noninteractive

# Timezone
ENV TZ=Asia/Tokyo
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Unminimize
RUN --mount=type=cache,target=/var/lib/apt/lists \
    --mount=type=cache,target=/var/cache/apt/archives \
    apt-get update -y && yes | unminimize

# Install python
RUN --mount=type=cache,target=/var/lib/apt/lists \
    --mount=type=cache,target=/var/cache/apt/archives \
    apt-get update -y && apt-get install -y \
      python3.8 \
      python3.8-dev \
      python3.8-minimal \
      python3.8-venv \
      python3-opencv \
      python3-pip \
      python3-setuptools \
      python3-testresources

# Update pip
RUN --mount=type=cache,target=/root/.cache \
    python3 -m pip install -U pip

# Install desktop
RUN --mount=type=cache,target=/var/lib/apt/lists \
    --mount=type=cache,target=/var/cache/apt/archives \
    apt-get update -y && apt-get install -y \
      autoconf \
      automake \
      build-essential \
      bzip2 \
      ca-certificates \
      cmake \
      curl \
      dbus-x11 \
      dstat \
      emacs \
      ffmpeg \
      firefox \
      g++ \
      gcc-multilib g++-multilib \
      git \
      gnome-icon-theme \
      gnupg2 \
      gnuplot \
      graphviz \
      gtkterm \
      gtkwave \
      htop \
      ibus-mozc \
      iotop \
      iproute2 \
      iputils-ping \
      iverilog \
      jq \
      language-pack-ja \
      less \
      libavcodec-dev \
      libavdevice-dev \
      libavformat-dev \
      libboost-dev \
      libc6-dev-i386 \
      libcanberra-gtk* \
      libfdt1 \
      libgflags-dev \
      libgl1-mesa-dri \
      libgnome2-bin \
      libgoogle-glog-dev \
      libgraphviz-dev \
      libgtk2.0-dev \
      libjson-c-dev \
      libncursesw5 \
      libtinfo5 \
      libtool\
      libunwind-dev \
      lsb-core \
      lv \
      make \
      mesa-utils \
      meson \
      neovim \
      net-tools \
      ninja-build \
      nis \
      opencl-headers \
      openssh-server \
      pass \
      peco \
      pigz \
      ruby \
      ruby-dev \
      socat \
      software-properties-common \
      supervisor \
      sysstat \
      tig \
      tigervnc-common \
      tigervnc-standalone-server \
      tigervnc-xorg-extension \
      tmux \
      tree \
      ttf-ubuntu-font-family \
      ubuntu-desktop \
      unity \
      unzip \
      valgrind \
      verilator \
      vim \
      vlc \
      wget \
      x11-utils \
      xorgxrdp \
      xrdp \
      xsel \
      xserver-xorg-core \
      xvfb \
      xz-utils \
      zenity \
      zsh \
      zstd

# locale
RUN update-locale LANG=ja_JP.UTF-8
RUN locale-gen en_US.UTF-8

RUN --mount=type=cache,target=/root/.cache \
    pip3 install \
      Flask \
      jupyter \
      jupyterlab \
      matplotlib \
      numpy \
      pillow \
      pipenv \
      pyserial \
      scipy \
      setuptools \
      wheel

##===========================================================================
## vai_base_2x
##===========================================================================

FROM base as vai_base_2x

SHELL ["/bin/bash", "-c"]

ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /tmp

RUN --mount=type=cache,target=/var/lib/apt/lists \
    --mount=type=cache,target=/var/cache/apt/archives \
    apt-get update -y && \
    apt-get install -y --no-install-recommends \
        apt-transport-https \
        autoconf \
        automake \
        bc \
        build-essential \
        bzip2 \
        ca-certificates \
        curl \
        g++ \
        gdb \
        git \
        gnupg \
        locales \
        libboost-all-dev \
        libgflags-dev \
        libgoogle-glog-dev \
        libgtest-dev \
        libjson-c-dev \
        libjsoncpp-dev \
        libssl-dev \
        libtool \
        libunwind-dev \
        make \
        openssh-client \
        openssl \
        python3 \
        python3-dev \
        python3-minimal \
        python3-numpy \
        python3-opencv \
        python3-pip \
        python3-setuptools \
        python3-venv \
        software-properties-common \
        sudo \
        tree \
        unzip \
        vim \
        wget \
        yasm \
        zstd \
        libavcodec-dev \
        libavformat-dev \
        libeigen3-dev \
        libgstreamer-plugins-base1.0-dev \
        libgstreamer1.0-dev \
        libgtest-dev \
        libgtk-3-dev \
        libgtk2.0-dev \
        libhdf5-dev \
        libjpeg-dev \
        libopenexr-dev \
        libpng-dev \
        libswscale-dev \
        libtiff-dev \
        libwebp-dev \
        opencl-clhpp-headers \
        opencl-headers \
        pocl-opencl-icd \
        rpm \
    && add-apt-repository -y ppa:ubuntu-toolchain-r/test \
    && apt-get install -y \
        gcc-8 \
        g++-8 \
        gcc-9 \
        g++-9 \
    && wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | gpg --dearmor - | tee /usr/share/keyrings/kitware-archive-keyring.gpg >/dev/null \
    && echo 'deb [signed-by=/usr/share/keyrings/kitware-archive-keyring.gpg] https://apt.kitware.com/ubuntu/ bionic main' | sudo tee /etc/apt/sources.list.d/kitware.list >/dev/null \
    && apt-get update -y \
    && apt-get install -y \
        cmake=3.16.0-0kitware1 \
        cmake-data=3.16.0-0kitware1 \
        kitware-archive-keyring \
    && apt-get install -y ffmpeg \
    && cd /usr/src/gtest \
    && mkdir -p build \
    && cd build \
    && cmake .. \
    && make \
    && make install

# glog 0.4.0
RUN --mount=type=cache,target=/root/downloads \
    if [[ ! -e /root/downloads/glog.0.4.0.tar.gz ]] ; then \
        wget --progress=dot:mega -O /root/downloads/glog.0.4.0.tar.gz https://codeload.github.com/google/glog/tar.gz/v0.4.0 ; \
    fi \
    && cd /tmp \
    && tar -xvf /root/downloads/glog.0.4.0.tar.gz \
    && cd glog-0.4.0 \
    && ./autogen.sh \
    && mkdir build \
    && cd build \
    && cmake -DBUILD_SHARED_LIBS=ON .. \
    && make -j \
    && make install \
    && rm -fr /tmp/*

# protobuf 3.4.0
RUN --mount=type=cache,target=/root/downloads \
    if [[ ! -e /root/downloads/protobuf.v3.4.0.zip ]] ; then \
        wget --progress=dot:mega -O /root/downloads/protobuf.v3.4.0.zip https://codeload.github.com/google/protobuf/zip/v3.4.0 ; \
    fi \
    && cd /tmp \
    && unzip /root/downloads/protobuf.v3.4.0.zip \
    && cd protobuf-3.4.0 \
    && ./autogen.sh \
    && ./configure \
    && make -j \
    && make install \
    && ldconfig \
    && rm -fr /tmp/*

# opencv 3.4.1
RUN --mount=type=cache,target=/var/lib/apt/lists \
    --mount=type=cache,target=/var/cache/apt/archives \
    add-apt-repository ppa:timsc/opencv-3.4 \
    && apt-get update \
    && apt install -y \
        libcv-dev=3.4.1-bionic1.1 \
        libcv3.4=3.4.1-bionic1.1 \
        libopencv-calib3d-dev=3.4.1-bionic1.1  \
        libopencv-calib3d3.4-dbg=3.4.1-bionic1.1 \
        libopencv-calib3d3.4=3.4.1-bionic1.1 \
        libopencv-core-dev=3.4.1-bionic1.1 \
        libopencv-core3.4=3.4.1-bionic1.1 \
        libopencv-dev=3.4.1-bionic1.1 \
        libopencv-dnn-dev=3.4.1-bionic1.1 \
        libopencv-dnn3.4-dbg=3.4.1-bionic1.1 \
        libopencv-dnn3.4=3.4.1-bionic1.1 \
        libopencv-features2d-dev=3.4.1-bionic1.1 \
        libopencv-features2d3.4-dbg=3.4.1-bionic1.1 \
        libopencv-features2d3.4=3.4.1-bionic1.1 \
        libopencv-flann-dev=3.4.1-bionic1.1 \
        libopencv-flann3.4-dbg=3.4.1-bionic1.1 \
        libopencv-flann3.4=3.4.1-bionic1.1 \
        libopencv-highgui-dev=3.4.1-bionic1.1 \
        libopencv-highgui3.4-dbg=3.4.1-bionic1.1 \
        libopencv-highgui3.4=3.4.1-bionic1.1 \
        libopencv-imgcodecs-dev=3.4.1-bionic1.1 \
        libopencv-imgcodecs3.4-dbg=3.4.1-bionic1.1 \
        libopencv-imgcodecs3.4=3.4.1-bionic1.1 \
        libopencv-imgproc-dev=3.4.1-bionic1.1 \
        libopencv-imgproc3.4-dbg=3.4.1-bionic1.1 \
        libopencv-imgproc3.4=3.4.1-bionic1.1 \
        libopencv-ml-dev=3.4.1-bionic1.1 \
        libopencv-ml3.4-dbg=3.4.1-bionic1.1 \
        libopencv-ml3.4=3.4.1-bionic1.1 \
        libopencv-objdetect-dev=3.4.1-bionic1.1 \
        libopencv-objdetect3.4-dbg=3.4.1-bionic1.1 \
        libopencv-objdetect3.4=3.4.1-bionic1.1 \
        libopencv-photo-dev=3.4.1-bionic1.1 \
        libopencv-photo3.4-dbg=3.4.1-bionic1.1 \
        libopencv-photo3.4=3.4.1-bionic1.1 \
        libopencv-shape-dev=3.4.1-bionic1.1 \
        libopencv-shape3.4-dbg=3.4.1-bionic1.1 \
        libopencv-shape3.4=3.4.1-bionic1.1 \
        libopencv-stitching-dev=3.4.1-bionic1.1 \
        libopencv-stitching3.4-dbg=3.4.1-bionic1.1 \
        libopencv-stitching3.4=3.4.1-bionic1.1 \
        libopencv-superres-dev=3.4.1-bionic1.1 \
        libopencv-superres3.4-dbg=3.4.1-bionic1.1 \
        libopencv-superres3.4=3.4.1-bionic1.1 \
        libopencv-ts-dev=3.4.1-bionic1.1 \
        libopencv-video-dev=3.4.1-bionic1.1 \
        libopencv-video3.4-dbg=3.4.1-bionic1.1 \
        libopencv-video3.4=3.4.1-bionic1.1 \
        libopencv-videoio-dev=3.4.1-bionic1.1 \
        libopencv-videoio3.4-dbg=3.4.1-bionic1.1 \
        libopencv-videoio3.4=3.4.1-bionic1.1 \
        libopencv-videostab-dev=3.4.1-bionic1.1 \
        libopencv-videostab3.4-dbg=3.4.1-bionic1.1 \
        libopencv-videostab3.4=3.4.1-bionic1.1 \
        libopencv-viz-dev=3.4.1-bionic1.1 \
        libopencv-viz3.4-dbg=3.4.1-bionic1.1 \
        libopencv-viz3.4=3.4.1-bionic1.1 \
        libopencv3.4-java=3.4.1-bionic1.1 \
        opencv-data=3.4.1-bionic1.1 \
        opencv-doc=3.4.1-bionic1.1 \
        python-opencv=3.4.1-bionic1.1 \
        python3-opencv=3.4.1-bionic1.1

# gflags 2.2.2
RUN --mount=type=cache,target=/root/downloads \
    if [[ ! -e /root/downloads/gflags.v2.2.2.tar.gz ]] ; then \
        wget --progress=dot:mega -O /root/downloads/gflags.v2.2.2.tar.gz https://github.com/gflags/gflags/archive/v2.2.2.tar.gz ; \
    fi \
    && cd /tmp \
    && tar xvf /root/downloads/gflags.v2.2.2.tar.gz \
    && cd gflags-2.2.2 \
    && mkdir build \
    && cd build \
    && cmake -DBUILD_SHARED_LIBS=ON .. \
    && make -j \
    && make install \
    && rm -fr /tmp/*

# pybind 2.5.0
RUN --mount=type=cache,target=/root/downloads \
    if [[ ! -e /root/downloads/pybind11 ]] ; then \
        git clone https://github.com/pybind/pybind11.git /root/downloads/pybind11 ; \
    fi \
    && cd /tmp \
    && cp -a /root/downloads/pybind11 . \
    && cd pybind11 \
    && git checkout v2.5.0 \
    && mkdir build \
    && cd build \
    && cmake -DPYBIND11_TEST=OFF .. \
    && make \
    && make install \
    && rm -fr /tmp/*

RUN --mount=type=cache,target=/root/downloads \
    if [[ ! -e /root/downloads/json-c-0.15-20200726.tar.gz ]] ; then \
        wget --progress=dot:mega -O /root/downloads/json-c-0.15-20200726.tar.gz https://github.com/json-c/json-c/archive/json-c-0.15-20200726.tar.gz ;\
    fi \
    && cd /tmp \
    && tar xvf /root/downloads/json-c-0.15-20200726.tar.gz \
    && cd json-c-json-c-0.15-20200726 \
    && mkdir build \
    && cd build \
    && cmake -DBUILD_SHARED_LIBS=ON .. \
    && make -j \
    && make install \
    && rm -fr /tmp/*

# Env for Vitis AI
ENV VAI_ROOT=/opt/vitis_ai

RUN mkdir -p ${VAI_ROOT} \
    && mkdir /etc/conda \
    && touch /etc/conda/condarc \
    && mkdir -p ${VAI_ROOT}/scripts

##===========================================================================
## vai_base_20
##===========================================================================

FROM vai_base_2x AS vai_base_20

ENV VAI_CONDA_CHANNEL="file:///tmp/conda-channel"

# Set up Anaconda
RUN cd /tmp \
    && wget --progress=dot:mega https://github.com/conda-forge/miniforge/releases/download/4.10.3-5/Mambaforge-4.10.3-5-Linux-x86_64.sh -O miniconda.sh \
    && /bin/bash ./miniconda.sh -b -p $VAI_ROOT/conda \
    && cat /dev/null > /etc/conda/condarc \
    && echo "channels:" >> /etc/conda/condarc \
    && echo "  - ${VAI_CONDA_CHANNEL}" >> /etc/conda/condarc \
    && echo "remote_connect_timeout_secs: 60.0">> /etc/conda/condarc \
    && rm -fr /tmp/miniconda.sh \
    && sudo ln -s $VAI_ROOT/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh \
    && . /etc/profile.d/conda.sh \
    &&  conda clean -y --force-pkgs-dirs

WORKDIR /tmp
ADD files/vitis_ai/20/cpu_conda/*.yml /tmp/
ADD files/vitis_ai/20/pip_requirements.txt /tmp/

# Rebuild this layer every time
#ARG CACHEBUST=1

RUN cd /tmp \
    && wget -O conda-channel.tar.gz --progress=dot:mega https://www.xilinx.com/bin/public/openDownload?filename=conda-channel_2.0.0.1103-02.tar.gz \
    && tar -xzvf conda-channel.tar.gz \
    && . $VAI_ROOT/conda/etc/profile.d/conda.sh \
    && mamba install -c conda-forge conda-build \
    && python3 -m pip install --upgrade pip wheel setuptools \
    && mamba env create -f /tmp/vitis-ai-pytorch.yml \
        && conda activate vitis-ai-pytorch \
        && pip install -r /tmp/pip_requirements.txt \
    && mamba env create -f /tmp/vitis-ai-caffe.yml \
        && conda activate vitis-ai-caffe \
        &&  mamba  install -y --no-update-deps  pydot pyyaml jupyter ipywidgets \
        dill progressbar2 pytest scikit-learn pandas matplotlib \
        pillow  -c conda-forge -c defaults \
        && pip install -r /tmp/pip_requirements.txt \
    && mamba env create -f /tmp/vitis-ai-tensorflow.yml \
        && conda activate vitis-ai-tensorflow \
        && pip install -r /tmp/pip_requirements.txt \
    && mamba env create -f /tmp/vitis-ai-tensorflow2.yml \
        && conda activate vitis-ai-tensorflow2 \
        &&  mamba  install --no-update-deps -y vai_q_tensorflow2  pydot pyyaml jupyter ipywidgets \
        dill progressbar2 pytest scikit-learn pandas matplotlib \
        pillow  -c conda-forge -c defaults \
        && pip install -r /tmp/pip_requirements.txt \
        && pip install  --ignore-installed tensorflow==2.6 keras==2.6 \
        && pip uninstall -y h5py \
         && pip uninstall -y h5py \
        && mamba install  -y --override-channels --force-reinstall h5py=2.10.0  -c conda-forge -c anaconda  \
    && conda clean -y --force-pkgs-dirs \
    && mkdir -p $VAI_ROOT/compiler \
        && conda activate vitis-ai-caffe \
        && sudo cp -r $CONDA_PREFIX/lib/python3.6/site-packages/vaic/arch $VAI_ROOT/compiler/arch \
    && cat /dev/null > /etc/conda/condarc

# VAI-1372: Workaround to fix GCC 9 in vitis-ai-tensorflow
RUN rm -f /opt/vitis_ai/conda/envs/vitis-ai-tensorflow/etc/conda/activate.d/activate-binutils_linux-64.sh \
    && rm -f /opt/vitis_ai/conda/envs/vitis-ai-tensorflow/etc/conda/activate.d/activate-gcc_linux-64.sh \
    && rm -f /opt/vitis_ai/conda/envs/vitis-ai-tensorflow/etc/conda/activate.d/activate-gxx_linux-64.sh \
    && rm -f /opt/vitis_ai/conda/envs/vitis-ai-tensorflow/etc/conda/deactivate.d/deactivate-binutils_linux-64.sh \
    && rm -f /opt/vitis_ai/conda/envs/vitis-ai-tensorflow/etc/conda/deactivate.d/deactivate-gcc_linux-64.sh \
    && rm -f /opt/vitis_ai/conda/envs/vitis-ai-tensorflow/etc/conda/deactivate.d/deactivate-gxx_linux-64.sh

RUN cd /tmp \
    && wget -O libunilog.deb https://www.xilinx.com/bin/public/openDownload?filename=libunilog_2.0.0-r87_amd64.deb \
    && wget -O libtarget-factory.deb https://www.xilinx.com/bin/public/openDownload?filename=libtarget-factory_2.0.0-r97_amd64.deb \
    && wget -O libxir.deb https://www.xilinx.com/bin/public/openDownload?filename=libxir_2.0.0-r109_amd64.deb \
    && wget -O libvart.deb https://www.xilinx.com/bin/public/openDownload?filename=libvart_2.0.0-r148_amd64.deb \
    && wget -O libvitis_ai_library.deb https://www.xilinx.com/bin/public/openDownload?filename=libvitis_ai_library_2.0.0-r134_amd64.deb \
    && wget -O librt-engine.deb https://www.xilinx.com/bin/public/openDownload?filename=librt-engine_2.0.0-r221_amd64.deb \
    && wget -O aks.deb https://www.xilinx.com/bin/public/openDownload?filename=aks_2.0.0-r92_amd64.deb \
    && apt-get install -y --no-install-recommends /tmp/*.deb \
    && rm -rf /tmp/* \
    && ldconfig

# Set default build toolchain to GCC 9 for better performance
RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-9 90 \
        --slave /usr/bin/g++ g++ /usr/bin/g++-9 \
        --slave /usr/bin/gcov gcov /usr/bin/gcov-9 \
    && update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-8 80 \
        --slave /usr/bin/g++ g++ /usr/bin/g++-8 \
        --slave /usr/bin/gcov gcov /usr/bin/gcov-8 \
    && update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-7 70 \
        --slave /usr/bin/g++ g++ /usr/bin/g++-7 \
        --slave /usr/bin/gcov gcov /usr/bin/gcov-7

# Vitis AI GitHub
RUN cd $VAI_ROOT \
    && git clone https://github.com/Xilinx/Vitis-AI.git workspace \
    && cd workspace \
    && git checkout 2.0

# VART
RUN cd $VAI_ROOT/workspace/demo && \
    wget "https://www.xilinx.com/bin/public/openDownload?filename=vitis_ai_runtime_r2.0.0_image_video.tar.gz" \
        -O vitis_ai_runtime_r2.0.0_image_video.tar.gz && \
    tar -xzvf vitis_ai_runtime_r2.0.0_image_video.tar.gz -C VART && \
    rm vitis_ai_runtime_r2.0.0_image_video.tar.gz

# Vitis AI Library
RUN wget https://www.xilinx.com/bin/public/openDownload?filename=vitis_ai_library_r2.0.0_images.tar.gz -O vitis_ai_library_r2.0.0_images.tar.gz && \
    wget https://www.xilinx.com/bin/public/openDownload?filename=vitis_ai_library_r2.0.0_video.tar.gz -O vitis_ai_library_r2.0.0_video.tar.gz && \
    cd $VAI_ROOT/workspace && \
    tar -xzvf /tmp/vitis_ai_library_r2.0.0_images.tar.gz -C demo/Vitis-AI-Library/ && \
    tar -xzvf /tmp/vitis_ai_library_r2.0.0_video.tar.gz -C demo/Vitis-AI-Library/ && \
    rm -rf /tmp/*

##===========================================================================
## vai_base_25
##===========================================================================

FROM vai_base_2x AS vai_base_25

WORKDIR /tmp

# Set up Anaconda
RUN --mount=type=cache,target=/root/downloads \
    if [[ ! -e /root/downloads/miniconda.sh ]] ; then \
        wget --progress=dot:mega https://github.com/conda-forge/miniforge/releases/download/4.10.3-5/Mambaforge-4.10.3-5-Linux-x86_64.sh -O /root/downloads/miniconda.sh ; \
    fi \
    && cd /tmp \
    && /bin/bash /root/downloads/miniconda.sh -b -p $VAI_ROOT/conda \
    && cat /dev/null > /etc/conda/condarc \
    && echo "remote_connect_timeout_secs: 60.0">> /etc/conda/condarc \
    && sudo ln -s $VAI_ROOT/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh \
    && . /etc/profile.d/conda.sh \
    && conda clean -y --force-pkgs-dirs

ADD files/vitis_ai/25/cpu_conda/*.yml /tmp/
ADD files/vitis_ai/25/pip_requirements.txt /tmp/

# Create conda envs
RUN --mount=type=cache,target=/root/downloads \
    file=/root/downloads/conda-channel_2.5.0.1260-01.tar.gz && \
    if [[ ! -e $file ]] ; then \
        wget -O $file --progress=dot:mega "https://www.xilinx.com/bin/public/openDownload?filename=conda-channel_2.5.0.1260-01.tar.gz" ; \
    fi \
    && cd /tmp \
    && tar xf $file

# wget -O conda-channel-wego.tar.gz --progress=dot:mega "https://www.xilinx.com/bin/public/openDownload?filename=conda-channel-wego_2.5.0.1260-01.tar.gz"

RUN --mount=type=cache,target=/root/.cache \
    --mount=type=cache,target=$VAI_ROOT/conda/pkgs \
    . $VAI_ROOT/conda/etc/profile.d/conda.sh \
    && mkdir -p $VAI_ROOT/conda/pkgs \
    && mamba install -c conda-forge conda-build \
    && python3 -m pip install --upgrade pip wheel setuptools

#RUN . $VAI_ROOT/conda/etc/profile.d/conda.sh \
#    && conda config --env --append channels file:///tmp/conda-channel-wego/wegotf1 \
#    && mamba env create -f /tmp/vitis-ai-wego-tf1.yml \
#    && conda clean -y --force-pkgs-dirs \
#    && rm -fr ~/.cache \
#    && conda config --env --remove-key channels \
#    && conda config --env --append channels file:///tmp/conda-channel-wego/wegotf2 \
#    && mamba env create -f /tmp/vitis-ai-wego-tf2.yml \
#    && conda config --env --remove-key channels \
#    && conda config --env --append channels file:///tmp/conda-channel

#RUN . $VAI_ROOT/conda/etc/profile.d/conda.sh \
#    && conda activate vitis-ai-wego-tf2 \
#    && pip install dm-tree libclang tensorflow-estimator==2.8.0 tensorflow-io-gcs-filesystem

#RUN . $VAI_ROOT/conda/etc/profile.d/conda.sh \
#    && conda activate vitis-ai-wego-tf2 \
#    && mamba install --no-update-deps -y vai_q_tensorflow2  \
#    && pip install --ignore-installed keras==2.8 protobuf==3.11 \
#    && conda clean -y --force-pkgs-dirs \
#    && conda config --env --remove-key channels \
#    && conda config --env --append channels file:///tmp/conda-channel \
#    && mamba env create -f /tmp/vitis-ai-wego-torch.yml \
#    && mamba env create -f /tmp/vitis-ai-pytorch.yml \
#        && conda activate vitis-ai-pytorch \
#        && conda config --show channels \
#        && pip install graphviz==0.19.1 \
#    && mamba env create -f /tmp/vitis-ai-tensorflow.yml \
#        && conda activate vitis-ai-tensorflow \
#        && pip install -r /tmp/pip_requirements.txt \
#    && mamba env create -f /tmp/vitis-ai-tensorflow2.yml \
#        && conda activate vitis-ai-tensorflow2 \
#        && mamba install --no-update-deps -y vai_q_tensorflow2 pydot pyyaml jupyter ipywidgets \
#            dill progressbar2 pytest scikit-learn pandas matplotlib \
#            pillow -c conda-forge -c defaults \
#        && pip install -r /tmp/pip_requirements.txt \
#        && pip install --ignore-installed tensorflow==2.8 keras==2.8 protobuf==3.11.* \
#        && pip uninstall -y h5py \
#        && pip uninstall -y h5py \
#        && mamba install -y --override-channels --force-reinstall h5py=2.10.0 -c conda-forge -c anaconda \
#    && conda clean -y --force-pkgs-dirs \
#    && rm -fr ~/.cache \
#    && mkdir -p $VAI_ROOT/conda/pkgs \
#    && sudo chmod 777 $VAI_ROOT/conda/pkgs \
#    && sudo rm /opt/vitis_ai/conda/.condarc \
#    && mkdir -p $VAI_ROOT/compiler \
#        && conda activate vitis-ai-pytorch \
#        && sudo cp -r $CONDA_PREFIX/lib/python3.7/site-packages/vaic/arch $VAI_ROOT/compiler/arch \
#    && cat /dev/null > /etc/conda/condarc \
#    && rm -rf /tmp/*

RUN --mount=type=cache,target=/root/.cache \
    --mount=type=cache,target=$VAI_ROOT/conda/pkgs \
    . $VAI_ROOT/conda/etc/profile.d/conda.sh \
    && conda config --env --append channels file:///tmp/conda-channel \
    && mamba env create -f /tmp/vitis-ai-pytorch.yml \
        && conda activate vitis-ai-pytorch \
        && conda config --show channels \
        && pip install graphviz==0.19.1 \
    && mamba env create -f /tmp/vitis-ai-tensorflow.yml \
        && conda activate vitis-ai-tensorflow \
        && pip install -r /tmp/pip_requirements.txt \
    && mamba env create -f /tmp/vitis-ai-tensorflow2.yml \
        && conda activate vitis-ai-tensorflow2 \
        && mamba install --no-update-deps -y vai_q_tensorflow2 pydot pyyaml jupyter ipywidgets \
            dill progressbar2 pytest scikit-learn pandas matplotlib \
            pillow -c conda-forge -c defaults \
        && pip install -r /tmp/pip_requirements.txt \
        && pip install --ignore-installed tensorflow==2.8 keras==2.8 protobuf==3.11.* \
        && pip uninstall -y h5py \
        && mamba install -y --override-channels --force-reinstall h5py=2.10.0 -c conda-forge -c anaconda \
    && conda clean -y --force-pkgs-dirs \
    && mkdir -p $VAI_ROOT/conda/pkgs \
    && sudo chmod 777 $VAI_ROOT/conda/pkgs \
    && sudo rm /opt/vitis_ai/conda/.condarc \
    && mkdir -p $VAI_ROOT/compiler \
        && conda activate vitis-ai-pytorch \
        && sudo cp -r $CONDA_PREFIX/lib/python3.7/site-packages/vaic/arch $VAI_ROOT/compiler/arch \
    && cat /dev/null > /etc/conda/condarc \
    && rm -rf /tmp/*

# VAI-1372: Workaround to fix GCC 9 in vitis-ai-tensorflow
RUN rm -f /opt/vitis_ai/conda/envs/vitis-ai-tensorflow/etc/conda/activate.d/activate-binutils_linux-64.sh \
    && rm -f /opt/vitis_ai/conda/envs/vitis-ai-tensorflow/etc/conda/activate.d/activate-gcc_linux-64.sh \
    && rm -f /opt/vitis_ai/conda/envs/vitis-ai-tensorflow/etc/conda/activate.d/activate-gxx_linux-64.sh \
    && rm -f /opt/vitis_ai/conda/envs/vitis-ai-tensorflow/etc/conda/deactivate.d/deactivate-binutils_linux-64.sh \
    && rm -f /opt/vitis_ai/conda/envs/vitis-ai-tensorflow/etc/conda/deactivate.d/deactivate-gcc_linux-64.sh \
    && rm -f /opt/vitis_ai/conda/envs/vitis-ai-tensorflow/etc/conda/deactivate.d/deactivate-gxx_linux-64.sh

RUN --mount=type=cache,target=/root/downloads \
    if [[ ! -e /root/downloads/vai25-deb ]] ; then \
        mkdir -p /root/downloads/vai25-deb ; \
        cd /root/downloads/vai25-deb ; \
        wget -O libunilog.deb https://www.xilinx.com/bin/public/openDownload?filename=libunilog_2.5.0-r90_amd64.deb ; \
        wget -O libtarget-factory.deb https://www.xilinx.com/bin/public/openDownload?filename=libtarget-factory_2.5.0-r100_amd64.deb ; \
        wget -O libxir.deb https://www.xilinx.com/bin/public/openDownload?filename=libxir_2.5.0-r112_amd64.deb ; \
        wget -O libvart.deb https://www.xilinx.com/bin/public/openDownload?filename=libvart_2.5.0-r158_amd64.deb ; \
        wget -O libvitis_ai_library.deb https://www.xilinx.com/bin/public/openDownload?filename=libvitis_ai_library_2.5.0-r146_amd64.deb ; \
        wget -O aks.deb https://www.xilinx.com/bin/public/openDownload?filename=aks_2.0.0-r102_amd64.deb ; \
        wget -O librt-engine.deb https://www.xilinx.com/bin/public/openDownload?filename=librt-engine_2.5.0-r238_amd64.deb ; \
    fi \
    && apt-get install -y --no-install-recommends /root/downloads/vai25-deb/*.deb \
    && ldconfig

# Set default build toolchain to GCC 9 for better performance
RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-9 90 \
        --slave /usr/bin/g++ g++ /usr/bin/g++-9 \
        --slave /usr/bin/gcov gcov /usr/bin/gcov-9 \
    && update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-8 80 \
        --slave /usr/bin/g++ g++ /usr/bin/g++-8 \
        --slave /usr/bin/gcov gcov /usr/bin/gcov-8 \
    && update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-7 70 \
        --slave /usr/bin/g++ g++ /usr/bin/g++-7 \
        --slave /usr/bin/gcov gcov /usr/bin/gcov-7

# Vitis AI GitHub
RUN --mount=type=cache,target=/root/downloads \
    if [[ ! -e /root/downloads/Vitis-AI ]] ; then \
        git clone https://github.com/Xilinx/Vitis-AI.git /root/downloads/Vitis-AI ; \
    fi \
    && cd $VAI_ROOT \
    && cp -a /root/downloads/Vitis-AI workspace \
    && cd workspace \
    && git checkout 491faef

# VART
RUN --mount=type=cache,target=/root/downloads \
    if [[ ! -e /root/downloads/vitis_ai_runtime_r2.5.0_image_video.tar.gz ]] ; then \
        wget "https://www.xilinx.com/bin/public/openDownload?filename=vitis_ai_runtime_r2.5.0_image_video.tar.gz" \
            -O /root/downloads/vitis_ai_runtime_r2.5.0_image_video.tar.gz ; \
    fi \
    && cd $VAI_ROOT/workspace/examples \
    && tar xf /root/downloads/vitis_ai_runtime_r2.5.0_image_video.tar.gz -C VART

# Vitis AI Library
RUN --mount=type=cache,target=/root/downloads \
    if [[ ! -e /root/downloads/vitis_ai_library_r2.5.0_images.tar.gz ]] ; then \
        wget "https://www.xilinx.com/bin/public/openDownload?filename=vitis_ai_library_r2.5.0_images.tar.gz" \
            -O /root/downloads/vitis_ai_library_r2.5.0_images.tar.gz ; \
    fi \
    && cd $VAI_ROOT/workspace \
    && tar xf /root/downloads/vitis_ai_library_r2.5.0_images.tar.gz -C examples/Vitis-AI-Library

RUN --mount=type=cache,target=/root/downloads \
    if [[ ! -e /root/downloads/vitis_ai_library_r2.5.0_video.tar.gz ]] ; then \
        wget "https://www.xilinx.com/bin/public/openDownload?filename=vitis_ai_library_r2.5.0_video.tar.gz" \
            -O /root/downloads/vitis_ai_library_r2.5.0_video.tar.gz ; \
    fi \
    && cd $VAI_ROOT/workspace \
    && tar xf /root/downloads/vitis_ai_library_r2.5.0_video.tar.gz -C examples/Vitis-AI-Library

##===========================================================================
## vai_base
##===========================================================================

FROM base AS vai_base_no

FROM vai_base_${ENABLE_VAI} AS vai_base

##===========================================================================
## dev_base
##===========================================================================

FROM vai_base AS dev_base

ARG XRT_PACKAGE_URL
ARG XRT_APU_PACKAGE_URL
ARG PLATFORM_TAR_GZ_URL
ARG PLATFORM_DEB_URL

SHELL ["/bin/bash", "-c"]

ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /tmp

# For xbutil validate
RUN pip install --upgrade pip && \
    pip install pyopencl 

# Install XRT
RUN --mount=type=cache,target=/var/lib/apt/lists \
    --mount=type=cache,target=/var/cache/apt/archives \
    --mount=type=cache,target=/root/downloads \
    if [[ -n "$XRT_PACKAGE_URL" ]] ; then \
        file=/root/downloads/$(echo $XRT_PACKAGE_URL | sed 's/^.*=//') && \
        if [[ ! -e $file ]] ; then \
            wget -O $file "$XRT_PACKAGE_URL" ; \
        fi && \
        apt-get update -y && \
        apt-get install -y $file ; \
    fi

# Install XRT_APU
RUN --mount=type=cache,target=/var/lib/apt/lists \
    --mount=type=cache,target=/var/cache/apt/archives \
    --mount=type=cache,target=/root/downloads \
    if [[ -n "$XRT_APU_PACKAGE_URL" ]] ; then \
        file=/root/downloads/$(echo $XRT_APU_PACKAGE_URL | sed 's/^.*=//') && \
        if [[ ! -e $file ]] ; then \
            wget -O $file "$XRT_APU_PACKAGE_URL" ; \
        fi && \
        apt-get update -y && \
        apt-get install -y $file ; \
    fi

# Install Deployment Platform (tar.gz)
RUN --mount=type=cache,target=/var/lib/apt/lists \
    --mount=type=cache,target=/var/cache/apt/archives \
    --mount=type=cache,target=/root/downloads \
    if [[ -n "$PLATFORM_TAR_GZ_URL" ]] ; then \
        file=/root/downloads/$(echo $PLATFORM_TAR_GZ_URL | sed 's/^.*=//') && \
        if [[ ! -e $file ]] ; then \
            wget -O $file "$PLATFORM_TAR_GZ_URL" ; \
        fi && \
        mkdir platform && cd platform && tar xf $file && \
        apt-get update -y && \
        apt-get install -y ./*.deb && \
        rm -rf /tmp/platform ; \
    fi

# Install Deployment Platform (deb)
RUN --mount=type=cache,target=/var/lib/apt/lists \
    --mount=type=cache,target=/var/cache/apt/archives \
    --mount=type=cache,target=/root/downloads \
    if [[ -n "$PLATFORM_DEB_URL" ]] ; then \
        file=/root/downloads/$(echo $PLATFORM_DEB_URL | sed 's/^.*=//') && \
        if [[ ! -e $file ]] ; then \
            wget -O $file "$PLATFORM_DEB_URL" ; \
        fi && \
        apt-get update -y && \
        apt-get install -y $file ; \
    fi

##===========================================================================
## dev_base_{card}
##===========================================================================

FROM dev_base AS dev_u200
FROM dev_base AS dev_u250
FROM dev_base AS dev_u280es1
FROM dev_base AS dev_u50
FROM dev_base AS dev_vck5000
FROM dev_base AS dev_no

##===========================================================================
## vai
##===========================================================================

FROM dev_${CARD} AS vai

##===========================================================================
## vai_20
##===========================================================================

FROM vai AS vai_20

WORKDIR /tmp

# Install XRM
RUN wget -O xrm.deb "https://www.xilinx.com/bin/public/openDownload?filename=xrm_202120.1.3.29_18.04-x86_64.deb" && \
    apt-get update -y && \
    apt-get install -y ./xrm.deb && \
    rm -rf ./xrm.deb

EXPOSE 9763
COPY files/supervisor/xrm.conf /etc/supervisor/conf.d

# Vitis AI setup file
COPY files/vitis_ai/20/setup.sh $VAI_ROOT

##===========================================================================
## vai_25
##===========================================================================

FROM vai AS vai_25

WORKDIR /tmp

# Install XRM
RUN --mount=type=cache,target=/var/lib/apt/lists \
    --mount=type=cache,target=/var/cache/apt/archives \
    --mount=type=cache,target=/root/downloads \
    file=/root/downloads/xrm_202120.1.3.29_18.04-x86_64.deb && \
    if [[ ! -e $file ]] ; then \
        wget -O $file "https://www.xilinx.com/bin/public/openDownload?filename=xrm_202120.1.3.29_18.04-x86_64.deb" ; \
    fi \
    && apt-get update -y \
    && apt-get install -y $file

EXPOSE 9763
COPY files/supervisor/xrm.conf /etc/supervisor/conf.d

# Vitis AI setup file
COPY files/vitis_ai/25/setup.sh $VAI_ROOT

##===========================================================================
## vai_20_vck5000
##===========================================================================

FROM vai_20 AS vai_20_vck5000

SHELL ["/bin/bash", "-c"]

WORKDIR /tmp

# xclbin
RUN wget "https://www.xilinx.com/bin/public/openDownload?filename=DPUCVDX8H_xclbins_2_0_0.tar.gz" -O xclbins.tar.gz && \
    tar xf xclbins.tar.gz --directory / && \
    rm xclbins.tar.gz

# Pretrained models
ENV VAI_MODELS=/usr/share/vitis_ai_library/models
ADD files/vitis_ai/20/download_models.sh /tmp/
ADD files/vitis_ai/20/models_vck50008pe-DPUCVDX8H.txt /tmp/
ADD files/vitis_ai/20/models_vck50006pe-DPUCVDX8H-DWC.txt /tmp/
RUN /tmp/download_models.sh vck50008pe-DPUCVDX8H /tmp/models_vck50008pe-DPUCVDX8H.txt
RUN /tmp/download_models.sh vck50006pe-DPUCVDX8H-DWC /tmp/models_vck50006pe-DPUCVDX8H-DWC.txt

COPY files/vitis_ai/20/select-dpu-vck5000.sh $VAI_ROOT
COPY files/vitis_ai/20/demo-vai-vck5000.sh $VAI_ROOT
RUN echo 'alias select-dpu="source $VAI_ROOT/select-dpu-vck5000.sh"' >> $VAI_ROOT/setup.sh
RUN echo 'alias demo-vai="bash $VAI_ROOT/demo-vai-vck5000.sh"' >> $VAI_ROOT/setup.sh

##===========================================================================
## vai_25_u50
##===========================================================================

FROM vai_25 AS vai_25_u50

SHELL ["/bin/bash", "-c"]

ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /tmp

# xclbin
RUN mkdir -p /opt/xilinx/overlaybins/DPUCAHX8H/u50

RUN --mount=type=cache,target=/root/downloads \
    file=/root/downloads/dpu_DPUCAHX8H_2PE_300M_xilinx_u50_gen3x16_xdma_201920_3.xclbin && \
    url="https://acri-room.web.app/dpu_DPUCAHX8H_2PE_300M_xilinx_u50_gen3x16_xdma_201920_3.xclbin" && \
    if [[ ! -e $file ]] ; then \
        wget "$url" -O "$file"; \
    fi \
    && cp $file /opt/xilinx/overlaybins/DPUCAHX8H/u50

COPY files/vitis_ai/25/u50/setup.sh $VAI_ROOT/workspace/setup/alveo/setup.sh

# Pretrained models
ENV VAI_MODELS=/usr/share/vitis_ai_library/models
ADD files/vitis_ai/25/u50/download_models.sh /tmp/
ADD files/vitis_ai/25/u50/models_*.txt /tmp/

RUN --mount=type=cache,target=/root/downloads \
    /tmp/download_models.sh DPUCAHX8H

COPY files/vitis_ai/25/u50/select-dpu.sh $VAI_ROOT
COPY files/vitis_ai/25/u50/demo-vai.sh $VAI_ROOT
RUN echo 'alias select-dpu="source $VAI_ROOT/select-dpu.sh"' >> $VAI_ROOT/setup.sh
RUN echo 'alias demo-vai="bash $VAI_ROOT/demo-vai.sh"' >> $VAI_ROOT/setup.sh

##===========================================================================
## vai_25_vck5000
##===========================================================================

FROM vai_25 AS vai_25_vck5000

SHELL ["/bin/bash", "-c"]

ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /tmp

# Uninstall rt-engine
RUN apt remove librt-engine
# Install rt-engine
RUN git clone https://github.com/anjn/rt-engine.git /tmp/rt-engine \
    && cd /tmp/rt-engine \
    && ./cmake.sh --clean --build-dir=$PWD/build --type=release --cmake-options="-DXRM_DIR=/opt/xilinx/xrm/share/cmake" --install-prefix=/usr/ \
    && rm -rf /tmp/*

# xclbin
RUN mkdir -p \
        /opt/xilinx/overlaybins/DPUCVDX8H/8PE \
        /opt/xilinx/overlaybins/DPUCVDX8H/6PE_aieDWC \
        /opt/xilinx/overlaybins/DPUCVDX8H/6PE_aieMISC \
        /opt/xilinx/overlaybins/DPUCVDX8H/4PE

RUN --mount=type=cache,target=/root/downloads \
    file=/root/downloads/dpu_DPUCVDX8H_8PE_200M_xilinx_vck5000_gen4x8_xdma_base_2.xclbin && \
    if [[ ! -e $file ]] ; then \
        wget "https://acri-room.web.app/dpu_DPUCVDX8H_8PE_200M_xilinx_vck5000_gen4x8_xdma_base_2.xclbin" \
            -O $file; \
    fi \
    && cp $file /opt/xilinx/overlaybins/DPUCVDX8H/8PE

COPY files/vitis_ai/25/vck5000/setup.sh $VAI_ROOT/workspace/setup/vck5000/setup.sh

# Pretrained models
ENV VAI_MODELS=/usr/share/vitis_ai_library/models
ADD files/vitis_ai/25/vck5000/download_models.sh /tmp/
ADD files/vitis_ai/25/vck5000/models_*.txt /tmp/

RUN --mount=type=cache,target=/root/downloads \
    /tmp/download_models.sh 8pe

COPY files/vitis_ai/25/vck5000/select-dpu-vck5000.sh $VAI_ROOT
COPY files/vitis_ai/25/vck5000/demo-vai-vck5000.sh $VAI_ROOT
RUN echo 'alias select-dpu="source $VAI_ROOT/select-dpu-vck5000.sh"' >> $VAI_ROOT/setup.sh
RUN echo 'alias demo-vai="bash $VAI_ROOT/demo-vai-vck5000.sh"' >> $VAI_ROOT/setup.sh

##===========================================================================
## vai_no_no
##===========================================================================

FROM vai_20 AS vai_20_no
FROM vai_25 AS vai_25_no

FROM vai AS vai_no_u200
FROM vai AS vai_no_u250
FROM vai AS vai_no_u280es1
FROM vai AS vai_no_u50
FROM vai AS vai_no_vck5000
FROM vai AS vai_no_no

##===========================================================================
## vai_no / vai
##===========================================================================

FROM vai_${ENABLE_VAI}_${CARD} AS dev

RUN rm -rf /tmp/*

##===========================================================================
## user_acri_yes
##===========================================================================

# ACRi remote env
FROM dev AS user_acri_yes

# nis
COPY files/yp.conf /etc/yp.conf
COPY files/nsswitch.conf /etc/nsswitch.conf

# supervisor
COPY files/supervisor/nis.conf /etc/supervisor/conf.d

# Tool license
RUN echo "export XILINXD_LICENSE_FILE=2100@172.16.6.205" >> /etc/profile

# sshd
EXPOSE 22

##===========================================================================
## user_acri_no
##===========================================================================

FROM dev AS user_acri_no

ARG USERNAME=user
ARG GROUPNAME=user
ARG PASSWORD=user
ARG UID=1000
ARG GID=1000
ARG SSHD_PORT=${SSHD_PORT:-8022}

RUN groupadd -g $GID $GROUPNAME && \
    useradd -m -s /bin/bash -u $UID -g $GID $USERNAME && \
    echo "$USERNAME:$PASSWORD" | chpasswd

RUN echo "Port $SSHD_PORT" >> /etc/ssh/sshd_config

# sshd
EXPOSE $SSHD_PORT

##===========================================================================
## user
##===========================================================================

FROM user_acri_${ACRI} AS user

SHELL ["/bin/bash", "-c"]

ENV DEBIAN_FRONTEND=noninteractive

# supervisor
COPY files/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY files/supervisor/entry.conf /etc/supervisor/conf.d

# xrdp/vnc
COPY files/startwm.sh /etc/xrdp/startwm.sh
COPY files/xstartup /etc/vnc/xstartup
COPY files/Xvnc-session /etc/X11/Xvnc-session
COPY files/vnc.conf /etc/vnc.conf

EXPOSE 3389 5901

RUN mkdir -p /var/run/sshd /var/run/dbus
RUN rm -rf /var/run/dbus/pid

RUN sed -i '/imklog/s/^/#/' /etc/rsyslog.conf

###############################################################

# Add packages here
#RUN apt-get update -y && apt-get install -y \
#      gnupg2 \
#      pass \
#      libfdt1 \
#      && apt autoclean -y \
#      && apt autoremove -y \
#      && rm -rf /var/lib/apt/lists/*

#RUN pip3 install \
#      jupyterlab

# Set bash as a default shell for AIE tools
RUN echo "dash dash/sh boolean false" | debconf-set-selections \
    && DEBIAN_FRONTEND=noninteractive dpkg-reconfigure dash || true

###############################################################

CMD ["/usr/bin/supervisord"]

## ## # Alveo-PYNQ
## RUN source $VAI_ROOT/conda/etc/profile.d/conda.sh && \
##     conda create -n pynq && \
##     conda activate pynq && \
##     python3 -m pip install --upgrade pip && \
##     pip3 install --use-feature=2020-resolver \
##       pynq \
##       pynq-alveo-examples \
##       pynq-compute-labs
## 
## COPY files/pynq-start.sh /opt/pynq-notebooks/start.sh


