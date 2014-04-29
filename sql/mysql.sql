CREATE DATABASE IF NOT EXISTS grammatch;
USE grammatch;

CREATE TABLE IF NOT EXISTS user (
    user_id             INTEGER     NOT NULL PRIMARY KEY AUTO_INCREMENT,
    dojo_id             INTEGER     NOT NULL DEFAULT 0,
    
    user_name           VARCHAR(20) NOT NULL,
    user_summary        TEXT,
    twitter_user_id     BIGINT      NOT NULL,
    twitter_screen_name VARCHAR(20) NOT NULL,
    pref_id             INTEGER     NOT NULL DEFAULT 0,
    allow_create_dojo   BOOLEAN     NOT NULL DEFAULT 0, # role

    last_logged_at      INTEGER     NOT NULL,
    created_at          INTEGER     NOT NULL,
    updated_at          INTEGER     NOT NULL
);

CREATE TABLE IF NOT EXISTS dojo (
    dojo_id             INTEGER     NOT NULL PRIMARY KEY AUTO_INCREMENT,
    user_id             INTEGER     NOT NULL,
    
    dojo_name           VARCHAR(20) NOT NULL,
    dojo_summary        TEXT,
    dojo_member         INTEGER     NOT NULL DEFAULT 0, # member_num? count?
    pref_id             INTEGER     NOT NULL DEFAULT 0,

    created_at          INTEGER     NOT NULL,
    updated_at          INTEGER     NOT NULL
);

CREATE TABLE IF NOT EXISTS user_dojo_map (
    id         INTEGER NOT NULL PRIMARY KEY AUTO_INCREMENT,
    user_id    INTEGER NOT NULL,
    dojo_id    INTEGER NOT NULL,

    status     INTEGER NOT NULL DEFAULT 0,

    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL
);

CREATE TABLE IF NOT EXISTS event (
    event_id INTEGER NOT NULL PRIMARY KEY AUTO_INCREMENT,
    user_id  INTEGER NOT NULL,
    dojo_id  INTEGER NOT NULL,

    event_name    TEXT NOT NULL,
    event_member  INTEGER NOT NULL DEFAULT 0,
    pref_id       INTEGER NOT NULL,
    place         TEXT NOT NULL, 
    reward        TEXT NOT NULL,
    period        INTEGER NOT NULL,
    event_summary TEXT,

    start_at   INTEGER NOT NULL,
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL
);

CREATE TABLE IF NOT EXISTS user_event_map (
    id         INTEGER NOT NULL PRIMARY KEY AUTO_INCREMENT,
    user_id    INTEGER NOT NULL,
    event_id   INTEGER NOT NULL,

    status     INTEGER NOT NULL DEFAULT 0,

    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL
);

CREATE TABLE IF NOT EXISTS event_comment (
    id         INTEGER NOT NULL PRIMARY KEY AUTO_INCREMENT,
    user_id    INTEGER NOT NULL,
    event_id   INTEGER NOT NULL,
    comment    TEXT    NOT NULL,

    deleted    INTEGER NOT NULL DEFAULT 0,
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL
);

CREATE TABLE IF NOT EXISTS dojo_comment (
    id         INTEGER NOT NULL PRIMARY KEY AUTO_INCREMENT,
    user_id    INTEGER NOT NULL,
    dojo_id   INTEGER NOT NULL,
    comment    TEXT    NOT NULL,

    deleted    INTEGER NOT NULL DEFAULT 0,
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL
);
