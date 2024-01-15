FROM ethereum/client-go:stable

RUN apk add --no-cache curl bash

WORKDIR /wrapper
COPY wrapper/wrapper.lib.sh clients/geth/wrapper.sh /wrapper/
EXPOSE 8545 8546 30303 30303/udp
ENTRYPOINT ["./wrapper.sh"]
