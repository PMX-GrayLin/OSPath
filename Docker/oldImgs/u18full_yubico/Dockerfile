# Use an official Python runtime as a parent image
FROM graygray/ubuntu18full

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Taiwan

RUN apt-get update && apt-get install -y \
	apt-utils \
	libudev-dev \
	libusb-1.0-0-dev \
	bsdmainutils \
	libengine-pkcs11-openssl \
	opensc pktools \
	gcc \
	systemd-dev* \
	usbutils \
	libssl-dev \
	cmake \
	check \
	gengetopt \
	help2man 

# Set the working directory to /app
# WORKDIR /src

# RUN wget https://launchpad.net/ubuntu/+archive/primary/+sourcefiles/pcsc-lite/1.8.23-1/pcsc-lite_1.8.23.orig.tar.bz2 && tar -jxvf pcsc-lite_1.8.23.orig.tar.bz2
# RUN wget https://launchpad.net/ubuntu/+archive/primary/+sourcefiles/ccid/1.4.29-1/ccid_1.4.29.orig.tar.bz2 && tar -jxvf ccid_1.4.29.orig.tar.bz2
# RUN wget https://developers.yubico.com/yubico-piv-tool/Releases/yubico-piv-tool-2.2.0.tar.gz && tar -zxvf yubico-piv-tool-2.2.0.tar.gz

# RUN cd /src/pcsc-lite-1.8.23 && ./configure && make && make install
# RUN cd /src/ccid-1.4.29 && ./configure && make && make install && cp src/92_pcscd_ccid.rules /etc/udev/rules.d/
# RUN cd /src/yubico-piv-tool-2.2.0 && mkdir build; cd build && cmake .. && make && make install

WORKDIR /debs
# pcsc-lite package:
RUN wget https://launchpad.net/ubuntu/+archive/primary/+files/libpcsclite-dev_1.8.23-1_amd64.deb
RUN wget https://launchpad.net/ubuntu/+archive/primary/+files/libpcsclite1_1.8.23-1_amd64.deb
RUN wget https://launchpad.net/ubuntu/+archive/primary/+files/libpcsclite1-dbg_1.8.23-1_amd64.deb
RUN wget https://launchpad.net/ubuntu/+archive/primary/+files/pcscd_1.8.23-1_amd64.deb

# ccid package:
RUN wget https://launchpad.net/ubuntu/+archive/primary/+files/libccid_1.4.29-1_amd64.deb

# yubico-piv-tool package:
RUN wget https://launchpad.net/ubuntu/+archive/primary/+files/libykpiv-dev_1.4.2-2ubuntu0.1_amd64.deb
RUN wget https://launchpad.net/ubuntu/+archive/primary/+files/libykpiv1_1.4.2-2ubuntu0.1_amd64.deb
RUN wget https://launchpad.net/ubuntu/+archive/primary/+files/ykcs11_1.4.2-2ubuntu0.1_amd64.deb
RUN wget https://launchpad.net/ubuntu/+archive/primary/+files/yubico-piv-tool_1.4.2-2ubuntu0.1_amd64.deb

RUN dpkg -i *

WORKDIR /
RUN ldconfig

COPY openssl.cnf /usr/lib/ssl/openssl.cnf

COPY scripts/* /scripts/
RUN chmod a+x /scripts/*.sh

COPY docker-entrypoint.sh /entrypoint.sh
RUN chmod a+x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

CMD ["help"]
