-- 1
select reverse_text('City of Moscow');

-- 2
select engine_power, most_common_value('car_models', 'engine_power') most_common
from car_models
group by engine_power;

-- check
select engine_power, count(*)
from car_models
group by engine_power;

-- 3
select * from owners_to_car_numbers();

-- 4
call update_phone_number(1, '+79104295004');

-- 5
update cars set owner_id=1 where id=1;

--6
select get_department_status(1);
