create database scheduler;

create role scheduler_user
NOSUPERUSER
login password 'Scheduler';

\c scheduler

create table Users_Test
(
	Id serial not null,
	Name varchar not null,
	Password varchar not null
);

create unique index Users_Test_Id_uIndex
	on Users_Test (Id);

create unique index Users_Test_Name_uIndex
	on Users_Test (Name);

alter table Users_Test
	add constraint Users_Test_pk
		primary key (Id);

insert into Users_Test (Name, Password) values ('Kamushek', 'testi4')