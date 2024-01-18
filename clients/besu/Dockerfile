FROM hyperledger/besu:24.1.0

USER root
RUN apt-get update && apt-get install -y --no-install-recommends \
  curl \
  bash \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*
RUN mkdir /ephemery_config && chown besu /ephemery_config

WORKDIR /wrapper
COPY wrapper/wrapper.lib.sh clients/besu/wrapper.sh /wrapper/

USER besu

EXPOSE 8545 8551 30303 30303/udp
ENTRYPOINT ["./wrapper.sh"]
