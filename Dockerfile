FROM python:3.9.18

# Install packages
RUN pip install --no-cache-dir -i https://mirrors.aliyun.com/pypi/simple/ \
    "devpi-server==6.3.1" \
    "devpi-client==5.2.3" \
    "devpi-web==4.0.8" \
    "devpi-findlinks==2.0.1" \
    "devpi-lockdown==2.0.0" \
    "devpi-json-info==0.1.3"

EXPOSE 3141
VOLUME /data

COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

ENV HOME /data
WORKDIR /data

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["devpi"]
