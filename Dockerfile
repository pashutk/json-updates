# Use a multi-stage build to compile the Rust application
FROM rust:latest as builder

# Add ARMv7 cross-compilation target
RUN rustup target add armv7-unknown-linux-gnueabihf

# Install necessary cross-compilation tools
RUN apt-get update && apt-get install -y \
    gcc-arm-linux-gnueabihf \
    libc6-dev-armhf-cross

# Create a directory for the application
WORKDIR /app

# Copy the Cargo.toml and Cargo.lock files
COPY Cargo.toml Cargo.lock ./

# Pre-build dependencies
RUN cargo fetch --locked

# Copy the source files
COPY src ./src

# Set environment variables for cross-compilation
ENV CC_armv7_unknown_linux_gnueabihf=arm-linux-gnueabihf-gcc

# Build the application for ARMv7 architecture
RUN cargo build --release --target=armv7-unknown-linux-gnueabihf

# Runtime stage
FROM debian:buster-slim as runtime
WORKDIR /usr/local/bin

# Copy the built binary
COPY --from=builder /app/target/armv7-unknown-linux-gnueabihf/release/json-updates ./json-updates

# Ensure the binary has execution permissions
RUN chmod +x ./json-updates

# Define the entry point
ENTRYPOINT ["./json-updates"]
