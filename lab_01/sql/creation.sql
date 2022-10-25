drop table if exists public.cars;
drop table if exists public.reg_departments;
drop table if exists public.car_models;
drop table if exists public.car_manufacturers;
drop table if exists public.car_owners;

create table public.reg_departments(
    id int8 generated always as identity not null primary key,
    city varchar(255) not null,
    name varchar(255) not null,
    phone_number varchar(15),
    is_operating bool not null
);

create table public.car_manufacturers(
    id int8 generated always as identity not null primary key,
    name varchar(255) unique not null
);

create table public.car_models(
    id int8 generated always as identity not null primary key,
    manufacturer_id int8 not null,
    name varchar(255) not null,
    start_production_date date not null,
    engine_power int2 not null,

    foreign key (manufacturer_id) references public.car_manufacturers(id)
);

create table public.car_owners(
    id int8 generated always as identity not null primary key,
    name varchar(255) not null,
    passport_number varchar(15) not null unique,
    phone_number varchar(15) unique,
    license_number varchar(15) not null unique
);

create table public.cars(
    id int8 generated always as identity not null primary key,
    owner_id int8 not null,
    model_id int8 not null,
    reg_department_id int8 not null,
    state_number varchar(15) not null unique,
    construction_date date not null,

    foreign key (owner_id) references public.car_owners(id),
    foreign key (model_id) references public.car_models(id),
    foreign key (reg_department_id) references public.reg_departments(id)
)
