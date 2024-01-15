
FROM ethpandaops/prysm:master

RUN apt-get update && apt-get install -y --no-install-recommends \
  curl \
  bash \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /wrapper
COPY wrapper/wrapper.lib.sh clients/prysm-beacon/wrapper.sh /wrapper/

EXPOSE 3500 4000 9000 9000/udp
ENTRYPOINT ["./wrapper.sh"]