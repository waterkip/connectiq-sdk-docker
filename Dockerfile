#
# SPDX-FileCopyrightText: 2017-2022 Cédric Dufour <http://cedric.dufour.name>
# SPDX-FileCopyrightText: 2022 Wesley Schwengle <wesley@opperschaap.net>
#
# SPDX-License-Identifier: Unlicense
#
# The exception is that you CANNOT distribute the resulting image. See the
# README.md for more information
#
## Installer
FROM ubuntu:jammy AS installer

ENV CIQ_SDK_DOWNLOAD_URL="https://developer.garmin.com/downloads/connect-iq"
ENV CIQ_SDK_MANAGER_DIR_URL="${CIQ_SDK_DOWNLOAD_URL}/sdk-manager"
ENV CIQ_SDK_MANAGER_LIST_URL="${CIQ_SDK_MANAGER_DIR_URL}/sdk-manager.json"

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update --quiet \
    && apt-get install --no-install-recommends --yes \
       ca-certificates \
       jq \
       curl \
       unzip
RUN \
    export CIQ_SDK_MANAGER_URL="${CIQ_SDK_MANAGER_DIR_URL}/$(curl -s "${CIQ_SDK_MANAGER_LIST_URL}" | jq -r '.linux')" \
    && curl -s -L "${CIQ_SDK_MANAGER_URL}" -o "/connectiq-sdk-manager-linux.zip" \
    && mkdir -p "/opt/connectiq-sdk-manager-linux" \
    && cd "/opt/connectiq-sdk-manager-linux" \
    && unzip -q "/connectiq-sdk-manager-linux.zip" \
    && chmod -R go-w "/opt/connectiq-sdk-manager-linux"

## SDK
FROM ubuntu:jammy AS sdk

ARG CIQ_SDK_UID=1000
ARG CIQ_SDK_GID=1000
ARG EULA_ACCEPT_MSCOREFONTS="false"

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update --quiet \
    && apt-get upgrade --yes \
    && apt-get install --no-install-recommends --yes \
       # House keeping
       sudo \
       ca-certificates \
       # SDK / SDK manager
       libatk1.0-0 \
       libcairo2 \
       libexpat1 \
       libfontconfig1 \
       libfreetype6 \
       libgdk-pixbuf2.0-0 \
       libglib2.0-0 \
       libgtk-3-0 \
       libjavascriptcoregtk-4.0-18 \
       libjpeg-turbo8 \
       libpango-1.0-0 \
       libpangocairo-1.0-0 \
       libpangoft2-1.0-0 \
       libpng16-16 \
       libsecret-1-0 \
       libsm6 \
       libsoup2.4-1 \
       libwebkit2gtk-4.0-37 \
       libx11-6 \
       libxext6 \
       libxxf86vm1 \
       # SDK manager
       libcurl4 \
       # SDK
       libusb-1.0-0 \
       openjdk-17-jdk \
       # developer env
       make \
       jq \
       vim-tiny \
       less \
       coreutils \
    && apt-get clean \
    && rm -rf /var/cache/apt/* /var/lib/apt/lists/* \
    # User/group
    && addgroup \
       --gid ${CIQ_SDK_GID} \
       --force-badname _ciq \
    && adduser \
       --gecos 'Garmin ConnectIQ SDK' \
       --disabled-login \
       --shell /bin/bash \
       --home /home/ciq \
       --gid ${CIQ_SDK_GID} \
       --uid ${CIQ_SDK_UID} \
       --force-badname _ciq \
    && mkdir "/home/ciq/src" \
    && chown _ciq:_ciq "/home/ciq/src" \
    && echo '_ciq ALL=NOPASSWD: ALL' > /etc/sudoers.d/_ciq \
    && chmod 440 /etc/sudoers.d/_ciq \
    && ln -s "/opt/connectiq-sdk-manager-linux/bin/sdkmanager" "/usr/local/bin/sdkmanager"

# ConnectIQ SDK manager
COPY --from=installer /opt/connectiq-sdk-manager-linux /opt/connectiq-sdk-manager-linux
COPY Makefile.* /etc/garmin-connectiq/
COPY bash-alias /home/ciq/.bash_aliases

CMD /bin/bash

USER _ciq
WORKDIR /home/ciq/src

# Font editor
#FROM sdk as hiero
#
#USER root
#RUN echo "ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula boolean ${EULA_ACCEPT_MSCOREFONTS}" | debconf-set-selections \
#    && apt-get update -q \
#    && apt-get install --no-install-recommends -y \
#       make \
#       tzdata \
#       x11-xserver-utils \
#       mesa-utils \
#       libnvidia-gl-460 \
#       ttf-mscorefonts-installer \
#    && apt-get clean \
#    && rm -rf /var/cache/apt/* /var/lib/apt/lists/*
#
#USER _ciq
