

-- create database beauty;

drop table if exists client cascade;
drop table if exists master cascade;
drop table if exists job cascade;
drop table if exists job_history cascade;
drop table if exists service cascade;
drop table if exists service_master cascade;
drop table if exists record cascade;
drop table if exists service_record cascade;


drop domain if exists domain_phone_number;


-- свой тип данных для номера телефона соответствие шаблону 8(ХХХ)ХХХ-ХХХХ
create domain domain_phone_number as varchar(20)
check
(
        value similar to '8\(\d{3}\)\d{3}\-\d{4}' or value is null
);


create table client
(
    id_client serial primary key,
    last_name varchar(44) not null,
    first_name varchar(44) not null,
    middle_name varchar(44) not null,
    phone domain_phone_number not null
);


create table master
(
    id_master serial primary key,
    last_name varchar(44) not null,
    first_name varchar(44) not null,
    middle_name varchar(44) not null,
    address varchar(255) not null,
    birth date not null
);


create table job
(
    id_job serial primary key,
    title varchar(44) not null
);



create table job_history
(
    id_master int not null,
	date_start date not null,
	id_job int not null,
	salary money not null, 
	date_end date,
	constraint job_history_pkey primary key (id_master, date_start),
	constraint job_history_id_master_fkey foreign key (id_master) references master (id_master) on update cascade on delete cascade,
	constraint job_history_id_job_fkey foreign key (id_job) references job (id_job) on update cascade on delete cascade
);



create table service
(
    id_service serial primary key,
    name varchar(44) not null,
	price numeric not null, 
	duration numeric not null 

);


create table service_master
(
    id_master int not null,
	id_service int not null,
	constraint service_master_pkey primary key (id_master, id_service),
	constraint service_master_id_master_fkey foreign key (id_master) references master (id_master) on update cascade on delete cascade,
	constraint service_master_id_service_fkey foreign key (id_service) references service (id_service) on update cascade on delete cascade
);




create table record
(
    id_record serial primary key,
	id_master int not null,
	id_client int not null,
	data_start timestamp not null,
	data_end timestamp,
	constraint record_id_master_fkey foreign key (id_master) references master (id_master) on update cascade on delete cascade,
	constraint record_id_client_fkey foreign key (id_client) references client (id_client) on update cascade on delete cascade
);



create table service_record
(
    id_record int not null,
	id_service int not null,
	active boolean default false not null,
	constraint service_record_pkey primary key (id_record, id_service),
	constraint service_record_id_record_fkey foreign key (id_record) references record (id_record) on update cascade on delete cascade,
	constraint service_record_id_service_fkey foreign key (id_service) references service (id_service) on update cascade on delete cascade
);




insert into client(last_name, first_name, middle_name, phone) values
('Иванов','Иван', 'Петрович', '8(888)888-7777'),
('Сидоров','Сидр', 'Иванович', '8(888)888-4444'),
('Кошкина','Оля', 'Никифоровна', '8(888)888-9999'),
('Собакина','Вера', 'Максимовна', '8(888)888-2222'),
('Ложкина','Полина', 'Викторовна', '8(888)888-5555');


insert into master(last_name, first_name, middle_name, address, birth) values
('Иванова','Галина', 'Петровна', 'г. Москва ул. Превая 55 - 77', '04.07.1997'),
('Сидорова','Рита', 'Ивановна', 'г. Москва ул. Вторая 4 - 9', '14.05.1977'),
('Лисицина','Оля', 'Никифоровна', 'г. Москва ул. Ленина 14', '14.09.1998'),
('Курочкина','Вера', 'Максимовна', 'г. Москва ул. Длинная 7', '07.07.2002');


begin;
insert into job (title) values 
('администратор'),
('мaстер ногтевого сервиса'),
('парикмахер'),
('визожист');
update job set title = 'визажист' where id_job = 4;
insert into job (id_job, title) values
(5, 'кoлopиcт'),
(6, 'косметолог'),
(7, 'парикмахер-стилист'),
(8, 'стилист-визажист');
select * from job;
commit;


insert into job_history(id_master, date_start, id_job, salary) values
(1, '04.04.2004', 2, 77000),
(2, '07.07.2007', 7, 77000),
(4, '05.05.2017', 5, 55000),
(1, '24.02.2022', 4, 99000);


insert into service(name, price, duration) values
('Массаж', 2400, 20),
('Окрашивание волос', 4000, 90),
('Наращивание ресниц', 2000, 60),
('Маникюр', 1000, 30),
('Педикюр', 2000, 30),
('Стрижка волос', 700, 60),
('Укладка волос', 400, 45);


insert into service_master(id_master, id_service) values
(2, 4),(2, 5),(4, 2),(4, 6),(4, 7);


insert into record(id_master, id_client, data_start) values
(2, 2, '04.04.2023 10:00'),
(2, 4, '07.04.2023 12:00'),
(4, 4, '24.05.2023 14:00'),
(4, 4, '04.06.2023 17:00'),
(4, 5, '04.06.2023 10:00');



insert into service_record(id_record, id_service, active) values
(1, 2, true), (1, 6, false), (2, 6, true), (2, 7, true), (3, 4, false),
(3, 5, true), (4, 5, true), (4, 4, true), (5, 4, true);

select * from record;
select * from record;






create view total_minute_master_work_month as
select
last_name || ' ' || first_name || ' ' || middle_name as master,
date_part('month', record.data_start) as month,
sum(duration) as minute
from master
join record on master.id_master = record.id_master
join service_record on record.id_record = service_record.id_record
join service on service_record.id_service = service.id_service
where
	service_record.active
	and date_part('year', record.data_start) = 2023
group by master, date_part('month', record.data_start)
order by date_part('month', record.data_start);


create view list_service as
select
master.last_name || ' ' || master.first_name || ' ' || master.middle_name as master,
client.last_name || ' ' || client.first_name || ' ' || client.middle_name as client,
service.name as service,
service.price as price,
date(record.data_start) as data
from master
join record on master.id_master = record.id_master
join service_record on record.id_record = service_record.id_record
join service on service_record.id_service = service.id_service
join client on record.id_client= client.id_client
where date(record.data_start) > now();







create user admin PASSWORD 'Kgt6)yf%t';
grant all privileges on database beauty to admin;
grant all privileges on all tables in schema public to admin;


create role master;
create user olga PASSWORD 'i8g_7Ftg';
grant master to olga;
grant select on client, job, job_history, service, service_master, record, service_record to master; 
grant update on record to master; 


create role manager;
create user ivan PASSWORD '93h&9djG';
grant manager to ivan;
grant select on total_minute_master_work_month, list_service to manager; 






create function price_record(num_record int)
returns int language plpgsql as
$$ declare
total_price numeric;

begin
	select
		sum(price) into total_price
	from record
	join service_record on record.id_record = service_record.id_record
	join service on service_record.id_service = service.id_service
	where
		service_record.id_record = num_record
		and service_record.active;
return total_price; 
end;
$$;


create or replace function data_end_record() returns trigger as $$
begin
case tg_op
	when 'INSERT' then
		update record 
			set data_end = data_start + ((select sum(duration) from service
				join service_record on service.id_service = service_record.id_service
					where id_record = new.id_record) || 'minutes')::interval where id_record = new.id_record;
		return new;
	else
		update record 
			set data_end = data_start + ((select sum(duration) from service
			join service_record on service.id_service = service_record.id_service
				where id_record = old.id_record) || 'minutes')::interval where id_record = old.id_record;
		return old;
end case;

end;
$$ language plpgsql;


create or replace trigger data_end_record after insert or update or delete on service_record
    for each row execute function data_end_record();






select
client.last_name || ' ' || client.first_name || ' ' || client.middle_name as client,
count(*) as count_service,
sum(service.price) as total_price
from client
join record on client.id_client = record.id_client
join service_record on record.id_record = service_record.id_record
join service on service_record.id_service = service.id_service
where
	service_record.active
	and date_part('year', record.data_start) = 2023
group by client
order by total_price desc;