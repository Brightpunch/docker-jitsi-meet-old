ARG BASE_IMAGE=jitsi/jibri
ARG BASE_TAG=latest
FROM ${BASE_IMAGE}:${BASE_TAG}

RUN \
	export GCSFUSE_REPO=gcsfuse-focal \
	&& echo "deb http://packages.cloud.google.com/apt $GCSFUSE_REPO main" | tee /etc/apt/sources.list.d/gcsfuse.list \
	&& curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - \
	&& apt-dpkg-wrap apt-get update \
	&& apt-dpkg-wrap apt-get install -y gcsfuse pulseaudio dbus dbus-x11 rtkit \
	&& apt-cleanup

RUN adduser jibri rtkit

COPY docker/files/ /
