FROM rust:1.72 as builder
RUN rustup target add aarch64-unknown-linux-gnu
RUN apt-get update && apt-get -y install binutils-arm-linux-gnueabihf gcc-aarch64-linux-gnu
WORKDIR /usr/src/myapp
COPY . .
RUN cargo install --target aarch64-unknown-linux-gnu --path .

FROM debian:bullseye-slim
RUN apt-get update && apt-get install -y && rm -rf /var/lib/apt/lists/*
COPY --from=builder /usr/src/myapp/target/release/json-updates /usr/local/bin/json-updates
CMD ["json-updates"]
