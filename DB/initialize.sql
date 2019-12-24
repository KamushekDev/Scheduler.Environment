create database scheduler;

create role scheduler_user
NOSUPERUSER
login password 'Scheduler';

\c scheduler

create type grouptype as enum ('Main', 'Secondary');

create type user_role as enum ('Student', 'Teacher', 'Group Monitor', 'Group Editor', 'Moderator', 'Admin');

create table departments
(
	id serial not null
		constraint departments_pk
			primary key,
	name varchar not null,
	description text
);

create unique index departments_id_uindex
	on departments (id);

create unique index departments_name_uindex
	on departments (name);

create table lesson_names
(
	id serial not null
		constraint lesson_names_pk
			primary key,
	name varchar not null
);

create unique index lesson_names_id_uindex
	on lesson_names (id);

create unique index lesson_names_name_uindex
	on lesson_names (name);

create table lessons
(
	id serial not null
		constraint lessons_pk
			primary key,
	id_primary_name integer not null
		constraint lessons_lesson_names_id_fk
			references lesson_names
				on update cascade on delete restrict,
	id_department integer not null
		constraint lessons_departments_id_fk
			references departments
				on update cascade on delete restrict,
	description text
);

create unique index lessons_id_uindex
	on lessons (id);

create table groups
(
	id serial not null
		constraint groups_pk
			primary key,
	id_department integer not null
		constraint groups_departments_id_fk
			references departments
				on update cascade on delete restrict,
	name varchar not null,
	group_type grouptype default 'Main'::grouptype not null
);

create unique index groups_id_uindex
	on groups (id);

create unique index groups_name_uindex
	on groups (name);

create table classrooms
(
	id serial not null
		constraint classrooms_pk
			primary key,
	name varchar(10) not null,
	description text
);

create unique index classrooms_id_uindex
	on classrooms (id);

create table examinations
(
	id serial not null
		constraint examinations_pk
			primary key,
	id_group integer not null
		constraint examinations_groups_id_fk
			references groups
				on update cascade on delete restrict,
	id_lesson integer not null
		constraint examinations_lessons_id_fk
			references lessons
				on update cascade on delete restrict,
	datetime timestamp not null,
	description text
);

create unique index examinations_id_uindex
	on examinations (id);

create table lesson_names_to_lessons
(
	id_lesson integer not null
		constraint lesson_names_to_lessons_lessons_id_fk
			references lessons
				on update cascade on delete restrict,
	id_lesson_name integer not null
		constraint lesson_names_to_lessons_lesson_names_id_fk
			references lesson_names
				on update cascade on delete restrict,
	constraint lesson_names_to_lessons_pk
		primary key (id_lesson, id_lesson_name)
);

create table class_types
(
	id serial not null
		constraint class_types_pk
			primary key,
	name varchar not null
);

create unique index class_types_id_uindex
	on class_types (id);

create unique index class_types_name_uindex
	on class_types (name);

create table users
(
	id serial not null
		constraint users_pk
			primary key,
	name varchar not null,
	surname varchar not null,
	patronymic varchar,
	phone varchar,
	email varchar,
	autorization_shit text
);

create table classes
(
	id serial not null
		constraint classes_pk
			primary key,
	id_lesson integer not null
		constraint classes_lessons_id_fk
			references lessons
				on update cascade on delete restrict,
	id_classroom integer not null
		constraint classes_classrooms_id_fk
			references classrooms
				on update cascade on delete restrict,
	id_group integer not null
		constraint classes_groups_id_fk
			references groups
				on update cascade on delete restrict,
	id_teacher integer not null
		constraint classes_users_id_fk
			references users
				on update cascade on delete restrict,
	class_time time not null,
	id_class_type integer not null
		constraint classes_class_types_id_fk
			references class_types
				on update cascade on delete restrict
);

create unique index classes_id_uindex
	on classes (id);

create table tasks
(
	id serial not null
		constraint tasks_pk
			primary key,
	id_lesson integer not null
		constraint tasks_lessons_id_fk
			references lessons
				on update cascade on delete restrict,
	id_group integer not null
		constraint tasks_groups_id_fk
			references groups
				on update cascade on delete restrict,
	id_class_receive integer not null
		constraint tasks_classes_id_fk
			references classes
				on update cascade on delete restrict,
	date_receive date not null,
	id_class_done integer
		constraint tasks_classes_id_fk_2
			references classes
				on update cascade on delete restrict,
	date_done date,
	description text
);

create unique index tasks_id_uindex
	on tasks (id);

create table users_to_user_roles
(
	id_user integer not null
		constraint users_to_user_roles_users_id_fk
			references users
				on update cascade on delete restrict,
	id_group integer
		constraint users_to_user_roles_groups_id_fk
			references groups
				on update cascade on delete restrict,
	id_department integer
		constraint users_to_user_roles_departments_id_fk
			references departments
				on update cascade on delete restrict,
	role user_role not null
);