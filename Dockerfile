# syntax=docker/dockerfile:1.7
FROM python:3.11-slim-bookworm

# Upstream release. The checksum is the SHA-256 of the GitHub source archive.
# The upstream repository is archived, so this version does not change.
ARG SATELLITE_VERSION=v1.4.1
ARG SATELLITE_SHA256=a539789b30f6b4d957cc75bf54549536a8e9b8508e99dda1e2d4cfd62eaffb6b

LABEL org.opencontainers.image.source="https://github.com/jlejeune/wyoming-satellite-karotz"
LABEL org.opencontainers.image.description="Wyoming satellite for a Karotz rabbit"
LABEL org.opencontainers.image.licenses="MIT"

ENV LANG=C.UTF-8 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

WORKDIR /opt

# Download the upstream sources and check the checksum.
ADD --checksum=sha256:${SATELLITE_SHA256} \
    https://github.com/rhasspy/wyoming-satellite/archive/refs/tags/${SATELLITE_VERSION}.tar.gz \
    /tmp/satellite.tar.gz

# Install the sources as an editable package, as the upstream script/setup does.
# A normal install loses the wyoming_satellite/utils package.
COPY requirements.txt /tmp/requirements.txt
RUN mkdir /opt/wyoming-satellite \
    && tar -xzf /tmp/satellite.tar.gz -C /opt/wyoming-satellite --strip-components=1 \
    && rm /tmp/satellite.tar.gz \
    && pip install -r /tmp/requirements.txt \
    && pip install --no-deps -e /opt/wyoming-satellite \
    && rm /tmp/requirements.txt

COPY relay/ /opt/relay/
COPY run.sh /opt/run.sh
RUN chmod +x /opt/run.sh

# The satellite does not need root rights.
RUN useradd --system --uid 10001 --no-create-home satellite
USER 10001

EXPOSE 10700
ENTRYPOINT ["/opt/run.sh"]
