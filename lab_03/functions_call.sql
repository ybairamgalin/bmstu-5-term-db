select avg_engine_power();

select * from owner_to_car_numbers();

select * from cars_delete_oldest_records();

select *
from fib(1,1, 13);

call change_car_owner_phone_number(1, '+79851513771');

call ith_fib(10);

call extract_names();

call extract_meta('car_owners');

update public.cars
    set state_number = 'М058НС199'
where id = 1;

delete from operating_departments
where id=3;

select * from operating_departments;

insert into cars (owner_id, model_id, reg_department_id, state_number, construction_date)
values (1, 1, 1, 'С596ОА799', '1900-10-10');

insert into cars (owner_id, model_id, reg_department_id, state_number, construction_date)
values (1, 1, 1, 'С596ОА799', '2021-10-10');
