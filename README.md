## clashx

See `https://hub.docker.com/repository/docker/i36lib/clashx/tags`

#### Auto reload config:

Put your clash subscription url in the `/your-path/clash/config/rss_url` file

- `AUTO_RELOAD_CONFIG`=true
- `REFRESH_CONFIG_INTERVAL`=15    # minutes

#### Run with docker:

```shell
$ docker run -v /<your-path>/clash/config:/config i36lib/clashx:<platform>-latest --net=host

$ docker run -v /<your-path>/clash/config:/config i36lib/clashx:premium-<platform>-latest --net=host
```

#### Run with docker-compose

```yaml
services:
  clash-proxy:
    container_name: clash-proxy
    hostname: clash-proxy
    # https://hub.docker.com/r/i36lib/clashx/tags
    image: i36lib/clashx:premium-arm64-latest
    network_mode: host
    volumes:
      - /data/proxy/clash/config:/config
    environment:
      - PUID=1000  # user
      - PGID=100  # group
      - UMASK=022
    # - PROXY_SECRET=your secret
      - AUTO_RELOAD_CONFIG=true
      - REFRESH_CONFIG_INTERVAL=15
    restart: unless-stopped
```

### Base On & Thanks

- dreamacro/clash
- dreamacro/clash-premium
- https://github.com/haishanh/yacd
