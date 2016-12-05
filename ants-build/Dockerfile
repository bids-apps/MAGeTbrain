# Use phusion/baseimage as base image
FROM phusion/baseimage:0.9.19

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

ENV DEBIAN_FRONTEND noninteractive

RUN buildDeps='cmake build-essential git zlib1g-dev' \
    && apt-get update \
    && apt-get install -y $buildDeps --no-install-recommends \
    && rm -rf /var/lib/apt/lists/* \
    && git clone https://github.com/stnava/ANTs.git /opt/ANTs-src \
    && cd /opt/ANTs-src && git checkout e56f961bf99b8bcb98eb25774eec3ca9479ca3ba \
    && mkdir /opt/ANTs-src/build && cd /opt/ANTs-src/build \
    && cmake -DITK_BUILD_MINC_SUPPORT:BOOL=ON \
    -DBUILD_TESTING:BOOL=OFF -DRUN_LONG_TESTS:BOOL=OFF -DRUN_SHORT_TESTS:BOOL=OFF \
    -DCMAKE_BUILD_TYPE:STRING=Release /opt/ANTs-src && make -j$(nproc) \
    && mkdir /opt/ANTs && mv /opt/ANTs-src/build/bin /opt/ANTs \
    && rm -rf /opt/ANTs-src \
    && apt-get purge -y --auto-remove $buildDeps \
    && apt-get clean \
    && apt-get --purge autoremove -y \
    && rm -rf /var/lib/apt/lists/*
