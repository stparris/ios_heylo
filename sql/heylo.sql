CREATE TABLE contacts ( 
	id INTEGER PRIMARY KEY NOT NULL,
	record_id INTEGER NOT NULL,
	heylo_id TEXT NOT NULL,
    first_name TEXT,
    last_name TEXT,
    phone_number TEXT NOT NULL,
    avatar TEXT NOT NULL,
    activity_date INTEGER NOT NULL,
    created_date INTEGER NOT NULL
);

CREATE TABLE conversations ( 
	id INTEGER PRIMARY KEY NOT NULL,
	thread TEXT NOT NULL,
	contact_string TEXT NOT NULL,
	read INTEGER NOT NULL,
	image_url TEXT,
	modified_date INTEGER NOT NULL,
    created_date INTEGER NOT NULL
);

CREATE TABLE messages ( 
	id INTEGER PRIMARY KEY NOT NULL,
	conversation_id INTEGER NOT NULL REFERENCES conversations(id) ON DELETE CASCADE,
	contact_id INTEGER NOT NULL REFERENCES contacts(id) ON DELETE CASCADE,
	image_url TEXT,
	message TEXT NOT NULL,
    created_date INTEGER NOT NULL
);

CREATE TABLE users ( 
	id INTEGER PRIMARY KEY NOT NULL,
	heylo_id TEXT,
	auth_token TEXT,
    first_name TEXT,
    last_name TEXT,
    email TEXT,
    phone_number TEXT,
    country TEXT,
    status TEXT, 
    created_date INTEGER NOT NULL
);


