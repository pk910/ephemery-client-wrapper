FROM ethereum/client-go:stable

RUN apk add --no-cache curl bash && rm -rf /var/cache/apk/*
RUN mkdir /ephemery_config && chmod 777 /ephemery_config

WORKDIR /wrapper
COPY wrapper/wrapper.lib.sh clients/geth/wrapper.sh /wrapper/
EXPOSE 8545 8546 30303 30303/udp
ENTRYPOINT ["./wrapper.sh"]
