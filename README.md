## clashx

See `https://hub.docker.com/repository/docker/i36lib/clashx/tags`

Put your clash subscription url in the `/your-path/clash/config/rss_url` file

```shell
$ docker run -v /<your-path>/clash/config:/config i36lib/clashx:<platform>-latest --net=host
$ docker run -v /<your-path>/clash/config:/config i36lib/clashx:premium-<platform>-latest --net=host
```
