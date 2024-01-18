FROM nethermind/nethermind:latest

RUN apt-get update && apt-get install -y --no-install-recommends \
  curl \
  bash \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*
RUN mkdir /ephemery_config && chmod 777 /ephemery_config

WORKDIR /wrapper
COPY wrapper/wrapper.lib.sh clients/nethermind/wrapper.sh /wrapper/
EXPOSE 8545 8551 30303
ENTRYPOINT ["./wrapper.sh"]
