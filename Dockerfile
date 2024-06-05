FROM rust:latest

WORKDIR /usr/src/json-updates
COPY . .

RUN cargo build --release

WORKDIR /usr/src/json-updates/target/release/
CMD ["./json-updates"]
