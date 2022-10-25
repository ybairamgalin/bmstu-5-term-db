import random
import postgres

from data.car_manufacturers import car_manufacturers
from data.names import names
from data.surnames import surnames


def generate_number(start: int, end: int) -> int:
    return random.randint(start, end)


def generate_name() -> str:
    name_index = generate_number(1, len(names) - 1)
    surname_index = generate_number(1, len(surnames) - 1)
    return names[name_index] + ' ' + surnames[surname_index]


def generate_pass_number() -> str:
    series = str(generate_number(40, 45)) + ' ' + \
             str(generate_number(10, 20)) + ' '
    number = str(generate_number(100000, 999999))
    return series + number


def generate_phone_number() -> str:
    number = '+79'

    for i in range(9):
        number += str(generate_number(0, 9))

    return number


def generate_license_number() -> str:
    series = str(generate_number(80, 99)) + ' ' + \
             str(generate_number(10, 99)) + ' '
    number = str(generate_number(100000, 999999))
    return series + number


def pack_to_sql_params(params):
    if len(params) < 1:
        raise

    req = '('
    req += f'\'{params[0]}\''
    params.pop(0)
    for element in params:
        req += f', \'{element}\''
    req += ')'
    return req


def generate_owners(num: int):
    owners = []

    for _ in range(num):
        owners.append(pack_to_sql_params([
            generate_name(),
            generate_pass_number(),
            generate_phone_number(),
            generate_license_number()
        ]))

    return owners


def generate_manufacturers():
    manufacturers = []

    for element in car_manufacturers:
        manufacturers.append(pack_to_sql_params([
            element,
        ]))

    return manufacturers


def generate_date(start_year: int, end_year: int):
    return f'{generate_number(start_year, end_year)}-' \
           f'{generate_number(1, 12)}-' \
           f'{generate_number(1, 28)}'


def generate_car_name():
    name = ''

    chance = random.random()
    if chance < 0.15:
        name += 'Новый '
    elif chance < 0.3:
        name += 'Кроссовер '
    elif chance < 0.8:
        name += 'Седан '
    else:
        name += 'Внедорожник '

    chance = random.random()
    if chance < 0.15:
        name += 'X'
    elif chance < 0.5:
        name += 'AMG'
    else:
        name += 'GT'

    name += str(random.randint(1, 12)) + ' '

    chance = random.random()
    if chance < 0.15:
        name += 'c прицепом '
    elif chance < 0.5:
        name += 'с мягкой подвеской '
    else:
        name += 'спортивного класса '

    return name


def generate_engine_power():
    powers = [
        70,
        70,
        70,
        71,
        71,
        71,
        125,
        149,
        179,
        209,
        249,
        350,
        420,
        550,
    ]
    return powers[random.randint(0, len(powers) - 1)]


def generate_car_models(num: int):
    models = []

    for _ in range(num):
        models.append(pack_to_sql_params([
            random.randint(1, len(car_manufacturers)),
            generate_car_name(),
            generate_date(1980, 2022),
            generate_engine_power(),
        ]))
    return models


def generate_reg_departments(num: int):
    departments = []

    for _ in range(num):
        departments.append(pack_to_sql_params([
            f'ГИБДД №{generate_number(1, 10000)}',
            ['Москва', 'Санкт-Петербкрг', 'Казань', 'Самара',
             'Красноярск', 'Челябинск', 'Донецк'][generate_number(0, 6)],
            generate_phone_number(),
            [True, False][generate_number(0, 1)]
        ]))
    return departments


def generate_state_number():
    letters = ['A', 'C', 'B', 'P', 'E', 'O', 'M', 'H']
    regions = ['77', '29', '777', '199', '799', '69',
               '150', '750']

    def rand_letter():
        return letters[generate_number(0, len(letters) - 1)]

    def rand_region():
        return regions[generate_number(0, len(regions) - 1)]

    state_number = ''
    state_number += rand_letter()
    state_number += str(generate_number(0, 9))
    state_number += str(generate_number(0, 9))
    state_number += str(generate_number(0, 9))
    state_number += rand_letter()
    state_number += rand_letter()
    state_number += rand_region()
    return state_number


def generate_cars(num: int):
    cars = []

    for _ in range(num):
        cars.append(pack_to_sql_params([
            generate_number(1, 1000),
            generate_number(1, 1000),
            generate_number(1, 1000),
            generate_state_number(),
            generate_date(1980, 2021),
        ]))
    return cars


def join_for_data(values):
    return ',\n\t'.join(values)


file = open('data/fill_data.sql', "w")

file.write(f"""
insert into
    public.car_manufacturers (name)
values
    {join_for_data(generate_manufacturers())};
""")

file.write(f"""
insert into
    public.car_owners (name, passport_number, phone_number, license_number)
values
    {join_for_data(generate_owners(1000))};
""")

file.write(f"""
insert into
    public.car_models (manufacturer_id, name, start_production_date, engine_power)
values
    {join_for_data(generate_car_models(1000))};
""")

file.write(f"""
insert into
    public.reg_departments (city, name, phone_number, is_operating)
values
    {join_for_data(generate_reg_departments(1000))};
""")

file.write(f"""
insert into
    public.cars (owner_id, model_id, reg_department_id, state_number, construction_date)
values 
    {join_for_data(generate_cars(1000))};
""")
