use actix_web::{Error, FromRequest, HttpRequest};
use actix_web::dev::Payload;
use actix_web::error::ErrorUnauthorized;
use actix_utils::future::{Ready, ok, err};
use std::string::String;
use std::option::Option;
use base64::{Engine as _, engine::general_purpose::URL_SAFE_NO_PAD};
use sha2::Sha256;
use hmac::{Hmac, Mac};
use serde_json::Value;

pub struct AuthorizedUser {
    pub user_id: String,
    pub username: String,
}

impl FromRequest for AuthorizedUser {
    type Error = Error;
    type Future = Ready<Result<Self, Self::Error>>;

    fn from_request(req: &HttpRequest, _: &mut Payload) -> Self::Future {
        let user = get_authorized_user(req);

        if user.is_some() {
            ok(user.unwrap())
        } else {
            err(ErrorUnauthorized("Unauthorized"))
        }
    }
}

fn get_authorized_user(req: &HttpRequest) -> Option<AuthorizedUser> {
    let secret = std::env::var("JWT_SECRET").expect("JWT_SECRET must be provided");

    let token = req.headers()
        .get("Authorization")
        .and_then(|value| value.to_str().ok())
        .take_if(|value| value.starts_with("Bearer "))
        .and_then(|value| Some(value.replace("Bearer ", "")));

    if token.is_none() {
        return None;
    }

    let token = token.unwrap();
    let jwt_parts: Vec<&str> = token.split('.').collect();

    if jwt_parts.len() != 3 {
        return None;
    }

    let _header: Value = serde_json::from_slice(&URL_SAFE_NO_PAD.decode(jwt_parts.get(0).unwrap()).ok()?).ok()?;
    let payload: Value = serde_json::from_slice(&URL_SAFE_NO_PAD.decode(jwt_parts.get(1).unwrap()).ok()?).ok()?;
    let signature = URL_SAFE_NO_PAD.decode(jwt_parts.get(2).unwrap()).ok()?;

    let mut mac = Hmac::<Sha256>::new_from_slice(secret.as_bytes()).ok()?;
    mac.update(format!("{}.{}", jwt_parts.get(0).unwrap(), jwt_parts.get(1).unwrap()).as_bytes());

    if mac.verify_slice(&signature).is_err() {
        return None;
    }

    Some(AuthorizedUser {
        user_id: payload["sub"].as_str()?.to_string(),
        username: payload["http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name"].as_str()?.to_string(),
    })
}

