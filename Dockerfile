FROM postgres:14 AS builder

ARG USER=docker
ARG UID=1000
ARG GID=1000

RUN useradd -m ${USER} --uid=${UID}

RUN apt-get update -y
RUN apt-get install -y bison flex zlib1g zlib1g-dev pkg-config make libssl-dev libreadline-dev wget gnupg gcc make build-essential libz-dev strace curl git ruby ruby-dev rubygems build-essential libpq-dev postgresql-server-dev-14
RUN gem install --no-document fpm

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | bash -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"
RUN cargo install cargo-pgx

USER ${UID}:${GID}
WORKDIR /home/${USER}

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | bash -s -- -y
ENV PATH="/home/docker/.cargo/bin:${PATH}"
RUN cargo install cargo-pgx
RUN cargo pgx init --pg14=`which pg_config`

RUN git clone --branch v3000.1.1 --depth 1 https://github.com/zombodb/zombodb

WORKDIR /home/${USER}/zombodb
RUN cargo pgx package
RUN ls -alh target/release/**/*

USER root
RUN chown root.root -R /home/docker/zombodb/target/

FROM postgres:14

COPY --from=builder /home/docker/zombodb/target/release/zombodb-pg14/usr/share/postgresql/14/extension/zombodb.control /usr/share/postgresql/14/extension/
COPY --from=builder /home/docker/zombodb/target/release/zombodb-pg14/usr/lib/postgresql/14/lib/zombodb.so /usr/lib/postgresql/14/lib/
COPY --from=builder /home/docker/zombodb/target/release/zombodb-pg14/usr/share/postgresql/14/extension/zombodb--3000.1.1.sql /usr/share/postgresql/14/extension/
COPY --from=builder /home/docker/zombodb/target/release/zombodb-pg14/usr/share/postgresql/14/extension/zombodb--3000.0.9--3000.0.10.sql /usr/share/postgresql/14/extension/
COPY --from=builder /home/docker/zombodb/target/release/zombodb-pg14/usr/share/postgresql/14/extension/zombodb--3000.0.4--3000.0.5.sql /usr/share/postgresql/14/extension/
COPY --from=builder /home/docker/zombodb/target/release/zombodb-pg14/usr/share/postgresql/14/extension/zombodb--3000.0.12--3000.1.0.sql /usr/share/postgresql/14/extension/
COPY --from=builder /home/docker/zombodb/target/release/zombodb-pg14/usr/share/postgresql/14/extension/zombodb--3000.0.11--3000.0.12.sql /usr/share/postgresql/14/extension/
COPY --from=builder /home/docker/zombodb/target/release/zombodb-pg14/usr/share/postgresql/14/extension/zombodb--3000.0.3--3000.0.4.sql /usr/share/postgresql/14/extension/
COPY --from=builder /home/docker/zombodb/target/release/zombodb-pg14/usr/share/postgresql/14/extension/zombodb--3000.0.5--3000.0.6.sql /usr/share/postgresql/14/extension/
COPY --from=builder /home/docker/zombodb/target/release/zombodb-pg14/usr/share/postgresql/14/extension/zombodb--3000.0.10--3000.0.11.sql /usr/share/postgresql/14/extension/
COPY --from=builder /home/docker/zombodb/target/release/zombodb-pg14/usr/share/postgresql/14/extension/zombodb--3000.0.1--3000.0.3.sql /usr/share/postgresql/14/extension/
COPY --from=builder /home/docker/zombodb/target/release/zombodb-pg14/usr/share/postgresql/14/extension/zombodb--3000.0.0-beta1--3000.0.0.sql /usr/share/postgresql/14/extension/
COPY --from=builder /home/docker/zombodb/target/release/zombodb-pg14/usr/share/postgresql/14/extension/zombodb--3000.0.0--3000.0.1.sql /usr/share/postgresql/14/extension/
COPY --from=builder /home/docker/zombodb/target/release/zombodb-pg14/usr/share/postgresql/14/extension/zombodb--3000.0.8--3000.0.9.sql /usr/share/postgresql/14/extension/
COPY --from=builder /home/docker/zombodb/target/release/zombodb-pg14/usr/share/postgresql/14/extension/zombodb--3000.0.6--3000.0.7.sql /usr/share/postgresql/14/extension/
COPY --from=builder /home/docker/zombodb/target/release/zombodb-pg14/usr/share/postgresql/14/extension/zombodb--3000.0.7--3000.0.8.sql /usr/share/postgresql/14/extension/
COPY --from=builder /home/docker/zombodb/target/release/zombodb-pg14/usr/share/postgresql/14/extension/zombodb--3000.1.0--3000.1.1.sql /usr/share/postgresql/14/extension/

ENV PGDATA /var/lib/postgresql/data

VOLUME /var/lib/postgresql/data

ENTRYPOINT ["docker-entrypoint.sh"]

STOPSIGNAL SIGINT

EXPOSE 5432
CMD ["postgres"]


