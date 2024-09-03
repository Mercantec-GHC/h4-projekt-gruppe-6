mod auth;
mod models;

use actix_web::{get, post, delete, Responder, HttpResponse, HttpServer, App, web};
use std::sync::{Mutex, MutexGuard, Arc};
use auth::AuthorizedUser;
use models::{Favorite, Review};
use serde::Deserialize;

mod embedded {
    use refinery::embed_migrations;
    embed_migrations!("./migrations");
}

struct AppData {
    database: Arc<Mutex<rusqlite::Connection>>,
}

#[get("/hc")]
async fn healthcheck(data: web::Data<AppData>) -> impl Responder {
    let db = data.database.lock().unwrap();

    match db.pragma_query(None, "integrity_check", |_| Ok(())) {
        Ok(_) => HttpResponse::Ok().body("OK"),
        Err(_) => HttpResponse::InternalServerError().body("Error"),
    }

}

#[get("/authorized")]
async fn authorized(auth: AuthorizedUser) -> impl Responder {
    HttpResponse::Ok().body(format!("Authorized as {} ({})", auth.username, auth.user_id))
}

#[get("/favorites")]
async fn favorites(auth: AuthorizedUser, data: web::Data<AppData>) -> impl Responder {
    let db = data.database.lock().unwrap();

    match get_favorites(db, auth.user_id) {
        Some(favorites) => HttpResponse::Ok().insert_header(("Content-Type", "application/json; charset=utf-8")).json(favorites),
        None => HttpResponse::InternalServerError().finish(),
    }
}

fn get_favorites(db: MutexGuard<'_, rusqlite::Connection>, user_id: String) -> Option<Vec<Favorite>> {
    Some(
        db.prepare("SELECT * FROM favorites WHERE user_id = :user_id").ok()?
            .query_map(&[(":user_id", &user_id)], |row| Favorite::from_row(row))
            .ok()?
            .map(|fav| fav.unwrap())
            .collect()
    )
}

#[derive(Deserialize)]
struct CreateFavoriteRequest {
    lat: f64,
    lng: f64,
    name: String,
    description: String,
}

#[post("/favorites")]
async fn create_favorite(auth: AuthorizedUser, data: web::Data<AppData>, input: web::Json<CreateFavoriteRequest>) -> impl Responder {
    let db = data.database.lock().unwrap();

    match db.execute(
        "INSERT INTO favorites (user_id, lat, lng, name, description) VALUES (:user_id, :lat, :lng, :name, :description)",
        &[
            (":user_id", &auth.user_id),
            (":lat", &input.lat.to_string()),
            (":lng", &input.lng.to_string()),
            (":name", &input.name),
            (":description", &input.description),
        ],
    ) {
        Ok(_) => HttpResponse::Created().json(Favorite {
            id: db.last_insert_rowid(),
            user_id: auth.user_id,
            lat: input.lat,
            lng: input.lng,
            name: input.name.clone(),
            description: input.description.clone(),
        }),
        Err(_) => HttpResponse::InternalServerError().finish(),
    }
}

#[delete("/favorites/{favorite}")]
async fn delete_favorite(auth: AuthorizedUser, data:web::Data<AppData>, path: web::Path<usize>) -> impl Responder {
    let db = data.database.lock().unwrap();
    let favorite_id = path.into_inner();
    let params = &[(":id", &favorite_id.to_string())];

    let result = db.query_row("SELECT * FROM favorites WHERE id = :id LIMIT 1", params, |row| Favorite::from_row(row));

    if result.is_err() {
        return HttpResponse::InternalServerError().finish();
    }

    let favorite = result.unwrap();

    if favorite.user_id != auth.user_id {
        return HttpResponse::Forbidden().body("Cannot remove favorite that you did not create");
    }

    match db.execute("DELETE FROM favorites WHERE id = :id", params) {
        Ok(_) => HttpResponse::NoContent().finish(),
        Err(_) => HttpResponse::InternalServerError().finish(),
    }
}

#[get("/reviews")]
async fn reviews(data: web::Data<AppData>) -> impl Responder {
    let db = data.database.lock().unwrap();

    match get_reviews(db) {
        Some(reviews) => HttpResponse::Ok().insert_header(("Content-Type", "application/json; charset=utf-8")).json(reviews),
        None => HttpResponse::InternalServerError().finish(),
    }
}

fn get_reviews(db: MutexGuard<'_, rusqlite::Connection>) -> Option<Vec<Review>> {
    Some(
        db.prepare("SELECT * FROM reviews").ok()?
            .query_map([], |row| Review::from_row(row))
            .ok()?
            .map(|rev| rev.unwrap())
            .collect()
    )
}

#[derive(Deserialize)]
struct CreateReviewRequest {
    lat: f64,
    lng: f64,
    place_name: String,
    place_description: String,
    title: String,
    content: String,
    rating: i64,
}

#[post("/reviews")]
async fn create_review(auth: AuthorizedUser, data: web::Data<AppData>, input: web::Json<CreateReviewRequest>) -> impl Responder {
    let db = data.database.lock().unwrap();

    match db.execute(
        "INSERT INTO reviews (user_id, lat, lng, place_name, place_description, title, content, rating) VALUES (:user_id, :lat, :lng, :place_name, :place_description, :title, :content, :rating)",
        &[
            (":user_id", &auth.user_id),
            (":lat", &input.lat.to_string()),
            (":lng", &input.lng.to_string()),
            (":place_name", &input.place_name),
            (":place_description", &input.place_description),
            (":title", &input.title),
            (":content", &input.content),
            (":rating", &input.rating.to_string()),
        ],
    ) {
        Ok(_) => HttpResponse::Created().json(Review {
            id: db.last_insert_rowid(),
            user_id: auth.user_id,
            lat: input.lat,
            lng: input.lng,
            place_name: input.place_name.clone(),
            place_description: input.place_description.clone(),
            title: input.title.clone(),
            content: input.content.clone(),
            rating: input.rating.clone(), 
        }),
        Err(_) => HttpResponse::InternalServerError().finish(),
    }
}


#[delete("/reviews/{review}")]
async fn delete_review(auth: AuthorizedUser, data:web::Data<AppData>, path: web::Path<usize>) -> impl Responder {
    let db = data.database.lock().unwrap();
    let review_id = path.into_inner();
    let params = &[(":id", &review_id.to_string())];

    let result = db.query_row("SELECT * FROM reviews WHERE id = :id LIMIT 1", params, |row| Review::from_row(row));

    if result.is_err() {
        return HttpResponse::InternalServerError().finish();
    }

    let review = result.unwrap();

    if review.user_id != auth.user_id {
        return HttpResponse::Forbidden().body("Cannot remove review that you did not create");
    }

    match db.execute("DELETE FROM reviews WHERE id = :id", params) {
        Ok(_) => HttpResponse::NoContent().finish(),
        Err(_) => HttpResponse::InternalServerError().finish(),
    }
}

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    let _ = dotenvy::dotenv();

    let port = std::env::var("RUST_BACKEND_PORT")
        .ok()
        .and_then(|port| port.parse::<u16>().ok())
        .unwrap_or(8080);

    let database_path = std::env::var("RUST_BACKEND_DB")
        .unwrap_or("database.sqlite3".to_string());

    println!("Opening database: {}", database_path);

    let mut conn = rusqlite::Connection::open(database_path.clone()).unwrap();

    embedded::migrations::runner().run(&mut conn).unwrap();

    println!("Starting web server at port {}", port);

    let conn = Arc::new(Mutex::new(rusqlite::Connection::open(database_path).unwrap()));

    HttpServer::new(move || {
        App::new()
            .app_data(web::Data::new(AppData {
                database: conn.clone(),
            }))
            .service(healthcheck)
            .service(authorized)
            .service(favorites)
            .service(create_favorite)
            .service(delete_favorite)
            .service(reviews)
            .service(create_review)
            .service(delete_review)
    })
    .bind(("0.0.0.0", port))?
    .run()
    .await
}

