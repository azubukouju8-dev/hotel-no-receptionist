-- Hotel guest communication system: database schema (Supabase / Postgres)
-- Run this in the Supabase SQL Editor on a new project.

-- Rooms (5-room boutique hotel)
create table rooms (
  id serial primary key,
  room_number text unique not null,
  name text,
  lock_id text
);

-- Guests
create table guests (
  id uuid primary key default gen_random_uuid(),
  full_name text not null,
  email text,
  phone text,
  telegram_chat_id bigint,
  preferred_channel text not null default 'telegram'
    check (preferred_channel in ('telegram','whatsapp','sms','email')),
  created_at timestamptz default now()
);

-- Bookings
create table bookings (
  id uuid primary key default gen_random_uuid(),
  guest_id uuid references guests(id) on delete cascade,
  room_id int references rooms(id),
  check_in date not null,
  check_out date not null,
  status text not null default 'confirmed'
    check (status in ('confirmed','checked_in','checked_out','cancelled')),
  welcome_sent boolean default false,
  reminder_sent boolean default false,
  upsell_sent boolean default false,
  late_checkout boolean default false,
  created_at timestamptz default now()
);

-- Door PINs (from the mock smart lock)
create table door_codes (
  id uuid primary key default gen_random_uuid(),
  booking_id uuid references bookings(id) on delete cascade,
  pin text not null,
  valid_from timestamptz not null,
  valid_to timestamptz not null,
  active boolean default true
);

-- Message log (used for the AI concierge and handled-by statistics)
create table messages (
  id uuid primary key default gen_random_uuid(),
  guest_id uuid references guests(id) on delete cascade,
  booking_id uuid references bookings(id) on delete set null,
  direction text not null check (direction in ('inbound','outbound')),
  channel text not null,
  body text not null,
  handled_by text not null default 'system'
    check (handled_by in ('system','ai','human')),
  created_at timestamptz default now()
);

-- Seed the 5 rooms
insert into rooms (room_number, name, lock_id) values
  ('101', 'Garden Room', 'lock-101'),
  ('102', 'Courtyard Room', 'lock-102'),
  ('201', 'Terrace Suite', 'lock-201'),
  ('202', 'Skyline Room', 'lock-202'),
  ('203', 'Penthouse Suite', 'lock-203');

-- Example: how much of the conversation needs no human?
-- select handled_by, count(*) as messages
-- from messages
-- where direction = 'outbound'
-- group by handled_by;
