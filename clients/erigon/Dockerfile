FROM erigontech/erigon:v3.8.0

USER root
RUN apt-get update && apt-get install -y --no-install-recommends \
  curl \
  bash \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*
RUN mkdir /ephemery_config && chmod 777 /ephemery_config

WORKDIR /wrapper
COPY wrapper/wrapper.lib.sh clients/erigon/wrapper.sh /wrapper/
USER erigon

EXPOSE 8545 \
       8551 \
       8546 \
       30303 \
       30303/udp \
       42069 \
       42069/udp \
       8080 \
       9090 \
       6060

ENTRYPOINT ["./wrapper.sh"]
