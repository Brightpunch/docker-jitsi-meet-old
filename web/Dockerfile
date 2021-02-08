ARG JITSI_REPO=jitsi
FROM ${JITSI_REPO}/base

ADD https://raw.githubusercontent.com/acmesh-official/acme.sh/2.8.8/acme.sh /opt

# Note github action will copy jitsi-meet-web and annolens-portal debian packages to rootfs/tmp
COPY rootfs/ /
# COPY jitsi-meet-web_1.0.1-1_all.deb /usr/share/jitsi-meet/ 

RUN \
	apt-dpkg-wrap apt-get update && \
	apt-dpkg-wrap apt-get install -y cron nginx-extras socat && \
	apt-dpkg-wrap apt-get install -y /usr/share/jitsi-meet-web_1.0.1-1_all.deb && \
	apt-dpkg-wrap apt-get -d install -y jitsi-meet-web-config && \
    dpkg -x /var/cache/apt/archives/jitsi-meet-web-config*.deb /tmp/pkg && \
    mv /tmp/pkg/usr/share/jitsi-meet-web-config/config.js /defaults && \
	mv /usr/share/jitsi-meet/interface_config.js /defaults && \
	apt-cleanup && \
	rm -f /usr/share/jitsi-meet-web_1.0.1-1_all.deb && \
	rm -f /etc/nginx/conf.d/default.conf && \
	rm -rf /tmp/pkg /var/cache/apt

EXPOSE 80 443

VOLUME ["/config", "/usr/share/jitsi-meet/transcripts"]
