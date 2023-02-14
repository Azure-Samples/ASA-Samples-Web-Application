CREATE TABLE IF NOT EXISTS todo_list (
   id uuid DEFAULT uuid_generate_v4(),
   name varchar(100),
   description text,
   PRIMARY KEY( id )
);

CREATE TABLE IF NOT EXISTS todo_item (
   id uuid DEFAULT uuid_generate_v4(),
   list_id uuid references todo_list(id),
   name varchar(100),
   description text,
   state varchar(20),
   due_date timestamptz default CURRENT_TIMESTAMP,
   completed_date timestamptz default CURRENT_TIMESTAMP,
   PRIMARY KEY( id )
);