alter table public.car_models add constraint positive_engine_power
    check (engine_power > 0);

alter table public.cars add constraint state_number_lng
    check (char_length(state_number) > 7 and char_length(state_number) < 10);

alter table public.reg_departments add constraint phone_number_lng
    check (char_length(phone_number) = 12);
