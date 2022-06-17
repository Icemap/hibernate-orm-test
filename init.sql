SET GLOBAL tidb_enable_noop_functions = 1;

CREATE USER IF NOT EXISTS 'hibernate_orm_test' IDENTIFIED BY 'hibernate_orm_test';
GRANT ALL ON *.* TO 'hibernate_orm_test';
FLUSH PRIVILEGES;

CREATE DATABASE IF NOT EXISTS hibernate_orm_test;