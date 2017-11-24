FROM nvidia/cuda:8.0-cudnn6-devel
MAINTAINER Zequn <lzq910123@gmail.com>

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8
# =================================
# cuda          8.0
# cudnn         v6
# ---------------------------------
# python        3.6
# anaconda      5.0.1
# ---------------------------------
# Xgboost       0.6(gpu)
# lightgbm      2.0.10(gpu)
# ---------------------------------
# tensorflow    1.4.0 (pip)
# pytorch       latest  (pip)
# keras         latest (pip)
# ---------------------------------

# =================================
# Path Setting
# =================================
ENV CUDA_HOME /usr/local/cuda
ENV LD_LIBRARY_PATH ${LD_LIBRARY_PATH}:${CUDA_HOME}/lib64
ENV LD_LIBRARY_PATH ${LD_LIBRARY_PATH}:/usr/local/lib
ENV LD_LIBRARY_PATH /usr/local/cuda/extras/CUPTI/lib64:${LD_LIBRARY_PATH}

ENV OPENCL_LIBRARIES /usr/local/cuda/lib64
ENV OPENCL_INCLUDE_DIR /usr/local/cuda/include
# =================================
# basic
# =================================
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        gcc \
        g++\
        cmake\
        curl \
        git \
        vim\
        mercurial \
        subversion \
        vim \
        libcurl3-dev \
        libfreetype6-dev \
        libpng12-dev \
        libzmq3-dev \
        libglib2.0-0 \
        libxext6 \
        libsm6 \
        libxrender1\
        libboost-dev \
        libboost-system-dev \
        libboost-filesystem-dev \
        pkg-config \
        rsync \
        software-properties-common \
        unzip \
        zip \
        zlib1g-dev \
        openjdk-8-jdk \
        openjdk-8-jre-headless \
        wget \
        bzip2\
        ca-certificates \
        libboost-all-dev \
        && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
# =================================
# Anaconda
# =================================
RUN echo 'export PATH=/opt/conda/bin:$PATH' > /etc/profile.d/conda.sh && \
	wget --quiet https://repo.continuum.io/archive/Anaconda3-5.0.1-Linux-x86_64.sh -O ~/anaconda.sh && \
	/bin/bash ~/anaconda.sh -b -p /opt/conda && \
    rm ~/anaconda.sh

ENV PATH /opt/conda/bin:${PATH}
RUN pip install --upgrade pip
# set up jupyter notebook
COPY jupyter_notebook_config.py /root/.jupyter/
EXPOSE 8888

RUN conda install --quiet --yes gcc

# =================================
# Tensorflow&keras
# =================================
RUN pip --no-cache-dir install \
    http://storage.googleapis.com/tensorflow/linux/gpu/tensorflow_gpu-1.4.0-cp36-cp36m-linux_x86_64.whl
EXPOSE 6006

RUN pip --no-cache-dir install keras

# =================================
# Pytorch
# =================================
RUN conda install --quiet --yes pytorch torchvision cuda80 -c soumith

# =================================
# Xgboost + gpu
# =================================
RUN cd /usr/local/src && \
  git clone --recursive https://github.com/dmlc/xgboost && \
  cd xgboost && \
  mkdir build && \
  cd build && \
  cmake --DUSE_CUDA=ON .. && \
  make -j


# =================================
# lightgbm + gpu
# =================================
RUN apt-get install -y libboost-all-dev

RUN mkdir -p /etc/OpenCL/vendors && \
    echo "libnvidia-opencl.so.1" > /etc/OpenCL/vendors/nvidia.icd
RUN cd /usr/local/src && mkdir lightgbm && cd lightgbm && \
    git clone --recursive https://github.com/Microsoft/LightGBM && \
    cd LightGBM && mkdir build && cd build && \
    cmake -DUSE_GPU=1 -DOpenCL_LIBRARY=/usr/local/cuda/lib64/libOpenCL.so -DOpenCL_INCLUDE_DIR=/usr/local/cuda/include/ .. && \
	make OPENCL_HEADERS=/usr/local/cuda-8.0/targets/x86_64-linux/include LIBOPENCL=/usr/local/cuda-8.0/targets/x86_64-linux/lib
RUN /bin/bash -c "source activate py3 && cd /usr/local/src/lightgbm/LightGBM/python-package && python setup.py install --precompile && source deactivate"

# =================================
# tini
# =================================

ENV TINI_VERSION v0.16.1
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini
# =================================
# clean
# =================================

RUN apt-get autoremove -y && apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    conda clean -i -l -t -y

# =================================
# settings
# =================================
RUN mkdir /notebook
ENTRYPOINT ["tini", "--"]
CMD ["jupyter", "notebook", "--no-browser", "--allow-root"]
WORKDIR /notebook