# Simple HTTP Server with Item Insertion Endpoint

This repository contains a simple HTTP server written in Rust that provides an endpoint for inserting items into a MongoDB database. The server accepts a POST request with a JSON payload, which includes the items to be inserted and a security token for authentication. If the provided token matches the `ACCESS_TOKEN` environment variable, the server inserts the items into the database and responds with the newly inserted items.

## Usage

To use this project, you will need to have Rust installed on your system. Follow the steps below to set up and run the project:

1. Clone the repository to your local machine.
2. Install Rust and its package manager, Cargo, from the official Rust website: [https://www.rust-lang.org/](https://www.rust-lang.org/).
3. Open a terminal and navigate to the project's root directory.

### Setting up Environment Variables

Before running the project, ensure that the following environment variables are set:

- `ACCESS_TOKEN`: The security/access token used for authentication. The token value provided in the request should match this environment variable.
- `MONGO_URI`: The MongoDB connection string.
- `MONGO_DB_NAME`: The name of the MongoDB database.
- `MONGO_COLLECTIONS_PREFIX`: The prefix that should be present in the `db_collection` key passed in the request body.

To set these variables, create a `.env` file in the project's root directory based on the provided `.env.example` file. Modify the values in the `.env` file accordingly.

### Building and Running the Server

To build and run the server, follow these steps:

1. Build the project by running the following command:

   ```shell
   cargo build --release
   ```

2. Run the server using the following command:

   ```shell
   cargo run --release
   ```

   The server will now be running on `http://localhost:8000`.

### Sending a Request

To send a POST request to the server, include the following JSON keys in the request body:

- `db_collection`: The MongoDB collection name where the items will be stored. It should contain the prefix specified in the `MONGO_COLLECTIONS_PREFIX` environment variable.
- `token`: The security/access token. It should match the `ACCESS_TOKEN` environment variable.
- `data`: A list of items to be inserted.
- `id_field`: The name of the ID key that should be present in every item.

Ensure that the appropriate content type (`Content-Type: application/json`) is set in the request headers.

If the provided token does not match the `ACCESS_TOKEN`, the server will respond with an error.

## Used Crates

This project utilizes the following Rust crates:

- `actix-web`: A web server framework for building HTTP servers.
- `serde` and `serde_json`: Libraries for serializing and deserializing data to and from JSON format.
- `mongodb` and `bson`: Libraries for communicating with a MongoDB database.
- `dotenvy`: A library for loading environment variables from a `.env` file.
- `chrono`: A library for working with dates and times.

Please refer to the official documentation of each crate for more information on their usage.

## License

This project is licensed under the [MIT License](LICENSE). You are free to use, modify, and distribute the code as needed.
