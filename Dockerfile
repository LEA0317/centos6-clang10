FROM centos:centos6

LABEL maintainer "Toshihiro KONDA <kontoshi0317@gmail.com>"

ARG USER
ARG PASSWD

RUN yum -y update && \
    yum clean all && \
    yum -y install sudo && \
    useradd -m ${USER} && \
    echo "${USER}:${PASSWD}" | chpasswd && \
    echo "${USER} ALL=(ALL) ALL" >> /etc/sudoers

RUN cd /home/${USER} && \
    yum -y update && \
    yum -y install gcc gcc-c++ wget && \
    wget http://ftp.tsukuba.wide.ad.jp/software/gcc/releases/gcc-10.1.0/gcc-10.1.0.tar.gz && \
    tar xf gcc-10.1.0.tar.gz && \
    rm gcc-10.1.0.tar.gz && \
    cd gcc-10.1.0 && \
    ./contrib/download_prerequisites && \
    mkdir build && cd build && \
    ../configure --enable-languages=c,c++ --prefix=/usr/local/ --enable-bootstrap --disable-multilib && \
    make -j`nproc` && \
    make -j`nproc` install

RUN cp /usr/local/lib64/libstdc++.so.6.0.28 /usr/lib64 && \
    cd /usr/lib64 && \
    mv libstdc++.so.6 libstdc++.so.6.bak && \
    ln -s libstdc++.so.6.0.28 libstdc++.so.6

RUN cd /home/${USER} && \
    wget https://github.com/Kitware/CMake/archive/v3.15.5.tar.gz && \
    tar xf v3.15.5.tar.gz && \
    rm v3.15.5.tar.gz && \
    cd CMake-3.15.5 && \
    mkdir build && \
    cd build && \
    ../configure --prefix=/usr/local/ && \
    make -j`nproc` && \
    make -j`nproc` install

RUN cd /home/${USER} && \
    wget https://www.python.org/ftp/python/2.7.6/Python-2.7.6.tgz && \
    tar xf Python-2.7.6.tgz && \
    rm Python-2.7.6.tgz && \
    cd Python-2.7.6 && \
    mkdir build && \
    cd build && \
    ../configure --prefix=/usr/local/ && \
    make -j`nproc` && \
    make -j`nproc` install

RUN cd /home/${USER} && \
    wget https://github.com/llvm/llvm-project/archive/llvmorg-10.0.1.tar.gz && \
    tar xf llvmorg-10.0.1.tar.gz && \
    rm llvmorg-10.0.1.tar.gz && \
    cd llvm-project-llvmorg-10.0.1/llvm && \
    mkdir build && \
    cd build && \
    cmake .. -DLLVM_TARGETS_TO_BUILD="X86" -DLLVM_ENABLE_PROJECTS="clang;lld" -DCMAKE_BUILD_TYPE=Release -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX=/usr/local/ -DCMAKE_C_COMPILER=/usr/local/bin/gcc -DCMAKE_CXX_COMPILER=/usr/local/bin/g++ && \
    make -j`nproc` && \
    make -j`nproc` install

USER ${USER}
WORKDIR /home/${USER}