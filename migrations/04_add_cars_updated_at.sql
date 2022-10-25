alter table public.cars
add column updated_at timestamp not null default now()
