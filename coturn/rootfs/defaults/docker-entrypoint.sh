#!/bin/ash

# Check certificates haven't been copied in or mounted
if [[ $ENABLE_TURN_CERTS -eq 1 ]]; then 
  if [[ -f /certs/fullchain.pem ]]; then
    cp /certs/fullchain.pem /config/keys/cert.crt
    cp /certs/privkey.pem /config/keys/cert.key
  else
  # otherwise auto generate keys (maybe)
    if [[ $ENABLE_LETSENCRYPT -eq 1 ]]; then
      if [[ ! -f /etc/letsencrypt/live/$LETSENCRYPT_DOMAIN/fullchain.pem ]]; then
        if ! certbot \
              certonly \
              --no-self-upgrade \
              --noninteractive \
              --standalone \
              --preferred-challenges http \
              -d $LETSENCRYPT_DOMAIN \
              --agree-tos \
              --email $LETSENCRYPT_EMAIL ; then

            echo "Failed to obtain a certificate from the Let's Encrypt CA."
            # this tries to get the user's attention and to spare the
            # authority's rate limit:
            sleep 15
            echo "Exiting."
            exit 1
        fi
        # copy keys into persistent store
        mkdir -p /config/keys/$LETSENCRYPT_DOMAIN
        cp /etc/letsencrypt/live/$LETSENCRYPT_DOMAIN/fullchain.pem /config/keys/$LETSENCRYPT_DOMAIN/fullchain.pem
        cp /etc/letsencrypt/live/$LETSENCRYPT_DOMAIN/privkey.pem /config/keys/$LETSENCRYPT_DOMAIN/privkey.pem
        cp /config/keys/$LETSENCRYPT_DOMAIN/fullchain.pem /config/keys/cert.crt
        cp /config/keys/$LETSENCRYPT_DOMAIN/privkey.pem /config/keys/cert.key
      fi
    fi
  fi
fi
# remove default certbot renewal
#if [[ -f /etc/cron.d/certbot ]]; then
#    rm /etc/cron.d/certbot
#fi
#
## setup certbot renewal script
#if [[ ! -f /etc/cron.daily/letencrypt-renew ]]; then
#    cp /defaults/letsencrypt-renew /etc/cron.daily/
#fi

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

# run coturn server with API auth method enabled.
turnserver ${TURN_ADMIN_OPTIONS}