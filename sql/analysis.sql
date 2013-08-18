-- １周間のツイート数
select count(*) from tweet where created_at > date_add(now(), interval -7 day);

-- １周間のハッシュタグ
select hashtags, count(hashtags) as num from tweet where created_at > date_add(now(), interval -7 day) group by hashtags order by num desc ;
-- タグリスト作成

-- 1週間を5分毎に分割し、タグリストで集計した結果をtableに入れる
-- weekly_moment

create table if not exists block_hash.analyzed_weekly_moment (
    id                  bigint unsigned not null auto_increment primary key
    , tag               varchar(140) not null
    , num               int unsigned not null
    , start_at          datetime not null
    , end_at            datetime not null
    , created_at        datetime not null
);
