select pg_terminate_backend(pid) from pg_stat_activity where datname = 'mobiles' and pid <> pg_backend_pid();
drop database if exists mobiles;
create database mobiles;
