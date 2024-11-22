FROM ethpandaops/ethereumjs:master

RUN apk add --no-cache curl bash && rm -rf /var/cache/apk/*
RUN mkdir /ephemery_config && chmod 777 /ephemery_config

RUN mkdir /wrapper
COPY ../../wrapper/wrapper.lib.sh clients/ethereumjs/wrapper.sh /wrapper/

EXPOSE 8545 8551 30303
ENTRYPOINT ["/wrapper/wrapper.sh"]
