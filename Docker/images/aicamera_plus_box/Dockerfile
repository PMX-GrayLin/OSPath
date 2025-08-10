# ===============================
# Stage 1: Build Python 3.9 + pip
# ===============================
FROM ubuntu:22.04 AS python-build

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Taiwan

SHELL ["/bin/bash", "-c"]

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl wget ca-certificates build-essential \
    libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev \
    libncurses5-dev libncursesw5-dev tk-dev libffi-dev liblzma-dev \
    llvm make xz-utils \
    && rm -rf /var/lib/apt/lists/*

# Build Python from source
RUN cd /tmp && \
    wget https://www.python.org/ftp/python/3.9.19/Python-3.9.19.tgz && \
    tar -xzf Python-3.9.19.tgz && \
    cd Python-3.9.19 && \
    ./configure --enable-optimizations && \
    make -j$(nproc) && \
    make altinstall && \
    curl -sS https://bootstrap.pypa.io/get-pip.py | /usr/local/bin/python3.9

# ===============================
# Stage 2: Final runtime image
# ===============================
FROM ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Taiwan \
    LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8

SHELL ["/bin/bash", "-c"]

# Runtime dependencies only (no build tools)
RUN apt-get update && apt-get install -y --no-install-recommends \
    software-properties-common \
    libelf-dev dpkg-dev sudo curl locales file lz4 nano tree zstd \
    gawk wget git diffstat unzip texinfo gcc build-essential chrpath \
    socat cpio libstdc++-12-dev xz-utils debianutils iputils-ping \
    libegl1-mesa libsdl1.2-dev pylint xterm mesa-common-dev gfortran \
    git-lfs lbzip2 e2fsprogs parted \
    && rm -rf /var/lib/apt/lists/*

# Copy Python from build stage
COPY --from=python-build /usr/local /usr/local

# Install Python packages
RUN python3.9 -m pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir pexpect gitpython jinja2 python-subunit && \
    update-alternatives --install /usr/bin/python3 python3 /usr/local/bin/python3.9 1

# Install repo tool
RUN curl -s https://storage.googleapis.com/git-repo-downloads/repo > /usr/local/bin/repo && \
    chmod a+rx /usr/local/bin/repo

# Create user
RUN useradd -m -d /home/gray.lin -s /bin/bash gray.lin && \
    echo "gray.lin:zxcv1234" | chpasswd && \
    adduser gray.lin sudo && \
    echo "%sudo ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    locale-gen en_US.UTF-8 && \
    update-locale LANG=en_US.UTF-8

# Copy configs and scripts
ADD ./ssh.tar.gz /home/gray.lin
ADD ./x.sh /home/gray.lin
ADD ./env /home/gray.lin

RUN mv /home/gray.lin/ssh /home/gray.lin/.ssh && \
    chmod 400 /home/gray.lin/.ssh/id_rsa && \
    chmod 700 /home/gray.lin/.ssh && \
    chmod 755 /home/gray.lin/x.sh && \
    mkdir -p /home/gray.lin/build && \
    chown -R gray.lin:gray.lin /home/gray.lin

USER gray.lin
WORKDIR /home/gray.lin/build

RUN git config --global user.email "gray.lin@primax.com.tw" && \
    git config --global user.name "Gray.Lin" && \
    git config --global color.ui auto && \
    git config --global --add safe.directory '*' && \
    ssh-keyscan github.com >> ~/.ssh/known_hosts && \
    ssh-keyscan gitlab.com >> ~/.ssh/known_hosts && \
    echo "source ~/env" >> ~/.bashrc

CMD ["/bin/bash"]
