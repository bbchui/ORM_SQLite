DROP TABLE IF EXISTS users;

CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  fname TEXT NOT NULL,
  lname TEXT NOT NULL
  -- follows INTEGER NOT NULL,
  -- FOREIGN KEY (follows) REFERENCES question_follows(id)
);

INSERT INTO
  users (fname, lname)
VALUES
  ('Brandon', 'Chui'),
  ('Vu', 'Pham');





DROP TABLE IF EXISTS questions;
CREATE TABLE questions (
  id INTEGER PRIMARY KEY,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  user_id INTEGER NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users(id)

);

INSERT INTO
  questions (title, body, user_id)
VALUES
  ('question1', 'what?', (SELECT id FROM users WHERE fname = 'Brandon'));








DROP TABLE IF EXISTS question_follows;
CREATE TABLE question_follows (
  id INTEGER PRIMARY KEY,
  follower INTEGER NOT NULL,
  question_id INTEGER NOT NULL,
  FOREIGN KEY (follower) REFERENCES users(id),
  FOREIGN KEY (question_id) REFERENCES questions(id)
);

INSERT INTO
  question_follows (follower, question_id)
VALUES
  ((SELECT id FROM users), (SELECT id FROM questions));











DROP TABLE IF EXISTS replies;
CREATE TABLE replies (
  id INTEGER PRIMARY KEY,
  question_id INTEGER NOT NULL,
  parent_id INTEGER,
  response TEXT NOT NULL,
  user_id INTEGER NOT NULL,

  FOREIGN KEY (question_id) REFERENCES questions(id),
  FOREIGN KEY (parent_id) REFERENCES replies(id),
  FOREIGN KEY (user_id) REFERENCES users(id)
);

INSERT INTO
  replies (question_id, parent_id, response, user_id)
VALUES
  ((SELECT id FROM questions), (SELECT id FROM replies), "Do this", (SELECT id FROM users)),
  ((SELECT id FROM questions), 1, "Do that", (SELECT id FROM users));













DROP TABLE IF EXISTS question_likes;
CREATE TABLE question_likes (
  id INTEGER PRIMARY KEY,
  user_id INTEGER NOT NULL,
  question_id INTEGER NOT NULL,

  FOREIGN KEY (user_id) REFERENCES users(id)
  FOREIGN KEY (question_id) REFERENCES questions(id)
);

INSERT INTO
  question_likes (user_id, question_id)
VALUES
  ((SELECT id FROM users), (SELECT id FROM questions))
  ;
