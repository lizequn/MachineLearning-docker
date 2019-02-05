# =================================
# cuda          10.0
# cudnn         v7
# ---------------------------------
# python        3.6
# anaconda      5.2.0
# Jupyter Notebook @:8008  
# ---------------------------------
# Xgboost       latest(gpu)
# lightgbm      latest(gpu)
# ---------------------------------
# tensorflow    1.13.0rc0 (pip)
# tensorboard   latest (pip) @:6006
# pytorch       latest (pip)
# torchvision   latest (pip)
# keras         latest (pip)
# ---------------------------------

FROM nvidia/cuda:10.0-base-ubuntu16.04 as base
LABEL maintainer="lzq910123@gmail.com"

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8


# =================================
# Path/Env Setting
# =================================


ENV CUDA_HOME /usr/local/cuda
ENV LD_LIBRARY_PATH $LD_LIBRARY_PATH:$CUDA_HOME/lib64
ENV LD_LIBRARY_PATH $LD_LIBRARY_PATH:/usr/local/lib
ENV LD_LIBRARY_PATH /usr/local/cuda/extras/CUPTI/lib64:$LD_LIBRARY_PATH

ENV CI_BUILD_PYTHON python
ENV TF_NEED_CUDA 1
ENV TF_NEED_TENSORRT 1
ENV TF_CUDA_COMPUTE_CAPABILITIES=3.5,5.2,6.0,6.1,7.0
ENV TF_CUDA_VERSION=10.0
ENV TF_CUDNN_VERSION=7

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
        libjpeg-dev \
        libpng-dev \
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
# Cuda
# =================================
RUN apt-get update && apt-get install -y --no-install-recommends \
        cuda-command-line-tools-10-0 \
        cuda-cublas-10-0 \
        cuda-cufft-10-0 \
        cuda-curand-10-0 \
        cuda-cusolver-10-0 \
        cuda-cusparse-10-0 \
        libcudnn7=7.4.1.5-1+cuda10.0 \
        libfreetype6-dev \
        libhdf5-serial-dev \
        libpng12-dev \
        libzmq3-dev \
        pkg-config \
        software-properties-common \
        unzip

RUN apt-get update && \
        apt-get install nvinfer-runtime-trt-repo-ubuntu1604-5.0.2-ga-cuda10.0 \
        && apt-get update \
        && apt-get install -y --no-install-recommends libnvinfer5=5.0.2-1+cuda10.0 \
        && apt-get clean \
        && rm -rf /var/lib/apt/lists/*

# =================================
# Anaconda
# =================================
ENV PATH /opt/conda/bin:$PATH
RUN wget --quiet https://repo.anaconda.com/archive/Anaconda3-5.2.0-Linux-x86_64.sh -O ~/anaconda.sh && \
    /bin/bash ~/anaconda.sh -b -p /opt/conda && \
    rm ~/anaconda.sh && \
    ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "conda activate base" >> ~/.bashrc

RUN pip install --upgrade pip

# set up jupyter notebook
COPY jupyter_notebook_config.py /root/.jupyter/
EXPOSE 8888


# =================================
# Tensorflow & keras
# =================================
# Options:
#   tensorflow-gpu
#   tf-nightly-gpu
RUN pip --no-cache-dir install http://storage.googleapis.com/tensorflow/linux/gpu/tensorflow_gpu-1.13.0rc0-cp36-cp36m-linux_x86_64.whl 
EXPOSE 6006

RUN pip --no-cache-dir install keras

# =================================
# Pytorch
# =================================

RUN conda install -y -c pytorch \
    pytorch \
    torchvision \
    cuda100 \
 && conda clean -ya



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

RUN cd /usr/local/src/xgboost/python-package && \
  python setup.py install 


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
RUN /bin/bash -c "cd /usr/local/src/lightgbm/LightGBM/python-package && python setup.py install --precompile "

# =================================
# tini
# =================================

RUN apt-get install -y curl grep sed dpkg && \
    TINI_VERSION=`curl https://github.com/krallin/tini/releases/latest | grep -o "/v.*\"" | sed 's:^..\(.*\).$:\1:'` && \
    curl -L "https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini_${TINI_VERSION}.deb" > tini.deb && \
    dpkg -i tini.deb && \
    rm tini.deb && \
    apt-get clean
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
ENTRYPOINT [ "/usr/bin/tini", "--" ]
CMD ["jupyter", "notebook", "--no-browser", "--allow-root"]
WORKDIR /notebook