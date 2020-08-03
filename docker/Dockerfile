FROM ubuntu:18.04

SHELL ["/bin/bash", "-c"]

ENV DEBIAN_FRONTEND=noninteractive

# Timezone
ENV TZ=Asia/Tokyo
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Unminimize
RUN apt-get update -y && yes | unminimize

# Install desktop
RUN apt-get update -y && apt-get install -y \
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
      firefox \
      g++ \
      git \
      gnuplot \
      graphviz \
      gtkwave \
      htop \
      ibus-mozc \
      iotop \
      iproute2 \
      iputils-ping \
      iverilog \
      language-pack-ja \
      less \
      libavcodec-dev \
      libavdevice-dev \
      libavformat-dev \
      libgflags-dev \
      libgl1-mesa-dri \
      libgnome2-bin \
      libgoogle-glog-dev \
      libgtk2.0-dev \
      libjson-c-dev \
      libtool\
      libunwind-dev \
      make \
      mesa-utils \
      nis \
      opencl-headers \
      openssh-server \
      python3-minimal \
      python3-opencv \
      python3-pip \
      python3-setuptools \
      python3-venv \
      ruby \
      software-properties-common \
      supervisor \
      sysstat \
      tig \
      tmux \
      tree \
      ttf-ubuntu-font-family \
      ubuntu-desktop \
      unity \
      unzip \
      valgrind \
      vim \
      wget \
      x11-utils \
      xorgxrdp \
      xrdp \
      xserver-xorg-core \
      xz-utils \
      zenity \
      zsh \
      zstd \
      && apt autoclean -y \
      && apt autoremove -y \
      && rm -rf /var/lib/apt/lists/*

RUN update-locale LANG=ja_JP.UTF-8

COPY files/yp.conf /etc/yp.conf
COPY files/nsswitch.conf /etc/nsswitch.conf
COPY files/startwm.sh /etc/xrdp/startwm.sh
COPY files/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

RUN mkdir -p /var/run/sshd /var/run/dbus

# Install packages
RUN apt-get update -y && apt-get install -y \
      gtkterm \
      libgraphviz-dev \
      lv \
      ruby-dev \
      verilator \
      && apt autoclean -y \
      && apt autoremove -y \
      && rm -rf /var/lib/apt/lists/*

RUN pip3 install \
      Flask \
      jupyter \
      matplotlib \
      numpy \
      pillow \
      pipenv \
      pyserial \
      scipy \
      setuptools \
      wheel

RUN apt-get update -y && \
    apt-get install -y libgtest-dev; \
    cd /usr/src/gtest; \
    mkdir build; \
    cd build && cmake .. && make && make install

# Install XRT
WORKDIR /tmp
RUN wget -O xrt.deb https://www.xilinx.com/bin/public/openDownload?filename=xrt_202010.2.6.655_18.04-amd64-xrt.deb && \
    apt-get update -y && \
    apt-get install -y ./xrt.deb && \
    rm -rf ./xrt.deb && \
    rm -rf /var/lib/apt/lists/*

# Install packages from source
RUN wget -O glog.0.4.0.tar.gz https://codeload.github.com/google/glog/tar.gz/v0.4.0 && \
    tar xf  glog.0.4.0.tar.gz && cd glog-0.4.0 && ./autogen.sh && \
    mkdir build && cd build && cmake -DBUILD_SHARED_LIBS=ON .. && make -j 12 && make install && rm -rf /tmp/*
RUN wget https://codeload.github.com/google/protobuf/zip/v3.4.0 && \
    unzip v3.4.0 && cd protobuf-3.4.0 && ./autogen.sh && ./configure && make -j 12 && make install && ldconfig
RUN wget https://github.com/opencv/opencv/archive/3.4.0.tar.gz && tar -xvf 3.4.0.tar.gz && \
    cd opencv-3.4.0 && mkdir build && cd build && \
    cmake -D CMAKE_BUILD_TYPE=RELEASE -D CMAKE_INSTALL_PREFIX=/usr/local -D WITH_FFMPEG=ON -D WITH_TBB=ON -D WITH_GTK=ON \
      -D WITH_V4L=ON -D WITH_OPENGL=ON -D WITH_CUBLAS=ON -DWITH_QT=OFF -DCUDA_NVCC_FLAGS="-D_FORCE_INLINES" .. && \
    make -j 12 && make install && ldconfig && rm -rf /tmp/*
RUN wget http://launchpadlibrarian.net/436533799/libjson-c4_0.13.1+dfsg-4_amd64.deb && \
    dpkg -i libjson-c4_0.13.1+dfsg-4_amd64.deb && rm -rf /tmp/*

# Env for Vitis AI
ENV VAI_ROOT=/opt/vitis_ai
ENV PATH="${VAI_ROOT}/utility:${PATH}"

# Install conda
ENV MY_CONDA_CHANNEL="file:///scratch/conda-channel"

WORKDIR /scratch
RUN wget -q https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh && \
    /bin/bash ./miniconda.sh -b -p $VAI_ROOT/conda && \
    ln -s $VAI_ROOT/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh

COPY files/conda_requirements.txt /scratch/
COPY files/conda_requirements_neptune.txt /scratch/
COPY files/pip_requirements.txt /scratch/
COPY files/pip_requirements_neptune.txt /scratch/

RUN wget -O conda-channel.tar.gz https://www.xilinx.com/bin/public/openDownload?filename=conda-channel_1.2.tar.gz && \
    tar xf conda-channel.tar.gz && \
    source $VAI_ROOT/conda/etc/profile.d/conda.sh && \
    conda create -n vitis-ai-caffe \
        python=3.6 caffe_decent \
        --file /scratch/conda_requirements.txt \
        -c $MY_CONDA_CHANNEL -c defaults -c conda-forge/label/gcc7 && \
    conda activate vitis-ai-caffe && \
    pip install -r /scratch/pip_requirements.txt && \
    conda create -n vitis-ai-tensorflow \
        python=3.6 vai_q_tensorflow keras \
        --file /scratch/conda_requirements.txt \
        -c $MY_CONDA_CHANNEL -c defaults -c conda-forge/label/gcc7 && \
    conda activate vitis-ai-tensorflow && \
    pip install -r /scratch/pip_requirements.txt && \
    conda create -n vitis-ai-neptune \
        python=3.6 \
        --file /scratch/conda_requirements_neptune.txt \
        -c $MY_CONDA_CHANNEL -c defaults -c conda-forge/label/gcc7 -c conda-forge && \
    conda activate vitis-ai-neptune && \
    pip install -r /scratch/pip_requirements_neptune.txt && \
    mkdir -p $VAI_ROOT/compiler && \
    ln -s /opt/vitis_ai/conda/envs/vitis-ai-tensorflow/lib/python3.6/site-packages/vaic/arch /opt/vitis_ai/compiler/arch && \
    rm -rf /scratch/*

# Install Vitis AI 1.2
WORKDIR /tmp
RUN wget -O libunilog.deb           https://www.xilinx.com/bin/public/openDownload?filename=libunilog_1.2.0-r10_amd64.deb && \
    wget -O libtarget-factory.deb   https://www.xilinx.com/bin/public/openDownload?filename=libtarget-factory_1.2.0-r10_amd64.deb && \
    wget -O libxir.deb              https://www.xilinx.com/bin/public/openDownload?filename=libxir_1.2.0-r12_amd64.deb && \
    wget -O libvart.deb             https://www.xilinx.com/bin/public/openDownload?filename=libvart_1.2.0-r16_amd64.deb && \
    wget -O libvitis_ai_library.deb https://www.xilinx.com/bin/public/openDownload?filename=libvitis_ai_library_1.2.0-r15_amd64.deb && \
	  apt-get install -y --no-install-recommends /tmp/*.deb && \
	  sudo ldconfig && \
	  rm /tmp/*.deb && \
    rm -rf /var/lib/apt/lists/*

# Install Alveo deployment platforms
RUN wget -O u200.deb     https://www.xilinx.com/bin/public/openDownload?filename=xilinx-u200-xdma-201830.2-2580015_18.04.deb && \
    wget -O u250.deb     https://www.xilinx.com/bin/public/openDownload?filename=xilinx-u250-xdma-201830.2-2580015_18.04.deb && \
    wget -O u280-es1.deb https://www.xilinx.com/bin/public/openDownload?filename=xilinx-u280-es1-xdma-201910.1-2579327_18.04.deb && \
	  apt-get install -y ./*.deb && \
	  rm *.deb && \
    rm -rf /var/lib/apt/lists/*

RUN wget -O u50.tar.gz   https://www.xilinx.com/bin/public/openDownload?filename=Xilinx_u50-gen3x16-xdma-201920.3-2784799_18.04_deb.tar.gz && \
    tar xf u50.tar.gz && \
	  apt-get install -y /tmp/*.deb && \
	  rm *.deb *.tar.gz && \
    rm -rf /var/lib/apt/lists/*

# Vitis AI GitHub
RUN cd $VAI_ROOT && \
    git clone https://github.com/Xilinx/Vitis-AI.git workspace

# U50 overlay
RUN wget https://www.xilinx.com/bin/public/openDownload?filename=U50_xclbin-v2.tar.gz -O U50_xclbin-v2.tar.gz && \
    tar xf U50_xclbin-v2.tar.gz && \
    cp U50_xclbin/6E250M/dpu.xclbin U50_xclbin/6E250M/hbm_address_assignment.txt /usr/lib && \
    rm -rf *.tar.gz U50_xclbin

# U200/U250 overlay
RUN wget -O overlay.deb https://www.xilinx.com/bin/public/openDownload?filename=xilinx-overlaybins.deb && \
    wget -O xplusml.deb https://www.xilinx.com/bin/public/openDownload?filename=vai-1.1-xplusml-bins-18.04.deb && \
	  apt-get install -y /tmp/*.deb && \
	  rm *.deb && \
    rm -rf /var/lib/apt/lists/*

# xbutler
RUN apt-get install -y $VAI_ROOT/workspace/alveo/packages/ubuntu/xbutler_3.0-2.deb & sleep 10

COPY files/supervisor/xbutler.conf /etc/supervisor/conf.d

# entry
COPY files/supervisor/entry.conf /etc/supervisor/conf.d

# VART
RUN cd $VAI_ROOT/workspace && \
    wget https://www.xilinx.com/bin/public/openDownload?filename=vitis_ai_runtime_r1.2.0_image_video.tar.gz -O vitis_ai_runtime_image_video.tar.gz && \
    tar xf vitis_ai_runtime_image_video.tar.gz -C VART && \
    rm vitis_ai_runtime_image_video.tar.gz

# Vitis AI Library
RUN wget -O xilinx_model_zoo_u50.deb https://www.xilinx.com/bin/public/openDownload?filename=xilinx_model_zoo_u50_1.2.0_amd64.deb && \
    dpkg -i xilinx_model_zoo_u50.deb && \
    rm xilinx_model_zoo_u50.deb

RUN wget https://www.xilinx.com/bin/public/openDownload?filename=xilinx_model_zoo_u50_pytorch_1.2.0_amd64.deb -O xilinx_model_zoo_u50_pytorch.deb && \
    dpkg -i xilinx_model_zoo_u50_pytorch.deb && \
    rm xilinx_model_zoo_u50_pytorch.deb

RUN cd $VAI_ROOT/workspace && \
    wget -O vitis_ai_library_images.tar.gz https://www.xilinx.com/bin/public/openDownload?filename=vitis_ai_library_r1.2.0_images.tar.gz && \
    wget -O vitis_ai_library_video.tar.gz   https://www.xilinx.com/bin/public/openDownload?filename=vitis_ai_library_r1.2.0_video.tar.gz && \
    tar xf vitis_ai_library_images.tar.gz -C Vitis-AI-Library/overview && \
    tar xf vitis_ai_library_video.tar.gz  -C Vitis-AI-Library/overview && \
    rm *.tar.gz

EXPOSE 22 3389

CMD ["/usr/bin/supervisord"]
