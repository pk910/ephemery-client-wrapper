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

| Client | Image | Tested |
|--------|-------|---------------------|
| Besu   | [pk910/ephemery-besu](https://hub.docker.com/r/pk910/ephemery-besu) |  |
| Erigon | [pk910/ephemery-erigon](https://hub.docker.com/r/pk910/ephemery-erigon) |  |
| Geth   | [pk910/ephemery-geth](https://hub.docker.com/r/pk910/ephemery-geth) | yes |
| Nethermind | [pk910/ephemery-nethermind](https://hub.docker.com/r/pk910/ephemery-nethermind) |  |
| Reth | [pk910/ephemery-reth](https://hub.docker.com/r/pk910/ephemery-reth) | yes |

### Consensus Clients

| Client | Image | Tested |
|--------|-------|---------------------|
| Lighthouse | [pk910/ephemery-lighthouse](https://hub.docker.com/r/pk910/ephemery-lighthouse) | yes |
| Lodestar | [pk910/ephemery-lodestar](https://hub.docker.com/r/pk910/ephemery-lodestar) |  |
| Prysm   | [pk910/ephemery-prysm-beacon](https://hub.docker.com/r/pk910/ephemery-prysm-beacon) / [pk910/ephemery-prysm-validator](https://hub.docker.com/r/pk910/ephemery-prysm-validator) |  |
| Teku | [pk910/ephemery-teku](https://hub.docker.com/r/pk910/ephemery-teku) | yes |

