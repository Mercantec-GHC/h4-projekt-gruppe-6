use actix_web::{Error, FromRequest, HttpRequest};
use actix_web::dev::Payload;
use actix_web::error::ErrorUnauthorized;
use std::string::String;
use actix_utils::future::{Ready, ok, err};

pub struct AuthorizedUser {
    user_id: String,
}

impl FromRequest for AuthorizedUser {
    type Error = Error;
    type Future = Ready<Result<Self, Self::Error>>;

    fn from_request(req: &HttpRequest, _: &mut Payload) -> Self::Future {
        if is_authorized(req) {
            ok(Self {
                user_id: "hi".to_string(),
            })
        } else {
            err(ErrorUnauthorized("Unauthorized"))
        }
    }
}

fn is_authorized(req: &HttpRequest) -> bool {
    let token = req.headers()
        .get("Authorization")
        .and_then(|value| value.to_str().ok())
        .take_if(|value| value.starts_with("Bearer "))
        .and_then(|value| Some(value.replace("Bearer ", "")));

    if token.is_none() {
        return false;
    }

    // TODO implement

    true
}

