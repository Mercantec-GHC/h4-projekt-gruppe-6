mod auth;
mod models;

use actix_web::{get, post, delete, Responder, HttpResponse, HttpServer, App, web};
use std::sync::{Mutex, MutexGuard, Arc};
use auth::AuthorizedUser;
use models::Favorite;
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
        Some(favorites) => HttpResponse::Ok().json(favorites),
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
}

#[post("/favorites")]
async fn create_favorite(auth: AuthorizedUser, data: web::Data<AppData>, input: web::Json<CreateFavoriteRequest>) -> impl Responder {
    let db = data.database.lock().unwrap();

    match db.execute(
        "INSERT INTO favorites (user_id, lat, lng) VALUES (:user_id, :lat, :lng)",
        &[(":user_id", &auth.user_id), (":lat", &input.lat.to_string()), (":lng", &input.lng.to_string())]
    ) {
        Ok(_) => HttpResponse::Created(),
        Err(_) => HttpResponse::InternalServerError(),
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
    })
    .bind(("0.0.0.0", port))?
    .run()
    .await
}

