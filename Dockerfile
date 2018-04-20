# Use an image with pre-built ANTs included
FROM gdevenyi/magetbrain-bids-ants:21d7c12ee1e332827b04848eb5f70f55d14cac23

RUN apt-get update \
    && apt-get install --auto-remove --no-install-recommends -y parallel \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update \
    && apt-get install -y --no-install-recommends --auto-remove git curl unzip bzip2 \
    && curl -o anaconda.sh https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh \
    && bash anaconda.sh -b -p /opt/anaconda && rm -f anaconda.sh \
    && git clone  https://github.com/CobraLab/antsRegistration-MAGeT.git /opt/antsRegistration-MAGeT \
    && (cd /opt/antsRegistration-MAGeT && git checkout tags/v0.2.2.1) \
    && curl -o /opt/atlases-nifti.zip -sL http://cobralab.net/files/atlases-nifti.zip \
    && mkdir /opt/atlases-nifti \
    && unzip /opt/atlases-nifti.zip -d /opt \
    && curl -sL http://cobralab.net/files/brains_t1_nifti.tar.bz2 | tar xvj -C /opt/atlases-nifti \
    && curl -o /opt/atlases-nifti/colin.zip -sL http://packages.bic.mni.mcgill.ca/mni-models/colin27/mni_colin27_1998_nifti.zip \
    && mkdir /opt/atlases-nifti/colin && unzip /opt/atlases-nifti/colin.zip -d /opt/atlases-nifti/colin && rm -f /opt/atlases-nifti/colin.zip \
    && curl -sL https://deb.nodesource.com/setup_4.x | bash - \
    && apt-get install -y nodejs \
    && apt-get purge --auto-remove -y git curl unzip bzip2 \
    && rm -rf /var/lib/apt/lists/*

ENV CONDA_PATH "/opt/anaconda"

RUN /opt/anaconda/bin/pip install git+https://github.com/pipitone/qbatch.git@aade5b9a17c5a5a2fe6b28267b3bca10b05a5936

RUN npm install -g bids-validator@0.26.4

ENV PATH /opt/ANTs/bin:/opt/anaconda/bin:/opt/antsRegistration-MAGeT/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
ENV QBATCH_SYSTEM local

RUN mkdir -p /scratch /local-scratch /code
COPY run.py /code/run.py
RUN chmod +x /code/run.py

COPY version /version

ENTRYPOINT ["/code/run.py"]
