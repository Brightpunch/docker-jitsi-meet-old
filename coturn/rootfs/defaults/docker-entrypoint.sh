#!/bin/ash

# make certs if not exist
if [[ ! -f /config/cert.crt || ! -f /config/cert.key  ]]; then
  openssl req -newkey rsa:2048 -nodes -keyout /config/cert.key -x509 -days 3650 -out /config/cert.crt -subj "/C=US/ST=NY/L=NY/O=IT/CN=${TURN_HOST}"
fi

# use non empty TURN_PUBLIC_IP variable, othervise set it dynamically.
[ -z "${TURN_PUBLIC_IP}" ] && export TURN_PUBLIC_IP=$(curl -4ks https://icanhazip.com)
[ -z "${TURN_PUBLIC_IP}" ] && echo "ERROR: variable TURN_PUBLIC_IP is not set and can not be set dynamically!" && kill 1

[ -z "${TURN_LOCAL_IP}" ] && export TURN_LOCAL_IP=$(hostname -i)
[ -z "${TURN_LOCAL_IP}" ] && echo "ERROR: variable TURN_LOCAL_IP is not set and can not be set dynamically!" && kill 1

# set coturn web-admin access
if [[ "${TURN_ADMIN_ENABLE}" == "1" || "${TURN_ADMIN_ENABLE}" == "true" ]]; then
  turnadmin -A -u ${TURN_ADMIN_USER:-admin} -p ${TURN_ADMIN_SECRET:-changeme}
  export TURN_ADMIN_OPTIONS="--web-admin --web-admin-ip=$(hostname -i) --web-admin-port=${TURN_ADMIN_PORT:-8443}"
fi

# template the configuration file with environment variables
frep /defaults/turnserver.conf:/etc/turnserver.conf --overwrite

#--no-stun \
#--cert=/certs/turn-annolens.pem \
#--pkey=/certs/turn-annolens.key \
#--server-name=coturn.annolens.com \
# --no-stun \

# run coturn server with API auth method enabled.
turnserver ${TURN_ADMIN_OPTIONS} \
# --verbose \
# --no-cli \
# --prod \
# --no-tlsv1 \
# --no-tlsv1_1 \
# --log-file=stdout \
#--listening-port=${TURN_PORT:-5349} \
#--tls-listening-port=${TURN_PORT:-5349} \
#--alt-listening-port=${TURN_PORT:-5349} \
#--alt-tls-listening-port=${TURN_PORT:-5349} \
# --cert=/certs/cert.crt \
# --pkey=/certs/cert.key \
#--min-port=${TURN_RTP_MIN:-30000} \
#--max-port=${TURN_RTP_MAX:-30500} \
# --use-auth-secret \
#--static-auth-secret=${TURN_SECRET:-keepthissecret} \
# --no-multicast-peers \
#--realm=${TURN_REALM:-realm} \
#--listening-ip=$(hostname -i) \
#--external-ip=${TURN_PUBLIC_IP} \
# --cipher-list=ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384 \
# --denied-peer-ip=0.0.0.0-0.255.255.255,10.0.0.0-10.255.255.255
# #--denied-peer-ip=100.64.0.0-100.127.255.255
#--denied-peer-ip=127.0.0.0-127.255.255.255
#--denied-peer-ip=169.254.0.0-169.254.255.255
#--denied-peer-ip=172.16.0.0-172.31.255.255
#--denied-peer-ip=192.0.0.0-192.0.0.255
#--denied-peer-ip=192.0.2.0-192.0.2.255
#--denied-peer-ip=192.88.99.0-192.88.99.255
#--denied-peer-ip=192.168.0.0-192.168.255.255
#--denied-peer-ip=198.18.0.0-198.19.255.255
#--denied-peer-ip=198.51.100.0-198.51.100.255
#--denied-peer-ip=203.0.113.0-203.0.113.255
#--denied-peer-ip=240.0.0.0-255.255.255.255
