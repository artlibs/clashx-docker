## clashx

```shell
$ docker run -p 7890:7890 -p 9090:9090 -v ./config:/config i36lib/clashx:latest

$ ./reload.sh config http://127.0.0.1:9090
```
