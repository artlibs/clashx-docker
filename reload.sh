#!/bin/bash

# Function to handle SIGTERM
terminate() {
    echo "Received SIGTERM, terminating..."
    exit 0
}

# Function to modify config.yaml
modify_config() {
    config_file="/config/config.yaml"

    # Modify specific lines in config.yaml
    sed -i '/^mode:/d' "$config_file"
    sed -i '/^allow-lan:/d' "$config_file"
    sed -i '/^socks-port:/d' "$config_file"
    sed -i '/^mixed-port:/d' "$config_file"
    sed -i '/^log-level:/d' "$config_file"
    sed -i '/^external-ui:/d' "$config_file"
    sed -i '/^external-controller:/d' "$config_file"
    sed -i '/^  sniff-tls-sni:/d' "$config_file"
    sed -i '/^experimental:/d' "$config_file"
    sed -i '/^tun:$/,+9d' "$config_file"
    sed -i -e 's/^port: 789*$/port: 7890/' \
           -e '/^port: 7890$/a mode: Rule' \
           -e '/^port: 7890$/a socks-port: 7890' \
           -e '/^port: 7890$/a mixed-port: 7890' \
           -e '/^port: 7890$/a allow-lan: true' \
           -e '/^port: 7890$/a log-level: warning' \
           -e '/^port: 7890$/a external-ui: /var/app/webui' \
           -e '/^port: 7890$/a external-controller: 0.0.0.0:9090' \
           -e '/^port: 7890$/a experimental:\n  sniff-tls-sni: true' "$config_file"
    sed -i 's/rules:/rules:\n  - DOMAIN-SUFFIX,httpbin.org,DIRECT/' "$config_file"

    # Add content to the end of config.yaml
    cat <<EOL >> "$config_file"
tun:
  enable: true
  stack: system
  dns-hijack:
    - 8.8.8.8:53
    - tcp://8.8.8.8:53
    - any:53
    - tcp://any:53
  auto-route: true
  auto-detect-interface: true
EOL
}

# Trap SIGTERM signal
trap terminate SIGTERM

# Default sleep time in minutes
default_sleep_minutes=15

# Check if the sleep time is specified in the environment variable, otherwise use the default
sleep_minutes=${REFRESH_CONFIG_INTERVAL:-$default_sleep_minutes}

# Convert minutes to seconds
sleep_seconds=$((sleep_minutes * 60))

# Loop indefinitely
while true; do
    # Read the first line of /config/rss_url and trim whitespace
    touch /config/rss_url
    url=$(head -n 1 /config/rss_url | xargs)

    if [ -n "$url" ]; then
        # Download the content from the URL and save it as config.yaml
        curl_output=$(curl -sS -m 5 -w "\n%{http_code}\n" -o /config/config.yaml "$url")
        
        # Extract the HTTP status code from the response
        http_code=$(echo "$curl_output" | tail -n 1)

        # Check if the HTTP status code is not 200
        if [ "$http_code" -ne 200 ]; then
            echo "Failed to download config file: HTTP $http_code"
            continue
        fi

        # Modify the downloaded config.yaml
        modify_config

        # Perform a PUT request to the specified address and capture response and HTTP code
        response=$(curl -sS -m 5 -w "\n%{http_code}\n" -X PUT -H "Content-Type: application/json" \
            -d '{"path": "/config/config.yaml"}' \
            http://127.0.0.1:9090/configs)
        
        # Extract the HTTP status code from the response
        http_code=$(echo "$response" | tail -n 1)

        if [ "$http_code" -eq 204 ]; then
            echo "Config reloaded."
        else
            # Print the response and the HTTP code for debugging
            echo "Failed to reload config: HTTP $http_code"
            echo "$response"
        fi
    else
        echo "URL is empty or not found"
    fi

    # Sleep for a specified interval before the next iteration
    sleep "$sleep_seconds"
done

