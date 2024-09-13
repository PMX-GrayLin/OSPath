# Use an official Python runtime as a parent image
FROM graygray/sav530

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Taiwan

# Set the working directory to /app
WORKDIR /src

RUN wget https://launchpad.net/ubuntu/+archive/primary/+sourcefiles/pcsc-lite/1.8.23-1/pcsc-lite_1.8.23.orig.tar.bz2 && tar -jxvf pcsc-lite_1.8.23.orig.tar.bz2
RUN wget https://launchpad.net/ubuntu/+archive/primary/+sourcefiles/ccid/1.4.29-1/ccid_1.4.29.orig.tar.bz2 && tar -jxvf ccid_1.4.29.orig.tar.bz2
RUN wget https://developers.yubico.com/yubico-piv-tool/Releases/yubico-piv-tool-2.2.0.tar.gz && tar -zxvf yubico-piv-tool-2.2.0.tar.gz

RUN cd /src/pcsc-lite-1.8.23 && ./configure && make && make install
RUN cd /src/ccid-1.4.29 && ./configure && make && make install && cp src/92_pcscd_ccid.rules /etc/udev/rules.d/
RUN cd /src/yubico-piv-tool-2.2.0 && mkdir build; cd build && cmake .. && make && make install

WORKDIR /tmp

RUN ldconfig

COPY openssl.cnf /usr/lib/ssl/openssl.cnf

COPY scripts/* /scripts/
RUN chmod a+x /scripts/*.sh

COPY docker-entrypoint.sh /entrypoint.sh
RUN chmod a+x /entrypoint.sh
# ENTRYPOINT ["/entrypoint.sh"]

CMD ["/bin/bash"]
