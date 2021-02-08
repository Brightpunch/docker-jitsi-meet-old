ARG VERSION
FROM jupyter/scipy-notebook:${VERSION:-latest}

USER root

RUN \ 
	apt-get update \
	&& apt-get install -y apt-transport-https apt-utils ca-certificates gnupg curl \
	&& export GCSFUSE_REPO=gcsfuse-focal \
	&& echo "deb http://packages.cloud.google.com/apt $GCSFUSE_REPO main" | tee /etc/apt/sources.list.d/gcsfuse.list \
	&& curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - \
	&& apt-get update \
	&& apt-get install -y gcsfuse \
	&& rm -rf /var/lib/apt/lists/

ADD ./setup-gcs.sh /usr/local/bin/before-notebook.d/setup-gcs.sh

USER $NB_UID