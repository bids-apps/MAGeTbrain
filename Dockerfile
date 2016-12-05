# Use an image with pre-built ANTs included
FROM gdevenyi/magetbrain-bids-ants:e56f961bf99b8bcb98eb25774eec3ca9479ca3ba

RUN apt-get update \
    && apt-get install --auto-remove --no-install-recommends -y parallel \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update \
    && apt-get install -y --no-install-recommends --auto-remove git curl unzip \
    && curl -o anaconda.sh https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh \
    && bash anaconda.sh -b -p /opt/anaconda && rm -f anaconda.sh \
    && git clone  https://github.com/CobraLab/antsRegistration-MAGeT.git /opt/antsRegistration-MAGeT \
    && (cd /opt/antsRegistration-MAGeT && git checkout d329c9ba7474321e11f96998b1066279bd09e7eb) \
    && git clone --depth 1 https://github.com/CobraLab/atlases.git /opt/atlases \
    && curl -sL http://cobralab.net/files/brains_t1.tar.bz2 | tar xvj -C /opt/atlases \
    && curl -o /opt/atlases/colin.zip -sL http://packages.bic.mni.mcgill.ca/mni-models/colin27/mni_colin27_1998_minc2.zip \
    && mkdir /opt/atlases/colin && unzip /opt/atlases/colin.zip -d /opt/atlases/colin && rm -f /opt/atlases/colin.zip \
    && curl -sL https://deb.nodesource.com/setup_4.x | bash - \
    && apt-get install -y nodejs \
    && apt-get purge --auto-remove -y git curl unzip \
    && rm -rf /var/lib/apt/lists/*

ENV CONDA_PATH "/opt/anaconda"

RUN /opt/anaconda/bin/pip install qbatch

RUN npm install -g bids-validator@0.18.17

ENV PATH /opt/ANTs/bin:/opt/anaconda/bin:/opt/antsRegistration-MAGeT/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
ENV QBATCH_SYSTEM local

RUN mkdir -p /scratch /local-scratch /code
COPY run.py /code/run.py
RUN chmod +x /code/run.py

COPY version /version

ENTRYPOINT ["/code/run.py"]
