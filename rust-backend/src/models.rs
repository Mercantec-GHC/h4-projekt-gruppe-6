use std::string::String;
use serde::Serialize;
use rusqlite::{Row, Error};

#[derive(Serialize)]
pub struct Favorite {
    pub id: i64,
    pub user_id: String,
    pub lat: f64,
    pub lng: f64,
    pub name: String,
    pub description: String,
}

impl Favorite {
    pub fn from_row(row: &Row) -> Result<Self, Error> {
        Ok(Favorite {
            id: row.get("id")?,
            user_id: row.get("user_id")?,
            lat: row.get("lat")?,
            lng: row.get("lng")?,
            name: row.get("name")?,
            description: row.get("description")?,
        })
    }
}

