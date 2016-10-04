START TRANSACTION;
INSERT INTO todos (title, body, done, user_id)
  VALUES ({{TITLE}}, {{BODY}}, {{DONE}}, {{USER_ID}});
SELECT * FROM todos WHERE id = LAST_INSERT_ID();
COMMIT;
