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

# entry
COPY files/supervisor/entry.conf /etc/supervisor/conf.d

# Fix icon
RUN apt-get update -y && apt-get install -y \
      gnome-icon-theme \
      && apt autoclean -y \
      && apt autoremove -y \
      && rm -rf /var/lib/apt/lists/*

# Fix no lsb message
RUN apt-get update -y && apt-get install -y \
      lsb-core \
      && apt autoclean -y \
      && apt autoremove -y \
      && rm -rf /var/lib/apt/lists/*

# VNC
RUN apt-get update -y && apt-get install -y \
      tigervnc-standalone-server tigervnc-common tigervnc-xorg-extension \
      && apt autoclean -y \
      && apt autoremove -y \
      && rm -rf /var/lib/apt/lists/*

COPY files/xstartup /etc/vnc/xstartup
COPY files/Xvnc-session /etc/X11/Xvnc-session
COPY files/vnc.conf /etc/vnc.conf

###############################################################

# Add packages here
RUN apt-get update -y && apt-get install -y \
      gtkterm \
      libgraphviz-dev \
      lv \
      ruby-dev \
      verilator \
      ffmpeg \
      gcc-multilib \
      g++-multilib \
      && apt autoclean -y \
      && apt autoremove -y \
      && rm -rf /var/lib/apt/lists/*

## # For docker image debug (test only)
## RUN apt-get update -y && apt-get install -y \
##       net-tools \
##       && apt autoclean -y \
##       && apt autoremove -y \
##       && rm -rf /var/lib/apt/lists/*

###############################################################

EXPOSE 22 3389 5901

CMD ["/usr/bin/supervisord"]
