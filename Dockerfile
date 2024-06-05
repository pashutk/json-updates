# Use a multi-stage build to compile the Rust application
FROM rust:latest as builder

# Add ARM cross-compilation targets
RUN rustup target add armv7-unknown-linux-gnueabihf aarch64-unknown-linux-gnu

# Install necessary cross-compilation tools
RUN apt-get update && apt-get install -y \
    g++-arm-linux-gnueabihf \
    g++-aarch64-linux-gnu \
    libc6-dev-armhf-cross \
    libc6-dev-arm64-cross

# Create a directory for the application
WORKDIR /app

# Copy the Cargo.toml and Cargo.lock files
COPY Cargo.toml Cargo.lock ./

# Pre-build dependencies
RUN cargo fetch --locked

# Copy the source files
COPY src ./src

# Set environment variables for cross-compilation
ENV CC_armv7_unknown_linux_gnueabihf=arm-linux-gnueabihf-gcc \
    CC_aarch64_unknown_linux_gnu=aarch64-linux-gnu-gcc

# Build the application for ARMv7 and ARM64 architectures
RUN cargo build --release --target=armv7-unknown-linux-gnueabihf
RUN cargo build --release --target=aarch64-unknown-linux-gnu

# Runtime stage
FROM debian:buster-slim as runtime
WORKDIR /usr/local/bin

# Ensure the appropriate binary is copied based on the target architecture
ARG TARGETARCH
COPY --from=builder /app/target/armv7-unknown-linux-gnueabihf/release/json-updates ./json-updates-armv7
COPY --from=builder /app/target/aarch64-unknown-linux-gnu/release/json-updates ./json-updates-aarch64

RUN if [ "$TARGETARCH" = "armv7" ]; then mv ./json-updates-armv7 ./json-updates; else mv ./json-updates-aarch64 ./json-updates; fi

# Ensure the binary has execution permissions
RUN chmod +x ./json-updates

# Define the entry point
ENTRYPOINT ["./json-updates"]
