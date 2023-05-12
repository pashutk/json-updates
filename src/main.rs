use actix_web::{web, App, HttpResponse, HttpServer, Responder};
use bson::{doc, Document};
use mongodb::{
    error::{BulkWriteError, BulkWriteFailure},
    options::ClientOptions,
    Client,
};
use serde::{Deserialize, Serialize};
use serde_json::json;
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
    let client = Client::with_options(client_options).unwrap();

    let collection = client
        .database("json-updates")
        .collection::<Document>(&data.db_collection);

    let now = chrono::Utc::now();

    let docs: Vec<Document> = data
        .data
        .clone()
        .into_iter()
        .map(|obj| {
            json!({
                "_id": obj.get(&data.id_field).unwrap(),
                "data": obj,
                "createdAt": bson::DateTime::from_chrono(now),
            })
        })
        .map(|value| bson::to_document(&value).unwrap())
        .collect();
    let result = collection.insert_many(docs, None).await;

    fn get_not_inserted_indexes(
        error: mongodb::error::Error,
    ) -> Result<Vec<usize>, mongodb::error::Error> {
        match *error.clone().kind {
            mongodb::error::ErrorKind::BulkWrite(BulkWriteFailure {
                write_errors: Some(errors),
                ..
            }) => {
                if errors
                    .clone()
                    .into_iter()
                    .all(|BulkWriteError { code, .. }| code == 11000)
                {
                    Ok(errors
                        .into_iter()
                        .map(|BulkWriteError { index, .. }| index)
                        .collect())
                } else {
                    Err(error)
                }
            }
            _ => Err(error),
        }
    }

    // let x = result
    //     .map(|result| result.inserted_ids)
    //     .or_else(|error| get_not_inserted_indexes(error));

    match result {
        Ok(insert_result) => HttpResponse::Ok().json(insert_result.inserted_ids),
        Err(error) => match get_not_inserted_indexes(error) {
            Ok(_not_inserted_indexes) => todo!(),
            Err(error) => {
                eprintln!("Mongo insertMany error, {}", error);
                HttpResponse::InternalServerError().finish()
            }
        },
    }
    // HttpResponse::Ok().json(serde_json::json!({
    //     "test": "ok"
    // }))
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
