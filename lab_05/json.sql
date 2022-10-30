-- 1
select row_to_json(cm)
from car_manufacturers cm;

select row_to_json(cm)
from car_models cm;

select row_to_json(co)
from car_owners co;

select row_to_json(c)
from cars c;

select row_to_json(rd)
from reg_departments rd;

-- 2
create table car_manufacturers_copy(
    id bigint generated always as identity primary key,
    name   varchar(255) not null unique,
    county varchar(255)
);

copy(
    select row_to_json(cm) from car_manufacturers cm
) to '/Users/yaroslavbairamgalin/Desktop/Studies/BMSTU/5 term/db/lab_05/cm.json';

create temporary table cm_import(
    doc json
);

copy cm_import from '/Users/yaroslavbairamgalin/Desktop/Studies/BMSTU/5 term/db/lab_05/cm.json';

insert into car_manufacturers_copy (name, county)
(select doc->>'name', doc->>'county' from cm_import);

drop table cm_import;
drop table car_manufacturers_copy;

-- 3
-- 05_add_model_attributes.sql
update car_models
set attributes='{"colors": ["red", "blue", "black"]}'::json
where id = 1;

update car_models
set attributes='{"colors": ["white"], "info": {"passengers": 7, "cargo": 120}}'::json
where id = 2;

select * from car_models where id=2;

-- 4.1
select attributes as info
from car_models
where id = 2;

-- 4.2
select attributes->>'info' as info
from car_models
where id = 2;

select attributes->>'info' as info
              from car_models
              where id = 2;

-- 4.3
select *
from car_models
where json_extract_path(attributes, 'colors') is not null;

-- 4.4
update car_models
set attributes = attributes::jsonb || '{"stage": "type_1"}'::jsonb
where json_extract_path(attributes, 'info') is not null;

update car_models
set attributes = attributes::jsonb || '{"info": {"cargo": 110, "passenger": 8}}'::jsonb
where json_extract_path(attributes, 'info') is not null;

-- 4.5
select
    json_extract_path(attributes, 'info') info,
    json_extract_path(attributes, 'colors') colors,
    json_extract_path(attributes, 'info', 'cargo') cargo
from car_models
where attributes is not null;
