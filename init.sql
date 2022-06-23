CREATE USER IF NOT EXISTS 'hibernate_orm_test' IDENTIFIED BY 'hibernate_orm_test';
GRANT ALL ON *.* TO 'hibernate_orm_test';
FLUSH PRIVILEGES;

set global tidb_enable_window_function = off;
set global tidb_enable_noop_functions = on;
set global tidb_txn_mode = pessimistic;
set global time_zone = UTC;
set global tidb_enable_async_commit = 0;
set global tidb_enable_1pc = 0;

CREATE DATABASE IF NOT EXISTS hibernate_orm_test collate=utf8mb4_general_ci;