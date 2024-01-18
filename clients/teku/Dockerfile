FROM consensys/teku:latest

USER root
RUN apt-get update && apt-get install -y --no-install-recommends \
  curl \
  bash \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*
RUN mkdir /ephemery_config && chmod 777 /ephemery_config

WORKDIR /wrapper
COPY wrapper/wrapper.lib.sh clients/teku/wrapper.sh /wrapper/

USER teku

EXPOSE 5051 8008 9000 9000/udp
ENTRYPOINT ["./wrapper.sh"]