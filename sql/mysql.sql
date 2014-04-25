CREATE DATABASE IF NOT EXISTS grammatch;
USE grammatch;

CREATE TABLE IF NOT EXISTS user (
    id                  INTEGER     NOT NULL PRIMARY KEY AUTO_INCREMENT,
    user_name           VARCHAR(20) NOT NULL,
    user_summary        TEXT        NOT NULL,
    twitter_user_id     INTEGER     NOT NULL,
    twitter_screen_name VARCHAR(20) NOT NULL,
    pref_id             INTEGER     NOT NULL DEFAULT 0,
    allow_create_dojo   BOOLEAN     NOT NULL DEFAULT 0,

    last_logged_at      INTEGER     NOT NULL,
    created_at          INTEGER     NOT NULL,
    updated_at          INTEGER     NOT NULL
);
