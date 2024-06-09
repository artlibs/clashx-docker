#!/bin/sh

USER_UID=${PUID:-1000}
USER_GID=${PGID:-1000}
USER_NAME="appuser"
GROUP_NAME="appgroup"

if getent group "$USER_GID" > /dev/null 2>&1; then
    GROUP_NAME=$(getent group "$USER_GID" | cut -d: -f1)
else
    addgroup -g "$USER_GID" "$GROUP_NAME"
fi

if id -u "$USER_UID" > /dev/null 2>&1; then
    USER_NAME=$(getent passwd "$USER_UID" | cut -d: -f1)
else
    adduser -u "$USER_UID" -G "$GROUP_NAME" -D "$USER_NAME"
fi

chown "$USER_NAME:$GROUP_NAME" /config
chown "$USER_NAME:$GROUP_NAME" -R /var/app
cp /var/app/Country.mmdb /config

# Function to handle SIGTERM
terminate() {
    echo "Entrypoint received SIGTERM, forwarding to child processes..."
    kill -SIGTERM $(jobs -p)
    wait
    exit 0
}

# Trap SIGTERM and call terminate function
trap terminate SIGTERM

# Start reload.sh in the background if AUTO_RELOAD_CONFIG is true
if [ "$AUTO_RELOAD_CONFIG" = "true" ]; then
    su "$USER_NAME" -c "/bin/sh /usr/local/bin/reload.sh &"
fi

# Execute /usr/local/bin/clash as appuser
exec su "$USER_NAME" -c "/usr/local/bin/clash -d /config"

# Wait for child processes to finish
wait

