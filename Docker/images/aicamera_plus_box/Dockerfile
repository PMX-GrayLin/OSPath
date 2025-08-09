# Use an official Python runtime as a parent image
FROM ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Taiwan

# Set bash as the default shell
SHELL ["/bin/bash", "-c"]

WORKDIR /tmp

# Update package list and install prerequisites
RUN apt-get update && apt-get install -y \
    software-properties-common \
    && add-apt-repository ppa:deadsnakes/ppa \
    && apt-get update

RUN apt-get update && apt-get install -y \
    libelf-dev \
    dpkg-dev \
    sudo \
    curl \
    locales \
    file \
    lz4 \
    nano \
    tree \
    zstd \
    gawk \
    wget \
    git \
    diffstat \
    unzip \
    texinfo \
    gcc \
    build-essential \
    chrpath \
    socat \
    cpio \
    libstdc++-12-dev \
    xz-utils \
    debianutils \
    iputils-ping \
    libegl1-mesa \
    libsdl1.2-dev \
    pylint \
    xterm \
    mesa-common-dev \
    gfortran \
    git-lfs \
    lbzip2 \
    e2fsprogs \
    libssl-dev \
    parted \
    # Python build deps
    libssl-dev zlib1g-dev libbz2-dev \
    libreadline-dev libsqlite3-dev \
    libncurses5-dev libncursesw5-dev \
    xz-utils tk-dev libffi-dev liblzma-dev \
    llvm make

# Install Python 3.9 and pip
#RUN apt-get install -y python3.9 python3.9-distutils \
#&& curl -sS https://bootstrap.pypa.io/get-pip.py | python3.9
# Set Python 3.9 as the default python3
#RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.9 1

# Build Python 3.8.18 (example)
RUN cd /tmp && \
    wget https://www.python.org/ftp/python/3.9.0/Python-3.9.0.tgz && \
    tar -xzf Python-3.9.0.tgz && \
    cd Python-3.9.0 && \
    ./configure --enable-optimizations && \
    make -j$(nproc) && \
    make altinstall && \
    ln -sf /usr/local/bin/python3.9 /usr/local/bin/python3

# Install Python packages via pip (works with your 3.8)
RUN python3 -m pip install --upgrade pip && \
    pip install pexpect gitpython jinja2 python-subunit
    
    # python3 \
    # python3-pip \
    # python3-pexpect \
    # python3-git \
    # python3-jinja2 \
    # python3-subunit \

# RUN apt-get remove -y python3 && \
#     cd /tmp && \
#     wget https://www.python.org/ftp/python/3.8.0/Python-3.8.0.tgz && \
#     tar -xzf Python-3.8.0.tgz && \
#     cd Python-3.8.0 && \
#     ./configure && make && make install

#RUN mkdir -p ~/.bin
#RUN PATH="${HOME}/.bin:${PATH}"
RUN curl https://storage.googleapis.com/git-repo-downloads/repo > /usr/local/bin/repo
RUN chmod a+rx /usr/local/bin/repo
#RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Create a new user called 'user'
RUN useradd -m -d /home/gray.lin -s /bin/bash gray.lin && \
    echo "gray.lin:zxcv1234" | chpasswd && \
    echo "%sudo ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    adduser gray.lin sudo && \
    locale-gen en_US.UTF-8 && \
    update-locale LANG=en_US.UTF-8

# Automatically extract tar archives with ADD
ADD ./ssh.tar.gz /home/gray.lin
ADD ./x.sh /home/gray.lin
ADD ./env /home/gray.lin

RUN mv /home/gray.lin/ssh /home/gray.lin/.ssh && \
    chmod 400 /home/gray.lin/.ssh/id_rsa && \
    chmod 777 /home/gray.lin/x.sh && \
    mkdir -p /home/gray.lin/build

# Set the new user as the default user
USER gray.lin
WORKDIR /home/gray.lin/build

# ENV PATH="/home/gray.lin:$PATH"

RUN git config --global user.email "gray.lin@primax.com.tw" && \
    git config --global user.name "Gray.Lin" && \
    git config --global color.ui auto && \
    git config --global --add safe.directory '*' && \
    ssh-keyscan github.com >> ~/.ssh/known_hosts && \
    ssh-keyscan gitlab.com >> ~/.ssh/known_hosts && \
    echo "source ~/env" >> ~/.bashrc

CMD ["/bin/bash"]