START TRANSACTION;
UPDATE todos SET
  user_id = IF({{USER_ID}} != 0, {{USER_ID}}, user_id),
  title = IF({{TITLE}} IS NOT NULL, {{TITLE}}, title),
  body = IF({{BODY}} IS NOT NULL, {{BODY}}, body),
  done = IF({{DONE}} IS NOT NULL, {{DONE}}, done)
WHERE id = {{ID}} AND user_id = {{USER_ID}};
SELECT * FROM todos WHERE id = {{ID}} AND user_id = {{USER_ID}};
COMMIT;
