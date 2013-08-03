--
-- BlockHash DB
--

create database if not exists block_hash;

/*
drop table if exists block_hash.program;
create table block_hash.program (
    prog_id             int(4) unsigned not null auto_increment primary key
    , prog_name         varchar(200) not null
    , hash_tags         varchar(100) not null
    , note              text
    , prog_week_day     int(1) unsigned -- 0-6
    , prog_day          date
    , prog_start_at     time not null
    , prog_end_at       time not null
    , created_at        datetime not null
    , updated_at        datetime
    , created_by        varchar(100) not null
    , updated_by        varchar(100)
);

drop table if exists block_hash.archive;
create table if not exists block_hash.archive (
    archive_id          int(8) unsigned not null auto_increment primary key
    , prog_id           int(4) not null
    , url               varchar(200) not null -- /${hash_tags}/${date}
    , started_at        datetime not null
    , stopped_at        datetime not null
    , foreign key(prog_id) references program(prog_id)
);
*/

-- drop table if exists block_hash.tweet;
-- drop table block_hash.tweet;
create table if not exists block_hash.tweet (
    id                  bigint unsigned not null auto_increment primary key
    , tweet_id          bigint unsigned not null unique
    , hashtags          varchar(140) not null
    , url               varchar(140)
    , media_type        varchar(20)
    , media_data        text
    , created_at        datetime not null
    , tweet_json        text not null
    , is_valid          int(1) default 0
);
create index tweet_hashtags on tweet (hashtags);
create index tweet_created_at on tweet (created_at);

create table if not exists block_hash.analyzed_tag (
    id                  bigint unsigned not null auto_increment primary key
    , tag               varchar(140) not null
    , num               int unsigned not null
);
