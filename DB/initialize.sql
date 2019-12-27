create database scheduler;

create role scheduler_user
NOSUPERUSER
login password 'Scheduler';

\c scheduler

alter schema public owner to scheduler_user;

create type grouptype as enum ('Main', 'Secondary');

alter type grouptype owner to scheduler_user;

create type user_role as enum ('Student', 'Teacher', 'Group Monitor', 'Group Editor', 'Moderator', 'Admin');

alter type user_role owner to scheduler_user;

create table departments
(
	id serial not null
		constraint departments_pk
			primary key,
	name varchar not null,
	description text
);

alter table departments owner to scheduler_user;

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

alter table lesson_names owner to scheduler_user;

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

alter table lessons owner to scheduler_user;

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

alter table groups owner to scheduler_user;

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

alter table classrooms owner to scheduler_user;

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

alter table examinations owner to scheduler_user;

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

alter table lesson_names_to_lessons owner to scheduler_user;

create table class_types
(
	id serial not null
		constraint class_types_pk
			primary key,
	name varchar not null
);

alter table class_types owner to scheduler_user;

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

alter table users owner to scheduler_user;

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
	class_time_begin time not null,
	id_class_type integer not null
		constraint classes_class_types_id_fk
			references class_types
				on update cascade on delete restrict,
	day_number integer not null,
	class_time_end time not null
);

alter table classes owner to scheduler_user;

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

alter table tasks owner to scheduler_user;

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

alter table users_to_user_roles owner to scheduler_user;

create function get_classes_by_groups(VARIADIC needed_groups text[]) returns TABLE(start_time time without time zone, end_time time without time zone, class_day_number integer, lesson_name character varying, room character varying, teacher_name character varying, teacher_surname character varying, teacher_patronymic character varying, class_type character varying, group_name character varying)
	language plpgsql
as $$
begin
    return QUERY select class_time_begin  as start_time,
                   class_time_end    as end_time,
                   day_number as class_day_number,
                   lesson_names.name as lesson_name,
                   rooms.name        as room,
                   u.name            as teacher_name,
                   u.surname         as teacher_surname,
                   u.patronymic      as teacher_patronymic,
                   ct.name           as class_type,
                   g.name            as group_name
            from classes cl
                     join lessons l on cl.id_lesson = l.id
                     join lesson_names on l.id_primary_name = lesson_names.id
                     join classrooms rooms on cl.id_classroom = rooms.id
                     join groups g on cl.id_group = g.id
                     join users u on cl.id_teacher = u.id
                     join class_types ct on cl.id_class_type = ct.id
            where g.name = ANY (needed_groups);
end;
$$;

alter function get_classes_by_groups(text[]) owner to scheduler_user;





INSERT INTO public.class_types (name) VALUES ('Lection');
INSERT INTO public.class_types (name) VALUES ('Laba');
INSERT INTO public.class_types (name) VALUES ('Shared');
INSERT INTO public.classrooms (name, description) VALUES ('1158', null);
INSERT INTO public.classrooms (name, description) VALUES ('1215', null);
INSERT INTO public.classrooms (name, description) VALUES ('5141', null);
INSERT INTO public.departments (name, description) VALUES ('БЖД', 'Самая сука важная кафедра');
INSERT INTO public.departments (name, description) VALUES ('ИС', null);
INSERT INTO public.departments (name, description) VALUES ('АПУ', null);
INSERT INTO public.groups (id_department, name, group_type) VALUES (2, '6374', 'Main');
INSERT INTO public.groups (id_department, name, group_type) VALUES (3, '6371', 'Main');
INSERT INTO public.groups (id_department, name, group_type) VALUES (1, '6394', 'Main');
INSERT INTO public.lesson_names (name) VALUES ('Безопасность Жизнидеятельности');
INSERT INTO public.lesson_names (name) VALUES ('Теория разработки программного обеспечения');
INSERT INTO public.lesson_names (name) VALUES ('БЖД');
INSERT INTO public.lesson_names (name) VALUES ('ТПРО');
INSERT INTO public.lessons (id_primary_name, id_department, description) VALUES (1, 1, 'САМАЯСУКАВАЖНАЯПАРАВМИРЕ');
INSERT INTO public.lessons (id_primary_name, id_department, description) VALUES (2, 2, '');
INSERT INTO public.lesson_names_to_lessons (id_lesson, id_lesson_name) VALUES (1, 1);
INSERT INTO public.lesson_names_to_lessons (id_lesson, id_lesson_name) VALUES (1, 3);
INSERT INTO public.lesson_names_to_lessons (id_lesson, id_lesson_name) VALUES (2, 2);
INSERT INTO public.lesson_names_to_lessons (id_lesson, id_lesson_name) VALUES (2, 4);
INSERT INTO public.users (name, surname, patronymic, phone, email, autorization_shit) VALUES ('Овдиенко', 'Х', 'З', null, null, null);
INSERT INTO public.users (name, surname, patronymic, phone, email, autorization_shit) VALUES ('Имя_препода', 'Фамилия_препода', 'Отчество_препода', null, null, null);
INSERT INTO public.users_to_user_roles (id_user, id_group, id_department, role) VALUES (1, null, 1, 'Teacher');
INSERT INTO public.users_to_user_roles (id_user, id_group, id_department, role) VALUES (2, null, 1, 'Teacher');
INSERT INTO public.classes (id_lesson, id_classroom, id_group, id_teacher, class_time_begin, id_class_type, day_number, class_time_end) VALUES (1, 1, 1, 1, '11:40:00', 2, 1, '13:15:00');
INSERT INTO public.classes (id_lesson, id_classroom, id_group, id_teacher, class_time_begin, id_class_type, day_number, class_time_end) VALUES (2, 2, 1, 2, '07:40:00', 1, 3, '09:15:00');
INSERT INTO public.classes (id_lesson, id_classroom, id_group, id_teacher, class_time_begin, id_class_type, day_number, class_time_end) VALUES (1, 3, 1, 1, '13:20:00', 2, 1, '15:15:00');
INSERT INTO public.classes (id_lesson, id_classroom, id_group, id_teacher, class_time_begin, id_class_type, day_number, class_time_end) VALUES (1, 3, 2, 1, '14:20:00', 2, 1, '15:15:00');
INSERT INTO public.classes (id_lesson, id_classroom, id_group, id_teacher, class_time_begin, id_class_type, day_number, class_time_end) VALUES (1, 3, 2, 1, '16:20:00', 2, 1, '19:15:00');
INSERT INTO public.classes (id_lesson, id_classroom, id_group, id_teacher, class_time_begin, id_class_type, day_number, class_time_end) VALUES (1, 3, 3, 1, '00:01:00', 2, 1, '23:59:00');
INSERT INTO public.classes (id_lesson, id_classroom, id_group, id_teacher, class_time_begin, id_class_type, day_number, class_time_end) VALUES (1, 3, 3, 1, '00:01:00', 2, 1, '23:59:00');