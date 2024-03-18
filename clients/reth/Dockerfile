FROM ghcr.io/paradigmxyz/reth:latest

USER root
RUN apt-get update && apt-get install -y --no-install-recommends \
  curl \
  bash \
  ca-certificates \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* && update-ca-certificates
RUN mkdir /ephemery_config && chmod 777 /ephemery_config

WORKDIR /wrapper
COPY wrapper/wrapper.lib.sh clients/reth/wrapper.sh /wrapper/

EXPOSE 30303 30303/udp 9001 8545 8546
ENTRYPOINT ["./wrapper.sh"]
