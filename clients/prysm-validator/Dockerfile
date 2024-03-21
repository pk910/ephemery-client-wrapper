
FROM ethpandaops/prysm:master

COPY --from=ghcr.io/tarampampam/curl:8.6.0 /bin/curl /bin/curl
COPY wrapper/wrapper.lib.sh clients/prysm-validator/wrapper.sh /wrapper/

ENTRYPOINT ["/wrapper/wrapper.sh"]