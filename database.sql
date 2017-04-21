CREATE DATABASE IF NOT EXISTS mousika DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci;

CREATE TABLE IF NOT EXISTS mousika.UserManagement (
    username VARCHAR(40) NOT NULL PRIMARY KEY,
    email VARCHAR(255) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    salt VARCHAR(255) NOT NULL    
);

CREATE TABLE IF NOT EXISTS mousika.UserProfiles (
    username VARCHAR(40) NOT NULL PRIMARY KEY,
    experience INT NOT NULL DEFAULT 0,
    songs_played INT NOT NULL DEFAULT 0,
    songs_correct INT NOT NULL DEFAULT 0,
    songs_won INT NOT NULL DEFAULT 0,
    games_won INT NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS mousika.UserToSong (
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
    username VARCHAR(40) NOT NULL,
    best_time INT NOT NULL DEFAULT 0 COMMENT 'time in milliseconds',
    record_date INT NOT NULL DEFAULT 0,
    attempts INT NOT NULL DEFAULT 0
);
