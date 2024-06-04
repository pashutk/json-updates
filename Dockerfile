FROM rust:1.72 as builder
RUN rustup target add armv7-unknown-linux-musleabihf
RUN apt-get update && apt-get -y install binutils-arm-linux-gnueabihf
WORKDIR /usr/src/myapp
COPY . .
RUN cargo build --release --target armv7-unknown-linux-musleabihf

FROM debian:bullseye-slim
RUN apt-get update && apt-get install -y && rm -rf /var/lib/apt/lists/*
COPY --from=builder /usr/src/myapp/target/release/json-updates /usr/local/bin/json-updates
CMD ["json-updates"]
