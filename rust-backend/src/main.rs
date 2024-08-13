use actix_web::{get, Responder, HttpResponse, HttpServer, App};

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

    HttpServer::new(|| {
        App::new()
            .service(healthcheck)
    })
    .bind(("127.0.0.1", port))?
    .run()
    .await
}
