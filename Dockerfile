FROM rust:1.67 as builder
WORKDIR /usr/src/myapp
COPY . .
RUN cargo install --path .

FROM debian:bullseye-slim
RUN apt-get update && apt-get install -y && rm -rf /var/lib/apt/lists/*
COPY --from=builder /usr/src/myapp/target/release/json-updates /usr/local/bin/json-updates
CMD ["json-updates"]
