# Use an official Python runtime as a parent image
FROM ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Taiwan

WORKDIR /tmp

RUN apt-get update && apt-get install -y \
    curl \
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

RUN mkdir -p ~/.bin
RUN PATH="${HOME}/.bin:${PATH}"
RUN curl https://storage.googleapis.com/git-repo-downloads/repo > ~/.bin/repo
RUN chmod a+rx ~/.bin/repo

CMD ["/bin/bash"]
