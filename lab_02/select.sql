-- 1 получить имя и паспорт владельца по гос номеру авто
select co.name, co.passport_number
from public.cars c left join public.car_owners co
on c.owner_id = co.id
where c.state_number = 'A269CC799';

-- 2 получить номера машины произведенные между 2000 и 2010 годом
select c.state_number, c.construction_date
from public.cars c
where c.construction_date between '2000-01-01' and '2010-01-01'
order by c.construction_date;

-- 3 получить марки внедорожников
select cmod.name model, cman.name brand
from public.car_models cmod left join car_manufacturers cman
on cmod.manufacturer_id = cman.id
where cmod.name like '%Внедорожник%';

-- 4 гос номера машин с двигателем мощнее 400 л с
select c.state_number
from public.cars c where c.model_id in
(select id from car_models where engine_power > 400);

-- 5 получить владельцев у которых больше чем 1 машина
select co.name, co.passport_number
from car_owners co
where exists(select 1 from
    (select count(*) car_number
     from public.cars c
     where c.owner_id = co.id) as ccn
    where car_number >= 2);

-- 6
select * from car_models
where start_production_date > all (select start_production_date
                                   from car_models where manufacturer_id=2);

-- 7 для каждого бренда количество автомобилей и средняя мощность
select cman.name, avg(cmod.engine_power) as avg_engine_power, count(cman.name)
from cars c
       left join car_models cmod
                 on c.model_id = cmod.id
       left join car_manufacturers cman
                 on cmod.manufacturer_id = cman.id
group by cman.name;

-- 8 для конкретной модели автомобиля вывести название, дату начала производства, мощность двигателя
-- и среднюю мощность двигателя всех автомобилей
select cmodels.name, cmodels.start_production_date, cmodels.engine_power,
       (select avg(engine_power) from car_models) avg_engine_power
from car_models cmodels
where cmodels.id = 2;

-- 9
select car_manufacturers.name,
       case
           when county = 'Russia' then 'Российский'
           else 'Иностранный'
       end as origin
from car_manufacturers;

-- 10 для каждого автомобиля вывести его гос номер, и признак (старый/средний/новый)
select
    c.state_number,
    case
        when (extract(year from c.construction_date)) > 2019 then 'новый'
        when (extract(year from c.construction_date)) > 2010 then 'средний'
        else 'старый'
    end as state
from cars c;

-- 11 вывести во временную таблицу марки автомобилей и их среднюю мощность двигателя
select avg(engine_power) ang_engine_power, cmanufacturers.name
into temporary manufacturer_to_avg_power
from car_models cmodels left join
    car_manufacturers cmanufacturers on cmodels.manufacturer_id = cmanufacturers.id
group by cmanufacturers.name;
select * from manufacturer_to_avg_power;
drop table if exists manufacturer_to_avg_power;

-- 12
select avg(c)
from (select count(*) c from cars group by model_id) as a;

-- 13
select name from car_manufacturers
where id =
      (select manufacturer_id
       from car_models
       where id =
             (select model_id from cars where id=10));

-- 14
select count(*), engine_power from car_models
group by engine_power;

-- 15
select count(*), engine_power from car_models
group by engine_power
having count(*) > 200
order by engine_power;

-- 16
insert into cars (owner_id, model_id, reg_department_id, state_number, construction_date)
values (1, 1, 1, ' АА123А777', '1980-10-10');

-- 17
insert into car_models (manufacturer_id, name, start_production_date, engine_power)
select manufacturer_id, name, start_production_date, engine_power + 100
from car_models
where id = 10;

-- 18
update car_models
set engine_power = engine_power + 100
where id=1;

-- 19
update car_models
set engine_power = (select max(car_models.engine_power) from car_models)
where car_models.id = 1;

-- 20
delete from cars
where id = 10;

-- 21
delete from cars
where id = (select id from cars order by id desc limit 1);

--22
with brand_count(name, count_cars) as (
    select cman.name, avg(cmod.engine_power) as avg_engine_power, count(cman.name)
    from cars c
           left join car_models cmod
                     on c.model_id = cmod.id
           left join car_manufacturers cman
                     on cmod.manufacturer_id = cman.id
    group by cman.name)
select brand_count.name
from brand_count
where brand_count.count_cars = (select max(count_cars) from brand_count);

-- 24
select cm.name, car_models.name,
       avg(engine_power) over (partition by cm.id),
       max(engine_power) over (partition by cm.id),
       min(engine_power) over (partition by cm.id)
from car_models left join
    car_manufacturers cm on car_models.manufacturer_id = cm.id;

-- 25
select cm.name, engine_power, row_number() over (order by engine_power)
from car_models left join
    car_manufacturers cm on car_models.manufacturer_id = cm.id;

-- защита
select co.id as owner_id, co.name as owner_name,
       c.name as brand_name, c.county as country
from cars left join
    car_owners co on cars.owner_id = co.id
    left join car_models cm on cars.model_id = cm.id
    left join car_manufacturers c on cm.manufacturer_id = c.id
where c.county = 'Germany';
