import credentials

import psycopg2


MENU = """
0. Exit;
1. Get max engine power;
2. Get owner name and phone number by car state number;
3. Get producer rating;
4. Get meta information about table; 
5. Get average engine power;
6. Get car numbers with drivers info;
7. Change car owner phone number
8. Print database info
9. Create table car colors
10. Insert new car color
"""


def start_connection():
    try:
        connection = psycopg2.connect(
            database=credentials.db_name,
            user=credentials.db_user,
            password=credentials.ds_pass,
            host=credentials.db_host,
            port=credentials.db_port,
        )
        return connection
    except Exception as e:
        print(f'Error occurred : {e}')


def stop_program(cursor):
    cursor.close()
    exit(0)


def find_max_engine_power(cursor):
    cursor.execute("""
        select max(engine_power)
        from car_models""")
    result = cursor.fetchone()[0]

    print(f'Max engine power is {result}')
    return float(result)


def find_owner_by_car_state_number(cursor):
    state_number = input('Enter car state number: ')

    cursor.execute(f"""
        select co.name, co.phone_number
        from cars c left join car_owners co
        on c.owner_id = co.id
        where c.state_number = '{state_number}'""")

    try:
        name, phone = cursor.fetchone()
    except Exception as e:
        print("Nothing found")
        return

    print(f'Name : {name};\nPhone : {phone}')


def get_producers_rating(cursor):
    cursor.execute(f"""
        with brand_count(name, country, count_cars) as (
            select cman.name, cman.county country, count(cman.name)
            from cars c
                   left join car_models cmod
                             on c.model_id = cmod.id
                   left join car_manufacturers cman
                             on cmod.manufacturer_id = cman.id
            group by cman.name, cman.county)
        select
            brand_count.name,
            brand_count.count_cars,
            brand_count.country,
            row_number() over (
                partition by brand_count.country
                order by brand_count.count_cars desc) country_rating
        from brand_count
        order by brand_count.country;
    """)

    for name, count, country, rating in cursor:
        print(f'Manufacturer {name} from {country} produced {count} cars '
              f'with position {rating} in its country')


def print_table_info(cursor):
    table_name = input('Enter table name: ')

    cursor.execute(f"""
        select column_name, data_type
        from information_schema.columns
        where table_name = '{table_name}'""")

    for name, data_type in cursor:
        print(f'{name} : {data_type}')


def find_average_engine_power(cursor):
    cursor.execute("""
        select avg_engine_power()""")

    average_power = cursor.fetchone()[0]
    print(f'Average engine power is {average_power}')


def select_owners_to_car_numbers(cursor):
    cursor.execute("""
        select * from owner_to_car_numbers()""")

    for name, phone, car_number in cursor:
        print(f'{name} ({phone}) : {car_number}')


def change_car_owner_phone_number(cursor):
    try:
        owner_id = int(input("Enter owner id: "))
        new_phone = input("Enter new owner phone number: ")
    except ValueError as e:
        print("Incorrect input")
        return

    cursor.execute(f"""
        call change_car_owner_phone_number({owner_id}, '{new_phone}')""")

    print("Done!")


def print_database_info(cursor):
    cursor.execute("""
        select current_database(), current_user""")
    db, user = cursor.fetchone()

    print(f"db : {db}; user : {user}")


def create_table_car_colors(cursor):
    cursor.execute("""
        create table if not exists car_colors(
            id bigint generated always as identity primary key ,
            color varchar(128) unique
    )""")

    print('Table car_colors with fields\n'
          '\tid bigint generated always as identity primary key\n'
          '\tcolor vatchar(128) unique\n'
          'has been created')


def insert_new_color(cursor):
    new_color = input('Enter new color: ')

    try:
        cursor.execute(f"""
            insert into car_colors (color)
            values ('{new_color}')""")
    except Exception as e:
        print(f'An error occurred : {e}')
        return

    print("Success!")


def get_action(action_number: int):
    if action_number == 0:
        return stop_program
    elif action_number == 1:
        return find_max_engine_power
    elif action_number == 2:
        return find_owner_by_car_state_number
    elif action_number == 3:
        return get_producers_rating
    elif action_number == 4:
        return print_table_info
    elif action_number == 5:
        return find_average_engine_power
    elif action_number == 6:
        return select_owners_to_car_numbers
    elif action_number == 7:
        return change_car_owner_phone_number
    elif action_number == 8:
        return print_database_info
    elif action_number == 9:
        return create_table_car_colors
    elif action_number == 10:
        return insert_new_color
    else:
        print('Please repeat')


def main_cycle(connection):
    cursor = connection.cursor()

    while True:
        print(MENU)
        try:
            selected = int(input())
            action = get_action(selected)
            action(cursor)
        except Exception as e:
            print(f'Error occurred : {e}')
        connection.commit()


def main():
    connection = start_connection()
    if connection is None:
        exit(1)

    main_cycle(connection)
    connection.close()


if __name__ == '__main__':
    main()
