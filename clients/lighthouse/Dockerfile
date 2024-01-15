FROM sigp/lighthouse:latest

RUN apt-get update && apt-get install -y --no-install-recommends \
  curl \
  bash \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*
RUN mv /usr/local/bin/lighthouse /usr/local/bin/lighthouse.bin
RUN ln -s /wrapper/wrapper.sh /usr/local/bin/lighthouse

WORKDIR /wrapper
COPY wrapper/wrapper.lib.sh clients/lighthouse/wrapper.sh /wrapper/
