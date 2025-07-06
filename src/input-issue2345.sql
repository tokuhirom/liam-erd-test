CREATE TABLE foo (
    foo_id int PRIMARY KEY,
    name text
);

CREATE TABLE bar (
    bar_id int NOT NULL,
    name text,
    CONSTRAINT bar_primary_key PRIMARY KEY (bar_id) 
);

CREATE TABLE foo_bar (
    foo_id int REFERENCES foo(foo_id),
    bar_id int REFERENCES bar(bar_id),
    PRIMARY KEY (foo_id, bar_id)
);
