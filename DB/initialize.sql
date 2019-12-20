create database scheduler;

create role scheduler_user
NOSUPERUSER
login password 'Scheduler';

\c scheduler

create schema public;

comment on schema public is 'standard public schema';

alter schema public owner to postgres;

create type grouptype as enum ('Main', 'Secondary');

alter type grouptype owner to postgres;

create table departments
(
	id serial not null
		constraint departments_pk
			primary key,
	name varchar not null,
	description text
);

alter table departments owner to postgres;

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

alter table lesson_names owner to postgres;

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

alter table lessons owner to postgres;

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

alter table groups owner to postgres;

create unique index groups_id_uindex
	on groups (id);

create unique index groups_name_uindex
	on groups (name);

create table students
(
	id serial not null
		constraint students_pk
			primary key,
	name varchar not null,
	surname varchar not null,
	patronymic varchar,
	phone varchar,
	email varchar
);

alter table students owner to postgres;

create unique index students_id_uindex
	on students (id);

create unique index students_phone_uindex
	on students (phone);

create unique index students_email_uindex
	on students (email);

create table students_to_groups
(
	id serial not null
		constraint students_to_groups_pk
			primary key,
	id_group integer not null
		constraint students_to_groups_groups_id_fk
			references groups
				on update cascade on delete restrict,
	id_student integer not null
		constraint students_to_groups_students_id_fk
			references students
				on update cascade on delete restrict,
	enter_date date not null,
	exit_date date not null
);

alter table students_to_groups owner to postgres;

create unique index students_to_groups_id_uindex
	on students_to_groups (id);

create table teachers
(
	id serial not null
		constraint teachers_pk
			primary key,
	id_department integer not null
		constraint teachers_departments_id_fk
			references departments
				on update cascade on delete restrict,
	name varchar not null,
	surname varchar not null,
	patronymic varchar,
	phone varchar,
	email varchar
);

alter table teachers owner to postgres;

create unique index teachers_id_uindex
	on teachers (id);

create table classrooms
(
	id serial not null
		constraint classrooms_pk
			primary key,
	name varchar(10) not null,
	description text
);

alter table classrooms owner to postgres;

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

alter table examinations owner to postgres;

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

alter table lesson_names_to_lessons owner to postgres;

create table class_types
(
	id serial not null
		constraint class_types_pk
			primary key,
	name varchar not null
);

alter table class_types owner to postgres;

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
		constraint classes_teachers_id_fk
			references teachers
				on update cascade on delete restrict,
	class_time time not null,
	id_class_type integer not null
		constraint classes_class_types_id_fk
			references class_types
				on update cascade on delete restrict
);

alter table classes owner to postgres;

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

alter table tasks owner to postgres;

create unique index tasks_id_uindex
	on tasks (id);

create unique index class_types_id_uindex
	on class_types (id);

create unique index class_types_name_uindex
	on class_types (name);

