ARG VERSION
FROM instrumentisto/coturn:${VERSION:-latest}

ADD ./rootfs/defaults/docker-entrypoint.sh /docker-entrypoint.sh
ADD ./rootfs/defaults/turnserver.conf /etc/turnserver.conf
COPY rootfs/ /

RUN \ 
  apk add --no-cache certbot && \
  wget -q https://github.com/subchen/frep/releases/download/v1.3.5/frep-1.3.5-linux-amd64 -O /usr/bin/frep && \
  chmod +x /usr/bin/frep

ENTRYPOINT ["/docker-entrypoint.sh"]

VOLUME ["/config"]
EXPOSE 5349 8443 30000:30500/udp

