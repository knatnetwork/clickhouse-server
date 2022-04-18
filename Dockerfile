FROM knatnetwork/clickhouse-builder as buildtime

ARG DEBIAN_FRONTEND=noninteractive

ENV CC=clang-12
ENV CXX=clang++-12

WORKDIR /root
COPY ClickHouse /root/ClickHouse
RUN cd /root/ClickHouse && mkdir build && cd build && cmake .. && ninja
RUN cd /root/ClickHouse/docker/server && tcc su-exec.c -o /bin/su-exec && chown root:root /bin/su-exec

FROM ubuntu:20.04 as runtime

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8
ENV TZ=UTC

EXPOSE 8123 9000 9009

COPY --from=buildtime /bin/su-exec /bin/su-exec

RUN groupadd -r clickhouse --gid=101 && useradd -r -g clickhouse --uid=101 --home-dir=/var/lib/clickhouse --shell=/bin/bash clickhouse

COPY --from=buildtime /root/ClickHouse/build/programs/clickhouse /usr/bin/
COPY --from=buildtime /root/ClickHouse/docker/server/entrypoint.sh /
RUN chmod +x /entrypoint.sh && \
    mkdir -p /etc/clickhouse-server/users.d && mkdir -p /etc/clickhouse-server/config.d && \
    mkdir /docker-entrypoint-initdb.d && \
    ln -s /usr/bin/clickhouse /usr/bin/clickhouse-server && ln -s /usr/bin/clickhouse /usr/bin/clickhouse-client

COPY --from=buildtime /root/ClickHouse/docker/server/docker_related_config.xml /etc/clickhouse-server/config.d/
COPY --from=buildtime /root/ClickHouse/programs/server/config.xml /etc/clickhouse-server/config.xml
COPY --from=buildtime /root/ClickHouse/programs/server/users.xml /etc/clickhouse-server/users.xml

COPY logging.xml /etc/clickhouse-server/config.d/logging.xml

VOLUME /var/lib/clickhouse
ENV CLICKHOUSE_CONFIG=/etc/clickhouse-server/config.xml

ENTRYPOINT ["/entrypoint.sh"]