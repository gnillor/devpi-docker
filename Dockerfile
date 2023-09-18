FROM python:3.9.18

# Install packages
RUN pip install --no-cache-dir -i https://mirrors.aliyun.com/pypi/simple/ \
    "devpi-client" \
    "devpi-web" \
    "devpi-server" \
    "devpi"

EXPOSE 3141
VOLUME /data

COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

ENV HOME /data
WORKDIR /data

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["devpi"]
