#!/bin/bash
function generate_password() {
    set +e
    tr -cd '[:alnum:]' < /dev/urandom | fold -w30 | head -n1 | tr -cd '[:alnum:]'
    set -e
}

DEVPI_ROOT_PASSWORD="${DEVPI_ROOT_PASSWORD:-}"
if [ -f "$DEVPI_SERVERDIR/.root_password" ]; then
    DEVPI_ROOT_PASSWORD=$(cat "$DEVPI_SERVERDIR/.root_password")
elif [ -z "$DEVPI_ROOT_PASSWORD" ]; then
    DEVPI_ROOT_PASSWORD=$(generate_password)
fi

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
    devpi-init --serverdir ${DEVPI_SERVERDIR}
    nohup devpi-server --host 0.0.0.0 --port 3141 --serverdir ${DEVPI_SERVERDIR} --replica-max-retries 3 --file-replication-threads 4 > ${DEVPI_SERVERDIR}/devpi.log 2>&1 &
    sleep 6s

    devpi use http://localhost:3141
    devpi login root --password=''
    devpi user -m root "password=$DEVPI_ROOT_PASSWORD"
    devpi index -c douban type=mirror mirror_url=http://pypi.douban.com/simple
    devpi index -c aliyun type=mirror mirror_url=http://mirrors.aliyun.com/pypi/simple/
}

defaults

if [ "$1" = 'devpi' ]; then
    if [ ! -f  $DEVPI_SERVERDIR/.serverversion ]; then
        init_devpi
    else
        echo "[RUN]: Launching devpi-server"
        nohup devpi-server --host 0.0.0.0 --port 3141 --serverdir ${DEVPI_SERVERDIR} --replica-max-retries 3 --file-replication-threads 4 > ${DEVPI_SERVERDIR}/devpi.log 2>&1 &
    fi
fi

echo "Watching devpi-server"
PID=$(pgrep devpi-server)

if [ -z "$PID" ]; then
    echo "ENTRYPOINT: Could not determine PID of devpi-server!"
    exit 1
fi

while : ; do
    kill -0 "$PID" > /dev/null 2>&1 || break
    sleep 2s
done

echo "ENTRYPOINT: devpi-server died, exiting..."
