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
      gtkterm \
      libgraphviz-dev \
      lv \
      ruby-dev \
      verilator \
      gnome-icon-theme \
      lsb-core \
      tigervnc-standalone-server tigervnc-common tigervnc-xorg-extension \
      ffmpeg \
      gcc-multilib g++-multilib \
      pigz \
      libboost-dev \
      && apt autoclean -y \
      && apt autoremove -y \
      && rm -rf /var/lib/apt/lists/*

RUN update-locale LANG=ja_JP.UTF-8
RUN locale-gen en_US.UTF-8

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

# Install XRT
WORKDIR /tmp
RUN wget -O xrt.deb https://www.xilinx.com/bin/public/openDownload?filename=xrt_202120.2.12.427_18.04-amd64-xrt.deb && \
    apt-get update -y && \
    apt-get install -y ./xrt.deb && \
    rm -rf ./xrt.deb && \
    rm -rf /var/lib/apt/lists/*

COPY files/yp.conf /etc/yp.conf
COPY files/nsswitch.conf /etc/nsswitch.conf
COPY files/startwm.sh /etc/xrdp/startwm.sh
COPY files/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY files/supervisor/entry.conf /etc/supervisor/conf.d

# VNC
COPY files/xstartup /etc/vnc/xstartup
COPY files/Xvnc-session /etc/X11/Xvnc-session
COPY files/vnc.conf /etc/vnc.conf

RUN mkdir -p /var/run/sshd /var/run/dbus

###############################################################

## # Add packages here
## RUN apt-get update -y && apt-get install -y \
##       && apt autoclean -y \
##       && apt autoremove -y \
##       && rm -rf /var/lib/apt/lists/*

###############################################################

EXPOSE 22 3389 5901

CMD ["/usr/bin/supervisord"]


