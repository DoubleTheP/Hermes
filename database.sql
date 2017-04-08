CREATE DATABASE IF NOT EXISTS mousika DEFAULT CHARACTER SET utf8 COLLATE uft8_unicode_ci;

CREATE TABLE IF NOT EXISTS mousika.UserManagement (
    user_id INT AUTO_INCREMENT,
    username VARCHAR(40) NOT NULL PRIMARY KEY,
    email VARCHAR(255) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    salt VARCHAR(255) NOT NULL    
);

CREATE TABLE IF NOT EXISTS mousika.UserProfiles (
    username VARCHAR(40) NOT NULL PRIMARY KEY,
    experience INT NOT NULL,
    songs_played INT NOT NULL,
    songs_correct INT NOT NULL,
    songs_won INT NOT NULL,
    games_won INT NOT NULL
);

CREATE TABLE IF NOT EXISTS mousika.UserToSongs (
    username VARCHAR(40) NOT NULL,
    song_id VARCHAR(255) NOT NULL
);

CREATE TABLE IF NOT EXISTS mousika.LikedSongs (
    song_id VARCHAR(255) NOT NULL PRIMARY KEY,
    artist VARCHAR(255) NOT NULL,
    title VARCHAR(255) NOT NULL,
    album VARCHAR(255) NOT NULL
);

CREATE TABLE IF NOT EXISTS mousika.Records (
    song_id VARCHAR(255) NOT NULL PRIMARY KEY,
    time VARCHAR(16) NOT NULL,
    username VARCHAR(40) NOT NULL,
    attempts INT NOT NULL,
    record_date DATETIME NOT NULL 
);
