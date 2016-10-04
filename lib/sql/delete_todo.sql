START TRANSACTION;
SELECT * FROM todos WHERE id = {{ID}} AND user_id = {{USER_ID}};
DELETE FROM todos WHERE id = {{ID}} AND user_id = {{USER_ID}};
COMMIT;
