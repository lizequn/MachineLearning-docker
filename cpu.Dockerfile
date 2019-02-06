# =================================
# python        3.6
# anaconda      5.2.0
# Jupyter Notebook @:8888  
# AwS api       boto3(pip)
# ---------------------------------
# Xgboost       latest(pip)
# lightgbm      latest
# ---------------------------------

FROM ubuntu:16.04

# =================================
# basic
# =================================
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8
ENV PATH /opt/conda/bin:$PATH

RUN apt-get update --fix-missing && apt-get install -y wget bzip2 ca-certificates \
    libglib2.0-0 libxext6 libsm6 libxrender1 \
    git mercurial subversion \
    build-essential gcc g++ \
    cmake

RUN apt-get clean

# =================================
# Anaconda
# =================================
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
# AWS api
# =================================
RUN pip --no-cache-dir install boto3

# =================================
# Xgboost 
# =================================
RUN pip --no-cache-dir install xgboost

# =================================
# lightgbm
# =================================
RUN apt-get install -y libboost-all-dev


RUN cd /usr/local/src && mkdir lightgbm && cd lightgbm && \
    git clone --recursive https://github.com/Microsoft/LightGBM && \
    cd LightGBM && mkdir build && cd build && \
    cmake .. && \
	make -j
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