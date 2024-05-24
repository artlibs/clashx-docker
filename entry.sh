#!/bin/sh

# 如果未设置 PUID 和 PGID 环境变量，则设置默认值
USER_UID=${PUID:-1000}
USER_GID=${PGID:-1000}
USER_NAME="appuser"
GROUP_NAME="appgroup"

# 检查 GID 是否已经存在
if getent group "$USER_GID" > /dev/null 2>&1; then
    # 如果 GID 已存在，使用现有组名
    GROUP_NAME=$(getent group "$USER_GID" | cut -d: -f1)
else
    # 创建新的组
    addgroup -g "$USER_GID" "$GROUP_NAME"
fi

# 检查 UID 是否已经存在
if id -u "$USER_UID" > /dev/null 2>&1; then
    # 如果 UID 已存在，使用现有用户名
    USER_NAME=$(getent passwd "$USER_UID" | cut -d: -f1)
else
    # 创建新的用户，并加入到组
    adduser -u "$USER_UID" -G "$GROUP_NAME" -D "$USER_NAME"
fi

# 确保 /config 目录属于 appuser:appgroup
chown "$USER_NAME:$GROUP_NAME" /config

# 复制 Country.mmdb 到 /config
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

# Start reload.sh in the background as appuser
su "$USER_NAME" -c "/bin/sh /usr/local/bin/reload.sh &"

# Execute /usr/local/bin/clash as appuser
exec su "$USER_NAME" -c "/usr/local/bin/clash -d /config"

# Wait for child processes to finish
wait

