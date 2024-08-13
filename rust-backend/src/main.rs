use actix_web::{get, Responder, HttpResponse, HttpServer, App};

mod embedded {
    use refinery::embed_migrations;
    embed_migrations!("./migrations");
}

#[get("/hc")]
async fn healthcheck() -> impl Responder {
    HttpResponse::Ok().body("OK")
}

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    let port = std::env::var("RUST_BACKEND_PORT")
        .ok()
        .and_then(|port| port.parse::<u16>().ok())
        .unwrap_or(8080);

    let database_path = std::env::var("RUST_BACKEND_DB")
        .unwrap_or("database.sqlite3".to_string());

    println!("Opening database: {}", database_path);

    let mut conn = rusqlite::Connection::open(database_path).unwrap();

    embedded::migrations::runner().run(&mut conn).unwrap();

    println!("Starting web server at port {}", port);

    HttpServer::new(|| {
        App::new()
            .service(healthcheck)
    })
    .bind(("0.0.0.0", port))?
    .run()
    .await
}
