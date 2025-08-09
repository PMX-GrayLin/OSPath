# Use an official Python runtime as a parent image
# Use Ubuntu 22.04 LTS as base
FROM ubuntu:22.04

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# Install dependencies
RUN apt-get update && apt-get install -y \
    gawk wget git diffstat unzip texinfo gcc build-essential \
    chrpath socat cpio python3 python3-pip python3-pexpect \
    xz-utils debianutils iputils-ping python3-git python3-jinja2 \
    libegl1-mesa libelf-dev libsdl1.2-dev lz4 pylint xterm \
    python3-subunit mesa-common-dev libstdc++-12-dev \
    curl locales file pzstd unzstd zstd gfortran \
 && rm -rf /var/lib/apt/lists/*

# Set up repo tool
RUN mkdir -p /root/bin \
 && curl -o /root/bin/repo https://storage.googleapis.com/git-repo-downloads/repo \
 && chmod a+rx /root/bin/repo

# Add repo to PATH
ENV PATH="/root/bin:${PATH}"

# Optionally, verify versions (uncomment to enforce minimum version checks)
# RUN git --version && tar --version && python3 --version && gcc --version && repo --version


# Create a new user called
RUN useradd -m -d /home/gray.lin -s /bin/bash gray.lin && \
    echo "gray.lin:zxcv1234" | chpasswd && \
    echo "%sudo ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
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

# CMD ["/bin/bash"]
# Default command: show versions (adjust as needed)
CMD ["bash", "-lc", "git --version && python3 --version && gcc --version && repo --version"]
