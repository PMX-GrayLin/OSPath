# Use an official Python runtime as a parent image
# FROM ubuntu:18.04
FROM graygray/ubuntu18full

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
    python-crypto \
    apt-utils \
	libudev-dev \
	libusb-1.0-0-dev \
	bsdmainutils \
	libengine-pkcs11-openssl \
	opensc \
    pktools \
	systemd-dev* \
	usbutils \
	libssl-dev \
	cmake \
	check \
	gengetopt \
	help2man 

CMD ["/bin/bash"]
