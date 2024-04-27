FROM prysmaticlabs/prysm-beacon-chain:v5.0.3

COPY wrapper /wrapper
SHELL [ "/bin/bash", "-c" ]
ARG TARGETPLATFORM
RUN if [ "$TARGETPLATFORM" = "linux/amd64" ]; then BINARCH=amd64; \
  elif [ "$TARGETPLATFORM" = "linux/arm64" ]; then BINARCH=arm64; \
  else BINARCH=amd64; fi; \
  mv /wrapper/bin-$BINARCH /wrapper/bin; \
  rm -rf /wrapper/bin-*

COPY clients/prysm-beacon/wrapper.sh /wrapper/

ENTRYPOINT ["/wrapper/wrapper.sh"]