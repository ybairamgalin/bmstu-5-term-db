-- 1.1
-- средняя мощность двигателя
create or replace function public.avg_engine_power()
    returns float8 as $$
    declare avg_power float8;
    begin
        select avg(cm.engine_power) into avg_power
        from public.car_models cm;

        return avg_power;
    end;
    $$ language plpgsql;


-- 1.2
-- имя, телефон владельца, гос номер его автомобиля
create or replace function public.owner_to_car_numbers()
    returns table (
        name varchar(255),
        phone_number varchar(15),
        state_number varchar(15)
    ) as $$
    begin
        return query select
                         co.name as name,
                         co.phone_number as phone_number,
                         c.state_number as state_number
        from cars c left join car_owners co
        on c.owner_id = co.id;
    end;
    $$ language plpgsql;


-- 1.3
create or replace function public.cars_delete_oldest_records()
    returns table(
        oldest_id int8,
        oldest_owner_id int8,
        oldest_model_id int8,
        oldest_reg_department_id int8,
        oldest_state_number varchar(15),
        oldest_construction_date date,
        oldest_updated_at timestamp
    ) as $$
    declare
        oldest_row record;
    begin
        for oldest_row in (select *
                      from public.cars c
                      where c.updated_at =
                            (select min(cars.updated_at) from cars))
        loop
            oldest_id = oldest_row.id;
            oldest_owner_id = oldest_row.owner_id;
            oldest_model_id = oldest_row.model_id;
            oldest_reg_department_id = oldest_row.reg_department_id;
            oldest_state_number = oldest_row.state_number;
            oldest_construction_date = oldest_row.construction_date;
            oldest_updated_at = oldest_row.updated_at;
            delete from cars where cars.id = oldest_row.id;
            return next;
        end loop;
    end;
    $$ language plpgsql;


-- 1.4
create or replace function fib(first int, second int, max int)
returns table (fibonacci int)
as '
begin
    return query
    select first;
    if second <= max then
        return query
        select *
        from fib(second, first + second, max);
    end if;
end' language plpgsql;


-- 2.1
create or replace procedure change_car_owner_phone_number(
    owner_id bigint,
    new_phone varchar(15)
)
    as'
begin
    update public.car_owners co
    set phone_number = new_phone
    where id = owner_id;
end;
' language plpgsql;


-- 2.2
create or replace procedure ith_fib
(
	i int,
	index int default 0,
	first int default 0,
	second int default 1
)
as '
begin
    if index = i then
        raise notice ''%-th fibonacci number is %'', i, first;
    else
        call ith_fib(i, index + 1, second, first + second);
end if;
end;
' language plpgsql;


-- 2.3
create or replace procedure extract_names()
as '
declare
    name varchar(255);
    name_cursor cursor
    for
        select co.name from car_owners co;
begin
    open name_cursor;
    loop
        fetch name_cursor
        into name;
        exit when not found;
        raise notice ''name=%'', split_part(name, '' '', 1);
    end loop;
    close name_cursor;
end;
' language plpgsql;


-- 2.4
create or replace procedure extract_meta(
	table_name_ VARCHAR(100)
)
as '
declare
	buf record;
    data_cursor cursor
	for
        select column_name, data_type
		from information_schema.columns
        where table_name = table_name_;
begin
    open data_cursor;
    loop
		fetch data_cursor
        into buf;
		exit when not found;
        raise notice ''column name = %; data type = %'', buf.column_name, buf.data_type;
    end loop;
	close data_cursor;
end;
' language plpgsql;


-- 3.1
create or replace function updated_at_cats_set()
returns trigger
as '
begin
    raise notice ''New =  %'', new;
    new.updated_at = now();
    raise notice ''New =  %'', new;
    return new;
end;
' language plpgsql;

create or replace trigger set_cars_updated_at
before update on public.cars
    for each row execute procedure updated_at_cats_set();


-- 3.2
create or replace function delete_operating_department()
returns trigger
as'
begin
    update public.reg_departments
    set is_operating = false
    where id = old.id;
    return new;
end;
' language plpgsql;

create or replace view operating_departments as
select * from reg_departments
where is_operating = true;

create or replace trigger delete_operating_departments
instead of delete on operating_departments
    for each row execute procedure delete_operating_department();


-- защита
create or replace function updated_at_cats_set()
returns trigger
as '
declare
    start_production_date_ date;
begin
    start_production_date_ = (select start_production_date
                              from public.car_models cm
                              where cm.id = new.model_id);
    if start_production_date_ > new.construction_date then
        raise exception ''Construction date cannot be before production date'';
    end if;
    return new;
end;
' language plpgsql;

create or replace trigger check_start_production_date
after insert on public.cars
    for each row execute procedure updated_at_cats_set();
