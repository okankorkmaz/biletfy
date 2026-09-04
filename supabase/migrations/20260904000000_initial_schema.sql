create extension if not exists pgcrypto;

create table public.tracked_entities (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  name text not null check (char_length(name) between 2 and 120),
  entity_type text not null default 'artist' check (entity_type in ('artist','event','movie')),
  country_code char(2) not null default 'TR',
  is_active boolean not null default true,
  created_at timestamptz not null default now()
);

create table public.events (
  id uuid primary key default gen_random_uuid(),
  tracked_entity_id uuid not null references public.tracked_entities(id) on delete cascade,
  external_id text not null,
  source text not null,
  title text not null,
  city text,
  venue text,
  starts_at timestamptz,
  ticket_url text,
  created_at timestamptz not null default now(),
  unique(source, external_id)
);

create table public.ticket_snapshots (
  id bigint generated always as identity primary key,
  event_id uuid not null references public.events(id) on delete cascade,
  captured_at timestamptz not null default now(),
  sold_count integer check (sold_count >= 0),
  capacity integer check (capacity > 0),
  availability_status text,
  price_min numeric(10,2),
  price_max numeric(10,2),
  raw_payload jsonb not null default '{}'::jsonb
);

create index tracked_entities_user_idx on public.tracked_entities(user_id, created_at desc);
create index events_tracked_idx on public.events(tracked_entity_id, starts_at);
create index snapshots_event_time_idx on public.ticket_snapshots(event_id, captured_at desc);

alter table public.tracked_entities enable row level security;
alter table public.events enable row level security;
alter table public.ticket_snapshots enable row level security;

grant select, insert, update, delete on public.tracked_entities to authenticated;
grant select on public.events, public.ticket_snapshots to authenticated;
grant usage, select on sequence public.ticket_snapshots_id_seq to authenticated;

create policy "users_manage_own_tracking" on public.tracked_entities
  for all to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

create policy "users_read_own_events" on public.events
  for select to authenticated
  using (exists (select 1 from public.tracked_entities t where t.id = tracked_entity_id and t.user_id = (select auth.uid())));

create policy "users_read_own_snapshots" on public.ticket_snapshots
  for select to authenticated
  using (exists (select 1 from public.events e join public.tracked_entities t on t.id = e.tracked_entity_id where e.id = event_id and t.user_id = (select auth.uid())));
