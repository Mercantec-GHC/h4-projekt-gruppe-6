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

#[derive(Serialize)]
pub struct Review {
    pub id: i64,
    pub user_id: String,
    pub lat: f64,
    pub lng: f64,
    pub place_name: String,
    pub place_description: String,
    pub title: String,
    pub content: String,
    pub rating: i64,
}

impl Review {
    pub fn from_row(row: &Row) -> Result<Self, Error> {
        Ok(Review { 
            id: row.get("id")?,
            user_id: row.get("user_id")?,
            lat: row.get("lat")?,
            lng: row.get("lng")?,
            place_name: row.get("place_name")?,
            place_description: row.get("place_description")?,
            title: row.get("title")?,
            content: row.get("content")?,
            rating: row.get("rating")?,
        })
    }
}

#[derive(Serialize)]
pub struct Image {
    pub id: i64,
    pub user_id: String,
    pub image_url: String,
}

impl Image {
    pub fn from_row(row: &Row) -> Resul<Self, Error> {
        Ok(Image {
            id: row.get("id")?,
            user_id: row.get("user_id")?,
            image_url: row.get("image_url")?,
        })
    }
}

