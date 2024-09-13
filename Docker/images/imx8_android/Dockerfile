# Use an official Python runtime as a parent image
# FROM ubuntu:18.04
FROM graygray/ubuntu18full

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Taiwan

# Set the working directory to /app
WORKDIR /tmp

RUN apt-get update && apt-get install -y \
    uuid \
    uuid-dev \
    zlib1g-dev \
    liblz-dev \
    liblzo2-2 \
    liblzo2-dev \
    lzop \
    git-core \
    curl \
    u-boot-tools \
    mtd-utils \
    android-tools-fsutils \
    openjdk-8-jdk \
    device-tree-compiler \
    gdisk \
    m4 \
    libz-dev \
    make gcc \
    ninja-build \
    bc \
    zip

CMD ["/bin/bash"]
