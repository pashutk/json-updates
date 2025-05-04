FROM rust:1.79.0

WORKDIR /usr/src/json-updates
COPY . .

RUN cargo build --release

WORKDIR /usr/src/json-updates/target/release/
CMD ["./json-updates"]
