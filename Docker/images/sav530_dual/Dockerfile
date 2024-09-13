# Use an official Python runtime as a parent image
FROM ubuntu:20.04

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Taiwan

# Set the working directory to /app
WORKDIR /tmp

RUN apt-get update && apt-get install -y \
    python \
    gcc \
    git \
    make-guile \
    bc \
    pkg-config \
    libncurses5-dev \
    libncursesw5-dev \
    vim \
    rename \
    iputils-ping \
    mtd-utils \
    python-crypto

CMD ["/bin/bash"]
