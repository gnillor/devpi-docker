FROM python:3.9.18

# Add the user of devpi
RUN useradd -m -U -s /bin/bash devpi

# Install packages
RUN pip install --no-cache-dir -i https://mirrors.aliyun.com/pypi/simple/ \
    "devpi-client==6.0.5" \
    "devpi-web==4.2.1" \
    "devpi-server==6.9.2"

EXPOSE 3141
VOLUME /data

COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

ENV HOME /data
WORKDIR /data

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["devpi"]
