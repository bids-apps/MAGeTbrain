# Use phusion/baseimage as base image
FROM phusion/baseimage:0.9.19

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update \
    && apt-get install -y curl cmake build-essential git parallel zlib1g-dev apt-utils

RUN curl -o anaconda.sh https://repo.continuum.io/miniconda/Miniconda2-latest-Linux-x86_64.sh
RUN bash anaconda.sh -b -p /opt/anaconda && rm anaconda.sh
RUN /opt/anaconda/bin/conda config --add channels conda-forge
RUN /opt/anaconda/bin/conda install -y --channel SimpleITK SimpleITK
#RUN /opt/anaconda/bin/conda install -y vtk
#RUN /opt/anaconda/bin/conda install -y system

ENV CONDA_PATH "/opt/anaconda"
#ENV VTK_DIR "$CONDA_PATH/lib/cmake/vtk-7.0"
#          -DVTK_DIR:STRING=$VTK_DIR \


#Sadly, ANTs hasn't had a real release in a long time, so we need to build form source
RUN git clone https://github.com/stnava/ANTs.git /opt/ANTs && cd /opt/ANTs && git checkout 9bc1866a758c2c7b6da463566edc3cdaed65a829
#RUN git clone https://github.com/gdevenyi/ANTs.git --branch vtk-fix /opt/ANTs
RUN mkdir /opt/ANTs/build && cd /opt/ANTs/build && \
    cmake -DITK_BUILD_MINC_SUPPORT:BOOL=ON \
          /opt/ANTs && \
          make

RUN git clone --depth 1 https://github.com/CobraLab/antsRegistration-MAGeT.git /opt/antsRegistration-MAGeT
RUN /opt/anaconda/bin/pip install qbatch


RUN curl -sL https://deb.nodesource.com/setup_4.x | bash -
RUN apt-get install -y nodejs
RUN npm install -g bids-validator

ENV PATH /opt/ANTs/build/bin:/opt/anaconda/bin:/opt/antsRegistration-MAGeT/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

RUN mkdir /scratch
RUN mkdir /local-scratch

RUN mkdir -p /code
COPY run.py /code/run.py
RUN chmod +x /code/run.py

COPY version /version

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


ENTRYPOINT ["/code/run.py"]
