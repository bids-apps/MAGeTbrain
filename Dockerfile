# Use an image with pre-built ANTs included
FROM gdevenyi/magetbrain-bids-ants:82dcdd647211004f3220e4073ea4daf06fdf89f9

RUN apt-get update \
    && apt-get install --auto-remove --no-install-recommends -y parallel git curl gzip bzip2 gnupg2 unzip coreutils ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN curl --insecure -o anaconda.sh https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh \
    && bash anaconda.sh -b -p /opt/anaconda && rm -f anaconda.sh

RUN curl -o /opt/atlases-nifti.zip -sL http://cobralab.net/files/atlases-nifti.zip \
    && mkdir /opt/atlases-nifti \
    && unzip /opt/atlases-nifti.zip -d /opt \
    && curl -sL http://cobralab.net/files/brains_t1_nifti.tar.bz2 | tar xvj -C /opt/atlases-nifti \
    && curl -o /opt/atlases-nifti/colin.zip -sL http://packages.bic.mni.mcgill.ca/mni-models/colin27/mni_colin27_1998_nifti.zip \
    && mkdir /opt/atlases-nifti/colin && unzip /opt/atlases-nifti/colin.zip -d /opt/atlases-nifti/colin && rm -f /opt/atlases-nifti/colin.zip \
    && gzip /opt/atlases-nifti/colin/colin27_t1_tal_lin.nii

RUN curl --insecure -sL https://deb.nodesource.com/setup_10.x | bash - \
    && apt-get install -y --no-install-recommends --auto-remove nodejs \
    && rm -rf /var/lib/apt/lists/*

ENV CONDA_PATH "/opt/anaconda"

RUN /opt/anaconda/bin/conda config --append channels conda-forge
RUN /opt/anaconda/bin/conda install -y numpy scipy nibabel pandas
RUN /opt/anaconda/bin/pip install future six
RUN /opt/anaconda/bin/pip install duecredit
RUN /opt/anaconda/bin/pip install pybids
RUN npm install -g bids-validator@0.26.18 --unsafe-perm

RUN git clone https://github.com/CobraLab/antsRegistration-MAGeT.git /opt/antsRegistration-MAGeT && \
    (cd /opt/antsRegistration-MAGeT && git checkout tags/v0.3.1)
RUN /opt/anaconda/bin/pip install git+https://github.com/pipitone/qbatch.git@951dd1bdfdcbb5fd3f27ee6a3e261eaecac1ef70

ENV PATH /opt/ANTs/bin:/opt/anaconda/bin:/opt/antsRegistration-MAGeT/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
ENV QBATCH_SYSTEM local

RUN mkdir -p /scratch /local-scratch /code
COPY run.py /code/run.py
RUN chmod +x /code/run.py

COPY version /version

ENTRYPOINT ["/code/run.py"]
