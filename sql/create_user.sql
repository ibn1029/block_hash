--
-- BlockHash user
--

create user block_hash@localhost identified by 'block_hash00';
grant select, insert, update, delete on block_hash.* to block_hash@localhost;
flush privileges;

create user block_hash@"%" identified by 'block_hash00';
grant select, insert, update, delete on block_hash.* to block_hash@"%";
flush privileges;
