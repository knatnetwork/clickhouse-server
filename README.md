# Clickhouse Server Multi-Arch

## Images

This repo provides the following images, both are Multi-Arch(amd64/arm64 supported):

* `knatnetwork/clickhouse-server:<tag>`

`<tag>` is related to the https://github.com/clickhouse/clickhouse/tags, for example, you may expect a image called `knatnetwork/clickhouse-server:21.8.3.44-lts` when `v21.8.3.44-lts` is created.

You can browse all the tags on https://hub.docker.com/r/knatnetwork/clickhouse-server/tags?page=1&ordering=name

Currently, tags before v21.7.x cannot be built on ARM64, thus the earliest tag is `21.8.3.44-lts`.

## Development

If you wish to build locally, you should do the following steps:

```bash
git clone https://github.com/knatnetwork/clickhouse-server.git
cd clickhouse
cd ClickHouse && git checkout v<TAG_NAME> && git submodule update --init --recursive
cd ..
docker buildx build --platform linux/arm64,linux/amd64 -t knatnetwork/clickhouse-server:<TAG_NAME> . --push
```

Dockerfile is relying on  https://github.com/knatnetwork/clickhouse-builder as there have clang-12 and CMake 3.21.3 preinstalled.(They compile very slow on ARM64, especially when using QEMU)

## License

GPL