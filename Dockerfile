# FROM rust:1.72 as builder
# RUN rustup target add armv7-unknown-linux-musleabihf
# RUN apt-get update && apt-get -y install binutils-arm-linux-gnueabihf musl-tools
# WORKDIR /usr/src/myapp
# COPY . .
# RUN cargo build --release --target armv7-unknown-linux-musleabihf

# FROM debian:bullseye-slim
# RUN apt-get update && apt-get install -y && rm -rf /var/lib/apt/lists/*
# COPY --from=builder /usr/src/myapp/target/release/json-updates /usr/local/bin/json-updates
# CMD ["json-updates"]

FROM rust:1.72 as builder
RUN rustup target add armv7-unknown-linux-gnueabihf aarch64-unknown-linux-gnu
WORKDIR /app
COPY Cargo.toml Cargo.lock ./
RUN cargo fetch --locked
COPY src ./src
RUN cargo build --release --target=armv7-unknown-linux-gnueabihf
RUN cargo build --release --target=aarch64-unknown-linux-gnu

FROM debian:buster-slim as runtime
WORKDIR /usr/local/bin
ARG TARGETARCH
COPY --from=builder /app/target/armv7-unknown-linux-gnueabihf/release/json-updates ./json-updates-armv7
COPY --from=builder /app/target/aarch64-unknown-linux-gnu/release/json-updates ./json-updates-aarch64
RUN if [ "$TARGETARCH" = "armv7" ]; then mv ./json-updates-armv7 ./json-updates; else mv ./json-updates-aarch64 ./json-updates; fi
RUN chmod +x ./json-updates
ENTRYPOINT ["./json-updates"]
