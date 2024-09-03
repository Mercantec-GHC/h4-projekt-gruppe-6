CREATE TABLE reviews (
	id INTEGER PRIMARY KEY AUTOINCREMENT,
	user_id TEXT NOT NULL,
	lat REAL NOT NULL,
	lng REAL NOT NULL,
    place_name TEXT NOT NULL,
    place_description TEXT NOT NULL,
    title TEXT NOT NULL,
    content TEXT NOT NULL,
    rating REAL NOT NULL
);

