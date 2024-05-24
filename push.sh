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

docker push i36lib/clashx:$ARCH_VALUE-latest

echo 'push premium ...'

docker push i36lib/clashx:premium-$ARCH_VALUE-latest

