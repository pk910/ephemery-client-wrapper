FROM ethpandaops/ethereumjs:master

RUN apt-get update && apt-get install -y --no-install-recommends \
  curl \
  bash \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*
RUN mkdir /ephemery_config && chmod 777 /ephemery_config

RUN mkdir /wrapper
COPY ../../wrapper/wrapper.lib.sh clients/ethereumjs/wrapper.sh /wrapper/

EXPOSE 8545 8551 30303
ENTRYPOINT ["wrapper.sh"]
