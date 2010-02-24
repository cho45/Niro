CREATE TABLE entry (
	id INTEGER PRIMARY KEY,
	title TEXT NOT NULL,
	body TEXT NOT NULL,
	created_at DATETIME NOT NULL,
	modified_at DATETIME NOT NULL
);
CREATE INDEX index_created_at ON entry (created_at);

CREATE TABLE tag (
	id INTEGER PRIMARY KEY,
	name VARCHAR(255),
	entry_id INTEGER
);
CREATE INDEX index_entry ON tag (entry_id);
CREATE INDEX index_name  ON tag (name);
CREATE UNIQUE INDEX index_entry_name  ON tag (entry_id, name);

