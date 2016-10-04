START TRANSACTION;
SELECT EXISTS(SELECT * FROM users where id = {{USER_ID}}) AS 'exists';
SELECT * FROM todos WHERE user_id = {{USER_ID}};
COMMIT;
