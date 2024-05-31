FROM nethermind/nethermind:latest

RUN apt-get update && apt-get install -y --no-install-recommends \
  curl \
  bash \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*
RUN mkdir /ephemery_config && chmod 777 /ephemery_config

WORKDIR /wrapper
COPY wrapper/wrapper.lib.sh clients/nethermind/wrapper.sh /wrapper/
RUN mv /nethermind/nethermind /nethermind/nethermind.bin
RUN ln -s /wrapper/wrapper.sh /nethermind/nethermind

EXPOSE 8545 8551 30303
ENTRYPOINT ["/nethermind/nethermind"]
