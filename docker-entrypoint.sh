#!/bin/bash

# Set default storage paths
function defaults {
    : ${DEVPI_SERVERDIR="/data/devpi/server"}
    : ${DEVPI_CLIENTDIR="/data/devpi/client"}

    echo "DEVPI_SERVERDIR is ${DEVPI_SERVERDIR}"
    echo "DEVPI_CLIENTDIR is ${DEVPI_CLIENTDIR}"

    export DEVPI_SERVERDIR DEVPI_CLIENTDIR
}

# Init devpi
function init_devpi {
    echo "[RUN]: Init devpi-server"
    devpi-server --init
    devpi-server --start --host 127.0.0.1 --port 3141 --serverdir ${DEVPI_SERVERDIR}
    devpi-server --status
    devpi use http://localhost:3141

    devpi user -c admin password=admin
    devpi login admin --password admin
    devpi index -c douban type=mirror mirror_url=http://pypi.douban.com/simple
    devpi index -c aliyun type=mirror mirror_url=http://mirrors.aliyun.com/pypi/simple/
    devpi index -c douban bases=admin/aliyun,admin/douban,root/pypi mirror_whitelist='*'
    devpi index -y -c public mirror_whitelist='*'
    devpi-server --stop
    devpi-server --status
}

defaults

if [ "$1" = 'devpi' ]; then
    if [ ! -f  $DEVPI_SERVERDIR/.serverversion ]; then
        init_devpi
    fi

    echo "[RUN]: Launching devpi-server"
    exec devpi-server --host 0.0.0.0 --port 3141
fi

echo "[RUN]: Builtin command not provided [devpi]"
echo "[RUN]: $@"

exec "$@"
