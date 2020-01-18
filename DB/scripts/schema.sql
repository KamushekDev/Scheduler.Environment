\c scheduler

alter schema public owner to scheduler_user;

create type access_modifier as enum ('Public', 'Group', 'Inherited');

alter type access_modifier owner to scheduler_user;

create type user_role as enum ('Student', 'Editor', 'Moderator', 'Headman');

alter type user_role owner to scheduler_user;

create table users
(
	id serial not null
		constraint users_pk
			primary key,
	name varchar(30) not null,
	surname varchar(30) not null,
	patronymic varchar(30),
	phone varchar(12),
	email varchar(50)
);

alter table users owner to scheduler_user;

create unique index users_email_uindex
	on users (email);

create unique index users_id_uindex
	on users (id);

create table credentials
(
	user_id integer not null
		constraint credentials_users_id_fk
			references users
				on update cascade on delete restrict,
	provider varchar(20) not null,
	access_token varchar not null,
	date_expired timestamp not null,
	constraint credentials_pk
		primary key (user_id, provider)
);

alter table credentials owner to scheduler_user;

create table lessons
(
	name varchar(40) not null
		constraint lessons_pk
			primary key,
	description text
);

alter table lessons owner to scheduler_user;

create unique index lessons_name_uindex
	on lessons (name);

create table rooms
(
	name varchar(30) not null
		constraint rooms_pk
			primary key,
	description text
);

alter table rooms owner to scheduler_user;

create unique index rooms_name_uindex
	on rooms (name);

create table groups
(
	id serial not null
		constraint groups_pk
			primary key,
	name varchar(30) not null,
	access access_modifier default 'Group'::access_modifier not null,
	invite_tag varchar,
	description text
);

alter table groups owner to scheduler_user;

create unique index groups_id_uindex
	on groups (id);

create unique index groups_invite_tag_uindex
	on groups (invite_tag);

create table users_to_groups
(
	user_id integer not null
		constraint users_to_groups_users_id_fk
			references users
				on update cascade on delete restrict,
	group_id integer not null
		constraint users_to_groups_groups_id_fk
			references groups
				on update cascade on delete restrict,
	role user_role default 'Student'::user_role not null,
	date_entry timestamp not null,
	date_exit timestamp,
	constraint users_to_groups_pk
		primary key (user_id, group_id)
);

alter table users_to_groups owner to scheduler_user;

create table exams
(
	id serial not null
		constraint exams_pk
			primary key,
	name varchar(30) not null,
	datetime timestamp,
	group_id integer not null
		constraint exams_groups_id_fk
			references groups
				on update cascade on delete restrict,
	lesson_name varchar(40) not null
		constraint exams_lessons_name_fk
			references lessons
				on update cascade on delete restrict,
	teacher_id integer not null
		constraint exams_users_id_fk
			references users
				on update cascade on delete restrict,
	access access_modifier default 'Inherited'::access_modifier not null
);

alter table exams owner to scheduler_user;

create unique index exams_id_uindex
	on exams (id);

create table class_types
(
	name varchar(30) not null
		constraint class_types_pk
			primary key,
	description text
);

alter table class_types owner to scheduler_user;

create unique index class_types_name_uindex
	on class_types (name);

create table terms
(
	id serial not null
		constraint terms_pk
			primary key,
	start_date date not null,
	end_date date not null,
	description text
);

alter table terms owner to scheduler_user;

create unique index terms_id_uindex
	on terms (id);

create unique index terms_start_date_end_date_uindex
	on terms (start_date, end_date);

create table classes
(
	lesson_name varchar(40) not null
		constraint classes_lessons_name_fk
			references lessons
				on update cascade on delete restrict,
	room_name varchar(30) not null
		constraint classes_rooms_name_fk
			references rooms
				on update cascade on delete restrict,
	group_id integer not null
		constraint classes_groups_id_fk
			references groups
				on update cascade on delete restrict,
	time time not null,
	access access_modifier default 'Inherited'::access_modifier,
	id serial not null
		constraint classes_pk
			primary key,
	class_type_name varchar(30) not null
		constraint classes_class_types_name_fk
			references class_types
				on update cascade on delete restrict,
	terms_id integer not null
		constraint classes_terms_id_fk
			references terms
				on update cascade on delete restrict,
	teacher_id integer
		constraint classes_users_id_fk
			references users
				on update cascade on delete restrict,
	duration integer default 95 not null
);

alter table classes owner to scheduler_user;

create unique index classes_id_uindex
	on classes (id);

create table tasks
(
	id serial not null
		constraint tasks_pk
			primary key,
	end_class_id integer
		constraint tasks_classes_id_fk_2
			references classes
				on update cascade on delete restrict,
	date_begin date not null,
	date_end date,
	name varchar(30) not null,
	description text,
	access access_modifier default 'Inherited'::access_modifier not null
);

alter table tasks owner to scheduler_user;

create unique index tasks_id_uindex
	on tasks (id);

