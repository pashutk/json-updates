use actix_web::{web, App, HttpResponse, HttpServer, Responder};
use bson::doc;
use mongodb::{options::ClientOptions, Client};
use serde::{Deserialize, Serialize};
use std::{collections::HashMap, env};

#[derive(Serialize, Deserialize)]
struct RequestData {
    db_collection: String,
    token: String,
    data: Vec<HashMap<String, serde_json::Value>>,
    id_field: String,
}

async fn process_data(data: web::Json<RequestData>) -> impl Responder {
    let env_access_token = env::var("ACCESS_TOKEN").unwrap();
    if env_access_token != data.token {
        return HttpResponse::Unauthorized().finish();
    }

    let _ids_to_insert: Vec<&str> = data
        .data
        .iter()
        .filter_map(|obj| {
            obj.get(data.id_field.as_str()).and_then(|val| match val {
                serde_json::Value::String(id) => Some(id.as_str()),
                _ => None,
            })
        })
        .collect();

    let env_mongo_uri = env::var("MONGO_URI").unwrap();
    let client_options = ClientOptions::parse(env_mongo_uri).await.unwrap();
    let _client = Client::with_options(client_options).unwrap();

    // let collection = client
    //     .database("json-updates")
    //     .collection(&data.db_collection);

    // // Convert data to Bson document
    // let data_string = serde_json::to_string(&data.data).unwrap_or_default();
    // let bson_data = match bson::Document::from_json(&data_string) {
    //     Ok(bson) => bson,
    //     Err(_) => doc! {},
    // };

    // // Insert data into the collection (here, you would normally use the token for authentication)
    // let result = collection.insert_one(bson_data, None).await;

    // // Return the result
    // match result {
    //     Ok(insert_result) => HttpResponse::Ok().json(insert_result.inserted_id.to_string()),
    //     Err(_) => HttpResponse::InternalServerError().finish(),
    // }
    HttpResponse::Ok().json(serde_json::json!({
        "test": "ok"
    }))
}

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    dotenvy::dotenv().unwrap();
    env::var("ACCESS_TOKEN").expect("Set ACCESS_TOKEN env var!");
    env::var("MONGO_URI").expect("Set MONGO_URI env var!");

    HttpServer::new(|| {
        App::new().service(web::resource("/data").route(web::post().to(process_data)))
    })
    .bind("127.0.0.1:8000")?
    .run()
    .await
}
