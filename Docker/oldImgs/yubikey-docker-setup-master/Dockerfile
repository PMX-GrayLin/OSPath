FROM gcc:6.1

WORKDIR /data

RUN wget https://launchpad.net/ubuntu/+archive/primary/+sourcefiles/pcsc-lite/1.8.23-1/pcsc-lite_1.8.23.orig.tar.bz2
RUN git clone https://salsa.debian.org/rousseau/PCSC.git
RUN wget https://launchpad.net/ubuntu/+archive/primary/+sourcefiles/ccid/1.4.29-1/ccid_1.4.29.orig.tar.bz2
RUN wget https://launchpad.net/ubuntu/+archive/primary/+sourcefiles/yubico-piv-tool/1.4.2-2ubuntu0.1/yubico-piv-tool_1.4.2.orig.tar.gz

RUN tar -jxvf pcsc-lite_1.8.23.orig.tar.bz2 && rm -rf pcsc-lite_1.8.23.orig.tar.bz2 && \
  tar -jxvf ccid_1.4.29.orig.tar.bz2 && rm -rf ccid_1.4.29.orig.tar.bz2 && \
  tar -zxvf yubico-piv-tool_1.4.2.orig.tar.gz && rm -rf yubico-piv-tool_1.4.2.orig.tar.gz

RUN apt-get update
RUN apt-get install -y apt-utils
RUN apt-get install -y libudev-dev libusb-1.0-0-dev bsdmainutils libengine-pkcs11-openssl opensc pktools systemd-dev* usbutils

RUN cd /data/pcsc-lite-1.8.23 && ./configure && make && make install
RUN cd /data/ccid-1.4.29 && ./configure && make && make install && cp src/92_pcscd_ccid.rules /etc/udev/rules.d/
RUN cd /data/yubico-piv-tool-1.4.2 && ./configure && make && make install

# WORKDIR /
RUN rm -rf mv /usr/local/lib64/libstdc++.so.6.0.22-gdb.py && ldconfig

COPY openssl.cnf /usr/lib/ssl/openssl.cnf

COPY scripts/* /scripts/
RUN chmod a+x /scripts/*.sh

COPY docker-entrypoint.sh /entrypoint.sh
RUN chmod a+x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

CMD ["help"]
