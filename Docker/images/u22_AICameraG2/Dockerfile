# Use an official Python runtime as a parent image
FROM ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Taiwan

WORKDIR /tmp

RUN apt-get update && apt-get install -y \
    libelf-dev \
    dpkg-dev \
    sudo \
    curl \
    locales \
    file \
    lz4 \
    nano \
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
    python3 \
    python3-pip \
    python3-pexpect \
    xz-utils \
    debianutils \
    iputils-ping \
    python3-git \
    python3-jinja2 \
    libegl1-mesa \
    libsdl1.2-dev \
    pylint \
    xterm \
    python3-subunit \
    mesa-common-dev 
    #&& rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    #&& apt-get clean

#RUN mkdir -p ~/.bin
#RUN PATH="${HOME}/.bin:${PATH}"
RUN curl https://storage.googleapis.com/git-repo-downloads/repo > /usr/local/bin/repo
RUN chmod a+rx /usr/local/bin/repo

# Create a new user called 'user'
RUN useradd -m -d /home/gray.lin -s /bin/bash gray.lin && \
    echo "gray.lin:zxcv1234" | chpasswd && \
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
    source /home/gray.lin/env
    # export PATH="/home/gray.lin/":$PATH
 
# Set the new user as the default user
USER gray.lin

ENV PATH="/home/gray.lin:$PATH"

RUN git config --global user.email "gray.lin@primax.com.tw" && \
    git config --global user.name "Gray.Lin" && \
    git config --global color.ui auto && \
    ssh-keyscan github.com >> ~/.ssh/known_hosts

CMD ["/bin/bash"]
