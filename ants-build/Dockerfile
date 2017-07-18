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
    && cd /opt/ANTs-src && git checkout 8084ef5487ce98a643e4c97360272326289d4de3 \
    && mkdir /opt/ANTs-src/build && cd /opt/ANTs-src/build \
    && cmake -DCMAKE_LINKER=/usr/bin/gold -DITK_BUILD_MINC_SUPPORT:BOOL=ON \
    -DBUILD_TESTING:BOOL=OFF -DRUN_LONG_TESTS:BOOL=OFF -DRUN_SHORT_TESTS:BOOL=OFF \
    -DCMAKE_BUILD_TYPE:STRING=Release /opt/ANTs-src && make -j$(nproc) \
    && ln -sf /usr/bin/gold /usr/bin/ld \
    && mkdir -p /opt/ANTs/bin \
    && cp /opt/ANTs-src/build/bin/antsRegistration /opt/ANTs/bin \
    && cp /opt/ANTs-src/build/bin/antsApplyTransforms /opt/ANTs/bin \
    && cp /opt/ANTs-src/build/bin/ImageMath /opt/ANTs/bin \
    && cp /opt/ANTs-src/build/bin/PrintHeader /opt/ANTs/bin \
    && cp /opt/ANTs-src/build/bin/ConvertImage /opt/ANTs/bin \
    && cp /opt/ANTs-src/build/bin/ConvertScalarImageToRGB /opt/ANTs/bin \
    && cp /opt/ANTs-src/build/bin/CreateTiledMosaic /opt/ANTs/bin \
    && cp /opt/ANTs-src/build/bin/AverageImages /opt/ANTs/bin \
    && cp /opt/ANTs-src/build/bin/antsApplyTransformsToPoints /opt/ANTs/bin \
    && rm -rf /opt/ANTs-src \
    && apt-get purge -y --auto-remove $buildDeps \
    && apt-get clean \
    && apt-get --purge autoremove -y \
    && rm -rf /var/lib/apt/lists/*
