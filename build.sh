#!/bin/sh

ARCH=$(arch)

if [ "$ARCH" = "i386" ] || [ "$ARCH" = "x86" ]; then
    ARCH_VALUE="amd64"
elif [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "armv8" ]; then
    ARCH_VALUE="arm64"
else
    echo "Error: Unsupported architecture $ARCH" >&2
    exit 1
fi

docker build --build-arg PREMIUM='' \
	--build-arg ARCH_TYPE=$ARCH_VALUE \
	-t i36lib/clashx:$ARCH_VALUE-latest .

echo 'build premium ...'

docker build --build-arg PREMIUM='-premium' \
	--build-arg ARCH_TYPE=$ARCH_VALUE \
	-t  i36lib/clashx:premium-$ARCH_VALUE-latest .

