FROM statusim/nimbus-eth2:multiarch-latest

USER root
RUN apt-get update && apt-get install -y --no-install-recommends \
  curl \
  bash \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*
RUN mkdir /ephemery_config && chmod 777 /ephemery_config
RUN mv /home/user/nimbus_beacon_node /home/user/nimbus_beacon_node.bin
RUN ln -s /wrapper/wrapper.sh /home/user/nimbus_beacon_node
USER user

WORKDIR /wrapper
COPY wrapper/wrapper.lib.sh clients/nimbus/wrapper.sh /wrapper/
ENTRYPOINT ["/wrapper/wrapper.sh"]
