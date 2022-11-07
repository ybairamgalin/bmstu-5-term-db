create extension plpython3u;

-- 1
create or replace function reverse_text(str_ text)
    returns varchar as
$$
    return str_[::-1]
$$ language plpython3u;

-- 2
create or replace function most_common_value(
    table_ varchar,
    column_ varchar)
    returns varchar as
$$
    query = f'select {column_} from {table_}'
    plan = plpy.prepare(query)
    result = plan.execute()

    values_to_count = {}
    for value in result:
        engine_power = value['engine_power']
        if engine_power in values_to_count:
            values_to_count[engine_power] += 1
        else:
            values_to_count[engine_power] = 1

    most_common_value = None
    max_count = 0
    for key, value in values_to_count.items():
        if value > max_count:
            most_common_value = key
            max_count = value

    return most_common_value
$$ language plpython3u;

-- 3
create or replace function owners_to_car_numbers()
    returns table(
                     name varchar,
                     phone_number varchar,
                     state_number varchar
                 ) as
$$
    query = f"""
        select *
        from cars c left join car_owners co on c.owner_id = co.id"""
    plan = plpy.prepare(query)
    result = plan.execute()

    owners_to_car_numbers = []
    for row in result:
        owners_to_car_numbers.append((
            row['name'],
            row['phone_number'],
            row['state_number']
        ))

    return owners_to_car_numbers
$$ language plpython3u;

-- 4
create or replace procedure update_phone_number(
    car_owner_id_ int8,
    new_phone_number_ varchar) as
$$
    query = f"""
        update car_owners set phone_number = '{new_phone_number_}'
        where id = {car_owner_id_}
    """
    plan = plpy.prepare(query)
    plan.execute()
$$ language plpython3u;

-- 5
create or replace function cars_procedure_after_update()
    returns trigger as
$$
    plpy.notice('Table cars was changed')
$$ language plpython3u;

create or replace trigger cars_trigger_after_update
    after update on cars for each row execute procedure
    cars_procedure_after_update();

-- 6
create type status_v01 as enum (
    'operating',
    'closed'
    );

create or replace function get_department_status(id_ int)
    returns status_v01 as
$$
    query = f"""
        select is_operating from reg_departments where id={id_}
    """
    plan = plpy.prepare(query)
    result = plan.execute()

    if result[0]:
        return 'operating'
    else:
        return 'closed'
$$ language plpython3u;
