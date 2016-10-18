# Use phusion/baseimage as base image
FROM gdevenyi/magetbrain-bids-ants:alpha

RUN apt-get update \
    && apt-get install --auto-remove --no-install-recommends -y parallel \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update \
    && apt-get install -y --auto-remove --no-install-recommends curl \
    && curl -o anaconda.sh https://repo.continuum.io/miniconda/Miniconda2-latest-Linux-x86_64.sh \
    && bash anaconda.sh -b -p /opt/anaconda && rm anaconda.sh \
    && apt-get purge --auto-remove -y curl \
    && rm -rf /var/lib/apt/lists/*

#RUN /opt/anaconda/bin/conda config --add channels conda-forge
#RUN /opt/anaconda/bin/conda install -y --channel SimpleITK SimpleITK

ENV CONDA_PATH "/opt/anaconda"

RUN apt-get update \
    && apt-get install -y --no-install-recommends --auto-remove git \
    && git clone --depth 1 https://github.com/CobraLab/antsRegistration-MAGeT.git /opt/antsRegistration-MAGeT \
    && git clone --depth 1 https://github.com/CobraLab/atlases.git /opt/atlases \
    && apt-get purge --auto-remove -y git \
    && rm -rf /var/lib/apt/lists/*

RUN /opt/anaconda/bin/pip install qbatch

## Install the validator
RUN apt-get update && \
    apt-get install -y curl && \
    curl -sL https://deb.nodesource.com/setup_4.x | bash - && \
    apt-get remove -y curl && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN npm install -g bids-validator@0.18.17

ENV PATH /opt/ANTs/bin:/opt/anaconda/bin:/opt/antsRegistration-MAGeT/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

RUN mkdir /scratch
RUN mkdir /local-scratch

RUN mkdir -p /code
COPY run.py /code/run.py
RUN chmod +x /code/run.py

COPY version /version

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


ENTRYPOINT ["/code/run.py"]
