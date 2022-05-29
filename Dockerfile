## Installer
FROM ubuntu:focal AS installer

ARG CIQ_SDK_VERSION
ENV CIQ_SDK_DOWNLOAD_URL="https://developer.garmin.com/downloads/connect-iq"
ENV CIQ_SDK_MANAGER_DIR_URL="${CIQ_SDK_DOWNLOAD_URL}/sdk-manager"
ENV CIQ_SDK_MANAGER_LIST_URL="${CIQ_SDK_MANAGER_DIR_URL}/sdk-manager.json"
#ENV CIQ_SDK_MANAGER_URL="${CIQ_SDK_MANAGER_DIR_URL}/connectiq-sdk-manager-linux.zip"
ENV CIQ_SDK_DIR_URL="${CIQ_SDK_DOWNLOAD_URL}/sdks"
ENV CIQ_SDK_LIST_URL="${CIQ_SDK_DIR_URL}/sdks.json"
#ENV CIQ_SDK_URL="${CIQ_SDK_DIR_URL}/connectiq-sdk-lin-${VERSION}-${DATE}-${CHECKSUM}.zip"

# OS dependencies
RUN \
    export DEBIAN_FRONTEND='noninteractive' \
    && apt-get update --quiet \
    && apt-get install --no-install-recommends --yes \
       ca-certificates \
       jq \
       wget \
       unzip

# SDK manager
RUN \
    export CIQ_SDK_MANAGER_URL="${CIQ_SDK_MANAGER_DIR_URL}/$(wget -qO- "${CIQ_SDK_MANAGER_LIST_URL}" | jq -r '.linux')" \
    && wget --progress=bar "${CIQ_SDK_MANAGER_URL}" -O "/connectiq-sdk-manager-linux.zip" \
    && mkdir -p "/opt/connectiq-sdk-manager-linux" \
    && cd "/opt/connectiq-sdk-manager-linux" \
    && unzip "/connectiq-sdk-manager-linux.zip" \
    && chmod -R go-w "/opt/connectiq-sdk-manager-linux"

# SDK
RUN \
    export CIQ_SDK_URL="${CIQ_SDK_DIR_URL}/$(wget -qO- "${CIQ_SDK_LIST_URL}" | jq -r ".[] | select(.version==\"${CIQ_SDK_VERSION}\") | .linux")" \
    && wget --progress=bar "${CIQ_SDK_URL}" -O "/connectiq-sdk-linux.zip" \
    && mkdir -p "/opt/connectiq-sdk-linux" \
    && cd "/opt/connectiq-sdk-linux" \
    && unzip "/connectiq-sdk-linux.zip" \
    && chmod -R go-w "/opt/connectiq-sdk-linux"


## SDK
FROM ubuntu:focal AS sdk

ARG CIQ_SDK_UID=1000
ARG CIQ_SDK_GID=1000
ARG EULA_ACCEPT_MSCOREFONTS="false"

# Legalese
RUN \
    echo "ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula boolean ${EULA_ACCEPT_MSCOREFONTS}" | debconf-set-selections

# OS dependencies
# NOTA BENE:
# - Connect IQ SDK requires: libusb-1.0, libwebkit2gtk-4.0-37
# - Hiero requires: openjdk-8-jdk, x11-xserver-utils (xrandr), libnvidia-gl-470 (<-> GLX)
RUN \
    export DEBIAN_FRONTEND='noninteractive' \
    && apt-get update --quiet \
    && apt-get install --no-install-recommends --yes \
       ca-certificates \
       curl \
       libusb-1.0-0 \
       libwebkit2gtk-4.0-37 \
       make \
       openjdk-8-jdk \
       sudo \
       tzdata \
       x11-xserver-utils \
       mesa-utils \
       libnvidia-gl-470 \
       ttf-mscorefonts-installer \
       libgtk-3-0 \
       libwebkit2gtk-4.0-37 \
    && apt-get clean

# User/group
RUN \
    addgroup \
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
    && echo '_ciq ALL=NOPASSWD: ALL' > /etc/sudoers.d/_ciq \
    && chmod 440 /etc/sudoers.d/_ciq

# ConnectIQ SDK
COPY --from=installer /opt/connectiq-sdk-manager-linux /opt/connectiq-sdk-manager-linux
COPY --from=installer /opt/connectiq-sdk-linux /opt/connectiq-sdk-linux
RUN \
    ln -s "/opt/connectiq-sdk-manager-linux/bin/sdkmanager" "/usr/local/bin/sdkmanager" \
    && touch "/opt/connectiq-sdk-linux/bin/default.jungle" \
    && chown _ciq "/opt/connectiq-sdk-linux/bin/default.jungle" \
    && mkdir "/home/ciq/src" \
    && chown _ciq:_ciq "/home/ciq/src"

CMD /bin/bash
