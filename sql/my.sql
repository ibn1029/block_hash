--
-- BlockHash DB
--

create database if not exists block_hash;

create table if not exists block_hash.hashtag (
    tag_id              bigint unsigned not null auto_increment primary key
    , hashtag            varchar(140) not null
    , title             varchar(200) not null
    , created_at        datetime not null
    , updated_at        datetime not null
);

create table if not exists block_hash.program (
    prog_id             bigint unsigned not null auto_increment primary key
    , prog_date         date not null
    , prog_start        time not null
    , prog_end          time not null
    , title             varchar(200) not null
    , subtitle          varchar(200) not null
    , hashtag           varchar(140)
    , is_archived       int(1) not null default 0
    , is_announced      int(1) not null default 0
    , created_at        datetime not null
);

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

--
-- Analysis
--
create table if not exists block_hash.analyzed_tag (
    id                  bigint unsigned not null auto_increment primary key
    , tag               varchar(140) not null
    , num               int unsigned not null
);

create table if not exists block_hash.analyzed_weekly_moment_job (
    job_id              bigint unsigned not null auto_increment primary key
    , span_from         datetime not null
    , span_to           datetime not null
    , created_at        datetime not null
);

create table if not exists block_hash.analyzed_weekly_moment (
    id                  bigint unsigned not null auto_increment primary key
    , job_id            bigint unsigned not null
    , hashtag           varchar(140) not null
    , count             int unsigned not null
    , count_from        datetime not null
    , count_to          datetime not null
    , foreign key(job_id) references analyzed_weekly_moment_job(job_id)
);
