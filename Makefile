.PHONY: build push

build:
	sh build.sh

push: build
	sh push.sh
