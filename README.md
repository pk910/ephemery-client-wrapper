# Ephemery Client Images

This repository contains a wrapper script that gets built into ethereum client docker images and provides the ephemery reset mechanism.

The wrapper script takes care of:
* Download the latest ephemery genesis (available within the image at `/ephemery_config`)
* Append ephmery specific client parameters (networkid, bootnodes, ...)
* Reset & initialize the client database on scheduled ephemery reset time
* Restart the client on scheduled ephemery reset time

The ephemery client images built by this repository are intended to be drop-in replacements.
They should work exactly the same way as mainnet nodes, but connect to the ephemery network instead.

## Clients

### Execution Clients

| Client | Image |
|--------|-------|
| Besu   | [pk910/ephemery-besu](https://hub.docker.com/r/pk910/ephemery-besu) |
| Erigon | [pk910/ephemery-erigon](https://hub.docker.com/r/pk910/ephemery-erigon) |
| Geth   | [pk910/ephemery-geth](https://hub.docker.com/r/pk910/ephemery-geth) |
| Nethermind | [pk910/ephemery-nethermind](https://hub.docker.com/r/pk910/ephemery-nethermind) |
| Reth | [pk910/ephemery-reth](https://hub.docker.com/r/pk910/ephemery-reth) |

### Consensus Clients

| Client | Image |
|--------|-------|
| Lighthouse | [pk910/ephemery-lighthouse](https://hub.docker.com/r/pk910/ephemery-lighthouse) |
| Lodestar | [pk910/ephemery-lodestar](https://hub.docker.com/r/pk910/ephemery-lodestar) |
| Prysm   | [pk910/ephemery-prysm-beacon](https://hub.docker.com/r/pk910/ephemery-prysm-beacon) / [pk910/ephemery-prysm-validator](https://hub.docker.com/r/pk910/ephemery-prysm-validator) |
| Teku | [pk910/ephemery-teku](https://hub.docker.com/r/pk910/ephemery-teku) |
| Nimbus | [pk910/ephemery-nimbus](https://hub.docker.com/r/pk910/ephemery-nimbus) |

## Examples

The following examples demonstrate how to use the ephemery client images to spin up ephemery nodes.
You always need to run a EL & CL client. 

The ephemery images are designed to work exactly the same way as the official mainnet images work.
If you want to switch over to mainnet, you litterally just need to change the image name to use the official client image.
All ephemery specific arguments are appended automatically by the wrapper script.

### Prerequisites

```
# generate jwt secret
echo -n 0x$(openssl rand -hex 32 | tr -d "\n") > ./jwtsecret
```

### Execution Clients

**Geth**:
```
docker run --pull always -v $(pwd)/jwtsecret:/execution-auth.jwt:ro -v $(pwd)/el:/data -p 30303:30303 -p 8545:8545 -p 8551:8551 -it pk910/ephemery-geth --datadir=/data --http --http.addr=0.0.0.0 --http.port=8545 --authrpc.addr=0.0.0.0 --authrpc.port=8551 --authrpc.vhosts=* --authrpc.jwtsecret=/execution-auth.jwt
```

**Erigon**:
```
docker run --pull always -v $(pwd)/jwtsecret:/execution-auth.jwt:ro -v $(pwd)/el:/data -p 30303:30303 -p 8545:8545 -p 8551:8551 -it pk910/ephemery-erigon --datadir=/data --http --http.addr=0.0.0.0 --http.port=8545 --authrpc.addr=0.0.0.0 --authrpc.port=8551 --authrpc.vhosts=* --authrpc.jwtsecret=/execution-auth.jwt --db.size.limit=100GB
```

**Besu**:
```
docker run --pull always -v $(pwd)/jwtsecret:/execution-auth.jwt:ro -v $(pwd)/el:/data -p 30303:30303 -p 8545:8545 -p 8551:8551 -it pk910/ephemery-besu --data-path=/data --rpc-http-enabled --rpc-http-host=0.0.0.0 --rpc-http-port=8545 --engine-rpc-port=8551 --engine-host-allowlist=* --engine-jwt-secret=/execution-auth.jwt
```

**Nethermind**:
```
docker run --pull always -v $(pwd)/jwtsecret:/execution-auth.jwt:ro -v $(pwd)/el:/data -p 30303:30303 -p 8545:8545 -p 8551:8551 -it pk910/ephemery-nethermind --datadir=/data --KeyStore.KeyStoreDirectory=/data/keystore --JsonRpc.Enabled=true --JsonRpc.Host=0.0.0.0 --JsonRpc.Port=8545 --JsonRpc.EngineHost=0.0.0.0 --JsonRpc.EnginePort=8551 --JsonRpc.JwtSecretFile=/execution-auth.jwt
```

**Reth**:
```
docker run --pull always -v $(pwd)/jwtsecret:/execution-auth.jwt:ro -v $(pwd)/el:/data -p 30303:30303 -p 8545:8545 -p 8551:8551 -it pk910/ephemery-reth --datadir=/data --http --http.addr=0.0.0.0 --http.port=8545 --authrpc.addr=0.0.0.0 --authrpc.port=8551 --authrpc.vhosts=* --authrpc.jwtsecret=/execution-auth.jwt
```

**EthereumJS**:
```
docker run -v $(pwd)/jwtsecret:/execution-auth.jwt:ro --network host -e JWT_SECRET=/execution-auth.jwt -it pk910/ephemery-ethereumjs
```

### Consensus Clients

**Lighthouse**:
```
docker run --pull always -v $(pwd)/jwtsecret:/execution-auth.jwt:ro -v $(pwd)/cl:/data -p 9000:9000 -p 5052:5052 -it pk910/ephemery-lighthouse lighthouse bn --datadir=/data --http --http-address=0.0.0.0 --http-port=5052 --execution-endpoint=http://172.17.0.1:8551 --execution-jwt=/execution-auth.jwt
```

**Lodestar**:
```
docker run --pull always -v $(pwd)/jwtsecret:/execution-auth.jwt:ro -v $(pwd)/cl:/data -p 9000:9000 -p 5052:5052 -it pk910/ephemery-lodestar beacon --dataDir=/data --rest --rest.address=0.0.0.0 --rest.namespace="*" --rest.port=5052 --execution.urls=http://172.17.0.1:8551 --jwt-secret=/execution-auth.jwt
```

**Teku**:
```
docker run --pull always -v $(pwd)/jwtsecret:/execution-auth.jwt:ro -v $(pwd)/cl:/data -p 9000:9000 -p 5052:5052 -it pk910/ephemery-teku --data-path=/data --rest-api-enabled --rest-api-interface=0.0.0.0 --rest-api-port=5052 --ee-endpoint=http://172.17.0.1:8551 --ee-jwt-secret-file=/execution-auth.jwt --ignore-weak-subjectivity-period-enabled
```

**Prysm**:
```
docker run --pull always -v $(pwd)/jwtsecret:/execution-auth.jwt:ro -v $(pwd)/cl:/data -p 9000:9000 -p 5052:5052 -it pk910/ephemery-prysm-beacon --accept-terms-of-use=true --datadir=/data --grpc-gateway-host=0.0.0.0 --grpc-gateway-port=5052 --execution-endpoint=http://172.17.0.1:8551 --jwt-secret=/execution-auth.jwt --min-sync-peers=2
```
