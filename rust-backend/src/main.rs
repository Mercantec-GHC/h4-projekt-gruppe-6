mod auth;
mod models;

use actix_web::{get, Responder, HttpResponse, HttpServer, App, web};
use std::sync::{Mutex, MutexGuard, Arc};
use auth::AuthorizedUser;
use models::Favorite;

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
    })
    .bind(("0.0.0.0", port))?
    .run()
    .await
}

