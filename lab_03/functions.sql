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

