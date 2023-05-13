# JSON Updates: HTTP Server for Tracking New Items in Data Sources

"json-updates" is a Rust-based HTTP server designed to help you monitor new items from various data sources. It can be used in conjunction with no-code/low-code tools (such as [n8n](https://n8n.io/)) to set up notifications about new items appearing on websites or other platforms. By passing items from the source to the server's endpoint, you receive back only the new items, which can then be used for notifications or other purposes.

## Use Case

This server can be extremely useful for setting up real-time notifications about new items on a monitored platform. For instance, you can connect this server with a no-code tool like n8n to fetch items from a website or any data source, pass the items to the server's endpoint, and the server will return only the newly appeared items. You can then send these new items to a messenger, email, or any other notification service to alert users about the new items.

## Getting Started

1. Clone this repository: `git clone https://github.com/pashutk/json-updates.git`
2. Navigate into the project directory: `cd json-updates`
3. Copy `.env.example` to `.env` and update the environment variables.
4. Build the Docker image: `docker build -t json-updates .`
5. Run the Docker container: `docker run -d -p 8000:8000 --env-file .env json-updates`

## API Endpoint

`POST /data`

The endpoint expects a JSON object containing:

- `db_collection`: MongoDB collection name where items will be stored.
- `token`: Access token for API. It should match the `ACCESS_TOKEN` environment variable. If it does not match, the server will return an error.
- `data`: List of items.
- `id_field`: Name of the ID key that should be present in every item.

## Environment Variables

Set these environment variables in your `.env` file:

- `ACCESS_TOKEN`: Security/access token for API access.
- `MONGO_URI`: MongoDB connection string.
- `MONGO_DB_NAME`: Name of the MongoDB database.
- `MONGO_COLLECTIONS_PREFIX`: Prefix for the MongoDB collection name.

## Dependencies

- [actix-web](https://github.com/actix/actix-web): for the web server.
- [serde](https://github.com/serde-rs/serde) and [serde_json](https://github.com/serde-rs/json): for serializing and deserializing JSON data.
- [MongoDB](https://github.com/mongodb/mongo-rust-driver): for communicating with MongoDB.
- [bson](https://github.com/mongodb/bson-rust): for working with BSON data.
- [dotenvy](https://github.com/greyblake/dotenvy-rs): for loading environment variables from `.env` files.
- [chrono](https://github.com/chronotope/chrono): for handling dates and times.

## Contribution

Feel free to open an issue or submit a pull request if you have suggestions or find bugs.

## License

This project is licensed under the [MIT License](LICENSE).
