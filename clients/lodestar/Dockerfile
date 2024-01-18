FROM chainsafe/lodestar:latest

RUN apk add --no-cache curl bash && rm -rf /var/cache/apk/*
RUN mkdir /ephemery_config && chmod 777 /ephemery_config

WORKDIR /wrapper
COPY wrapper/wrapper.lib.sh clients/lodestar/wrapper.sh /wrapper/

ENTRYPOINT ["./wrapper.sh"]