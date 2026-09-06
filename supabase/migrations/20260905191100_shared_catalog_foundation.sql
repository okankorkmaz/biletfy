-- Phase 1. Apply only after reviewing supabase/PHASE1.md.
-- No legacy rows are updated or deleted. No provider is connected.
begin;
set local lock_timeout = '5s';
set local statement_timeout = '60s';

create schema if not exists biletify_private;
revoke all on schema biletify_private from public, anon, authenticated;
grant usage on schema biletify_private to service_role;

create function biletify_private.reject_history_change()
returns trigger language plpgsql set search_path = pg_catalog as $$
begin
  raise exception 'History protection: % on %.% is forbidden', tg_op, tg_table_schema, tg_table_name
    using errcode = '55000';
end;
$$;
revoke all on function biletify_private.reject_history_change() from public, anon, authenticated;

-- Existing FKs remain intact. BEFORE triggers abort the entire cascade,
-- including auth.users deletion, instead of silently deleting history.
-- Legacy unfollow remains UPDATE tracked_entities SET is_active = false.
revoke delete, truncate on public.tracked_entities from public, anon, authenticated, service_role;
create trigger protect_legacy_tracking_delete before delete on public.tracked_entities
for each row execute function biletify_private.reject_history_change();
create trigger protect_legacy_tracking_truncate before truncate on public.tracked_entities
for each statement execute function biletify_private.reject_history_change();
create trigger protect_legacy_events_delete before delete on public.events
for each row execute function biletify_private.reject_history_change();
create trigger protect_legacy_events_truncate before truncate on public.events
for each statement execute function biletify_private.reject_history_change();
create trigger protect_legacy_snapshots_change before update or delete on public.ticket_snapshots
for each row execute function biletify_private.reject_history_change();
create trigger protect_legacy_snapshots_truncate before truncate on public.ticket_snapshots
for each statement execute function biletify_private.reject_history_change();
revoke update, delete, truncate on public.ticket_snapshots from public, anon, authenticated, service_role;

create table public.catalog_entities (
  id uuid primary key default gen_random_uuid(),
  entity_kind text not null check (entity_kind in ('artist', 'event', 'show')),
  display_name text not null check (length(btrim(display_name)) > 0),
  publication_status text not null default 'draft' check (publication_status in ('draft', 'published', 'archived')),
  created_at timestamptz not null default now(),
  unique (id, entity_kind)
);
create table public.artists (
  id uuid primary key,
  entity_kind text not null default 'artist' check (entity_kind = 'artist'),
  artist_type text not null default 'person' check (length(btrim(artist_type)) > 0),
  foreign key (id, entity_kind) references public.catalog_entities(id, entity_kind) on delete restrict
);
create table public.catalog_events (
  id uuid primary key,
  entity_kind text not null default 'event' check (entity_kind = 'event'),
  -- Open classification: concert, stand_up, theatre, movie, or future types.
  event_type text not null check (length(btrim(event_type)) > 0),
  foreign key (id, entity_kind) references public.catalog_entities(id, entity_kind) on delete restrict
);
create table public.event_participants (
  event_id uuid not null references public.catalog_events(id) on delete restrict,
  artist_id uuid not null references public.artists(id) on delete restrict,
  participant_role text not null default 'performer' check (length(btrim(participant_role)) > 0),
  primary key (event_id, artist_id, participant_role)
);
create index event_participants_artist_idx on public.event_participants(artist_id, event_id);

create table public.venues (
  id uuid primary key default gen_random_uuid(),
  name text not null check (length(btrim(name)) > 0),
  city text,
  country_code text check (country_code ~ '^[A-Z]{2}$'),
  timezone text not null default 'Europe/Istanbul',
  publication_status text not null default 'draft' check (publication_status in ('draft', 'published', 'archived')),
  created_at timestamptz not null default now()
);
create table public.venue_spaces (
  id uuid primary key default gen_random_uuid(),
  venue_id uuid not null references public.venues(id) on delete restrict,
  name text not null check (length(btrim(name)) > 0),
  -- Nominal seating is not observed sales capacity.
  nominal_capacity integer check (nominal_capacity >= 0),
  unique (id, venue_id)
);
create index venue_spaces_venue_idx on public.venue_spaces(venue_id);
create table public.shows (
  id uuid primary key,
  entity_kind text not null default 'show' check (entity_kind = 'show'),
  event_id uuid not null references public.catalog_events(id) on delete restrict,
  venue_id uuid references public.venues(id) on delete restrict,
  venue_space_id uuid,
  starts_at timestamptz,
  ends_at timestamptz,
  timezone text not null default 'Europe/Istanbul',
  lifecycle_status text not null default 'unknown' check (lifecycle_status in ('unknown', 'scheduled', 'postponed', 'cancelled', 'completed')),
  foreign key (id, entity_kind) references public.catalog_entities(id, entity_kind) on delete restrict,
  foreign key (venue_space_id, venue_id) references public.venue_spaces(id, venue_id) on delete restrict,
  check (venue_space_id is null or venue_id is not null),
  check (ends_at is null or starts_at is null or ends_at >= starts_at),
  unique (id, event_id)
);
create index shows_event_time_idx on public.shows(event_id, starts_at);
create index shows_venue_time_idx on public.shows(venue_id, starts_at);

create table public.providers (
  id uuid primary key default gen_random_uuid(),
  code text not null unique check (code ~ '^[a-z0-9][a-z0-9_-]*$'),
  name text not null check (length(btrim(name)) > 0),
  adapter_key text,
  is_active boolean not null default false,
  is_published boolean not null default false,
  freshness_seconds integer not null default 86400 check (freshness_seconds > 0),
  capabilities jsonb not null default '{}'::jsonb check (jsonb_typeof(capabilities) = 'object'),
  created_at timestamptz not null default now()
);
create table public.provider_listings (
  id uuid primary key default gen_random_uuid(),
  provider_id uuid not null references public.providers(id) on delete restrict,
  show_id uuid not null references public.shows(id) on delete restrict,
  external_namespace text not null default 'public' check (length(btrim(external_namespace)) > 0),
  external_id text not null check (length(btrim(external_id)) > 0),
  ticket_url text,
  publication_status text not null default 'draft' check (publication_status in ('draft', 'published', 'archived')),
  -- Private/account inventory is deliberately not exposed in Phase 1.
  data_access text not null default 'restricted' check (data_access in ('shared', 'restricted')),
  created_at timestamptz not null default now(),
  unique (provider_id, external_namespace, external_id),
  unique (id, provider_id),
  unique (id, show_id)
);
create index provider_listings_show_idx on public.provider_listings(show_id, provider_id);

create table public.user_follows (
  user_id uuid not null references auth.users(id) on delete cascade,
  entity_id uuid not null references public.catalog_entities(id) on delete restrict,
  created_at timestamptz not null default now(),
  primary key (user_id, entity_id)
);
create index user_follows_entity_idx on public.user_follows(entity_id, user_id);
create table public.user_favorites (
  user_id uuid not null references auth.users(id) on delete cascade,
  entity_id uuid not null references public.catalog_entities(id) on delete restrict,
  created_at timestamptz not null default now(),
  primary key (user_id, entity_id)
);
create index user_favorites_entity_idx on public.user_favorites(entity_id, user_id);

create table public.ingestion_jobs (
  id uuid primary key default gen_random_uuid(),
  provider_id uuid not null references public.providers(id) on delete restrict,
  listing_id uuid,
  idempotency_key text not null unique check (length(btrim(idempotency_key)) > 0),
  job_kind text not null check (job_kind in ('discovery', 'collection', 'legacy_import')),
  status text not null default 'queued' check (status in ('queued', 'running', 'succeeded', 'failed', 'cancelled')),
  scheduled_at timestamptz not null default now(),
  lease_until timestamptz,
  created_at timestamptz not null default now(),
  foreign key (listing_id, provider_id) references public.provider_listings(id, provider_id) on delete restrict,
  unique (id, provider_id)
);
create index ingestion_jobs_due_idx on public.ingestion_jobs(status, scheduled_at);
create table public.collection_attempts (
  id uuid primary key default gen_random_uuid(),
  job_id uuid not null,
  provider_id uuid not null,
  attempt_number integer not null check (attempt_number > 0),
  status text not null default 'running' check (status in ('running', 'succeeded', 'partial', 'failed')),
  started_at timestamptz not null default now(),
  finished_at timestamptz,
  error_code text,
  error_detail jsonb not null default '{}'::jsonb check (jsonb_typeof(error_detail) = 'object'),
  foreign key (job_id, provider_id) references public.ingestion_jobs(id, provider_id) on delete restrict,
  check ((status = 'running' and finished_at is null) or (status <> 'running' and finished_at is not null)),
  check (finished_at is null or finished_at >= started_at),
  check (status <> 'failed' or error_code is not null),
  unique (job_id, attempt_number),
  unique (id, provider_id, status)
);
create table public.collection_results (
  id uuid primary key default gen_random_uuid(),
  attempt_id uuid not null,
  provider_id uuid not null,
  attempt_status text not null check (attempt_status in ('succeeded', 'partial', 'failed')),
  listing_id uuid not null,
  status text not null check (status in ('succeeded', 'failed', 'not_found', 'invalid')),
  result_origin text not null default 'provider' check (result_origin in ('provider', 'legacy_import')),
  collected_at timestamptz not null,
  recorded_at timestamptz not null default now(),
  error_code text,
  raw_payload jsonb,
  metadata jsonb not null default '{}'::jsonb check (jsonb_typeof(metadata) = 'object'),
  foreign key (attempt_id, provider_id, attempt_status) references public.collection_attempts(id, provider_id, status) on delete restrict,
  foreign key (listing_id, provider_id) references public.provider_listings(id, provider_id) on delete restrict,
  check (status <> 'succeeded' or attempt_status in ('succeeded', 'partial')),
  check (status = 'succeeded' or error_code is not null),
  unique (attempt_id, listing_id),
  unique (id, listing_id, status)
);
create index collection_results_listing_time_idx on public.collection_results(listing_id, collected_at desc);

create table public.ticket_observations (
  id uuid primary key default gen_random_uuid(),
  collection_result_id uuid not null,
  listing_id uuid not null,
  result_status text not null default 'succeeded' check (result_status = 'succeeded'),
  observed_at timestamptz not null,
  source_timestamp timestamptz,
  recorded_at timestamptz not null default now(),
  measurement_scope text not null check (measurement_scope in ('unknown', 'show', 'provider_allocation', 'category')),
  scope_key text not null default 'total' check (length(btrim(scope_key)) > 0),
  measurement_origin text not null check (measurement_origin in ('unknown', 'reported', 'derived', 'estimated')),
  parser_version text not null check (length(btrim(parser_version)) > 0),
  normalizer_version text not null check (length(btrim(normalizer_version)) > 0),
  sold_count bigint check (sold_count >= 0),
  capacity bigint check (capacity >= 0),
  occupancy numeric(7,4) check (occupancy between 0 and 100),
  min_price numeric(18,4) check (min_price >= 0),
  max_price numeric(18,4) check (max_price >= 0),
  revenue numeric(20,4) check (revenue >= 0),
  currency text check (currency ~ '^[A-Z]{3}$'),
  availability text check (availability in ('available', 'limited', 'sold_out', 'not_on_sale', 'cancelled')),
  quality_metadata jsonb not null default '{}'::jsonb check (jsonb_typeof(quality_metadata) = 'object'),
  freshness_metadata jsonb not null default '{}'::jsonb check (jsonb_typeof(freshness_metadata) = 'object'),
  foreign key (collection_result_id, listing_id, result_status) references public.collection_results(id, listing_id, status) on delete restrict,
  check (min_price is null or max_price is null or min_price <= max_price),
  -- No implicit inventory aggregation or monetary derivation.
  unique (collection_result_id)
);
create index ticket_observations_listing_time_idx on public.ticket_observations(listing_id, observed_at desc, recorded_at desc);

-- Justified by DashboardRepository.priceTiers(showId). No synthetic tiers.
create table public.ticket_observation_tiers (
  id uuid primary key default gen_random_uuid(),
  observation_id uuid not null references public.ticket_observations(id) on delete restrict,
  tier_key text not null check (length(btrim(tier_key)) > 0),
  name text not null check (length(btrim(name)) > 0),
  price numeric(18,4) check (price >= 0),
  currency text check (currency ~ '^[A-Z]{3}$'),
  sold_count bigint check (sold_count >= 0),
  capacity bigint check (capacity >= 0),
  quality_metadata jsonb not null default '{}'::jsonb check (jsonb_typeof(quality_metadata) = 'object'),
  unique (observation_id, tier_key)
);

create table public.legacy_tracking_map (
  legacy_tracking_id uuid primary key references public.tracked_entities(id) on delete restrict,
  entity_id uuid references public.catalog_entities(id) on delete restrict,
  mapping_status text not null default 'pending_review' check (mapping_status in ('pending_review', 'approved', 'blocked')),
  review_note text not null default 'Manual identity review required; names are not identifiers.',
  reviewed_at timestamptz,
  relationship_imported_at timestamptz,
  check (mapping_status <> 'approved' or (entity_id is not null and reviewed_at is not null and length(btrim(review_note)) > 0))
);
create table public.legacy_event_map (
  legacy_event_id uuid primary key references public.events(id) on delete restrict,
  catalog_event_id uuid,
  show_id uuid,
  listing_id uuid,
  mapping_status text not null default 'pending_review' check (mapping_status in ('pending_review', 'approved', 'blocked')),
  review_note text not null default 'Manual provider namespace, performance and access review required.',
  reviewed_at timestamptz,
  foreign key (show_id, catalog_event_id) references public.shows(id, event_id) on delete restrict,
  foreign key (listing_id, show_id) references public.provider_listings(id, show_id) on delete restrict,
  check (mapping_status <> 'approved' or (catalog_event_id is not null and show_id is not null and listing_id is not null and reviewed_at is not null and length(btrim(review_note)) > 0))
);
create table public.legacy_snapshot_map (
  legacy_snapshot_id bigint primary key references public.ticket_snapshots(id) on delete restrict,
  observation_id uuid unique references public.ticket_observations(id) on delete restrict,
  mapping_status text not null default 'pending_review' check (mapping_status in ('pending_review', 'imported', 'blocked')),
  review_note text not null default 'Waiting for approved event mapping.',
  imported_at timestamptz,
  check ((mapping_status = 'imported') = (observation_id is not null and imported_at is not null))
);
create index legacy_tracking_review_idx on public.legacy_tracking_map(mapping_status);
create index legacy_event_review_idx on public.legacy_event_map(mapping_status);
create index legacy_snapshot_review_idx on public.legacy_snapshot_map(mapping_status);

-- Terminal attempts cannot be rewritten to turn failures into successes.
create function biletify_private.protect_attempt()
returns trigger language plpgsql set search_path = pg_catalog as $$
begin
  if old.status <> 'running' or new.id <> old.id or new.job_id <> old.job_id
     or new.provider_id <> old.provider_id or new.attempt_number <> old.attempt_number
     or new.started_at <> old.started_at then
    raise exception 'Only a running attempt may be finalized; identity is immutable' using errcode = '55000';
  end if;
  return new;
end;
$$;
revoke all on function biletify_private.protect_attempt() from public, anon, authenticated;
create trigger protect_attempt_update before update on public.collection_attempts
for each row execute function biletify_private.protect_attempt();

-- A listing cannot be reassigned to another performance after collection.
-- A correction needs an explicit new identity and an audited future workflow.
create function biletify_private.protect_identity()
returns trigger language plpgsql set search_path = pg_catalog as $$
declare field_name text;
begin
  foreach field_name in array tg_argv loop
    if (to_jsonb(old) -> field_name) is distinct from (to_jsonb(new) -> field_name) then
      raise exception 'Identity field %.% is immutable', tg_table_name, field_name using errcode = '55000';
    end if;
  end loop;
  return new;
end;
$$;
revoke all on function biletify_private.protect_identity() from public, anon, authenticated;
create trigger protect_listing_identity before update on public.provider_listings for each row
execute function biletify_private.protect_identity('id', 'provider_id', 'show_id', 'external_namespace', 'external_id');
create trigger protect_show_identity before update on public.shows for each row
execute function biletify_private.protect_identity('id', 'event_id');

create function biletify_private.protect_completed_mapping()
returns trigger language plpgsql set search_path = pg_catalog as $$
begin
  if tg_table_name = 'legacy_snapshot_map' and old.mapping_status = 'imported' then
    raise exception 'Imported snapshot mapping is immutable' using errcode = '55000';
  end if;
  if tg_table_name = 'legacy_event_map' and old.mapping_status = 'approved' then
    raise exception 'Approved event mapping is immutable' using errcode = '55000';
  end if;
  if tg_table_name = 'legacy_tracking_map' then
    if old.relationship_imported_at is not null then
      raise exception 'Imported relationship mapping is immutable' using errcode = '55000';
    end if;
  end if;
  return new;
end;
$$;
revoke all on function biletify_private.protect_completed_mapping() from public, anon, authenticated;
create trigger protect_snapshot_mapping before update on public.legacy_snapshot_map for each row
execute function biletify_private.protect_completed_mapping();
create trigger protect_event_mapping before update on public.legacy_event_map for each row
execute function biletify_private.protect_completed_mapping();
create trigger protect_tracking_mapping before update on public.legacy_tracking_map for each row
execute function biletify_private.protect_completed_mapping();

-- Explicit grants override Supabase installations with permissive defaults.
do $$
declare t text;
begin
  foreach t in array array[
    'catalog_entities','artists','catalog_events','event_participants','shows','venues','venue_spaces',
    'providers','provider_listings','user_follows','user_favorites','ingestion_jobs',
    'collection_attempts','collection_results','ticket_observations','ticket_observation_tiers',
    'legacy_tracking_map','legacy_event_map','legacy_snapshot_map'
  ] loop
    execute format('alter table public.%I enable row level security', t);
    execute format('revoke all on public.%I from public, anon, authenticated, service_role', t);
    execute format('grant select, insert, update on public.%I to service_role', t);
  end loop;
  foreach t in array array['collection_results','ticket_observations','ticket_observation_tiers'] loop
    execute format('revoke update on public.%I from service_role', t);
    execute format('create trigger immutable_rows before update or delete on public.%I for each row execute function biletify_private.reject_history_change()', t);
  end loop;
  foreach t in array array[
    'catalog_entities','artists','catalog_events','event_participants','shows','venues','venue_spaces',
    'providers','provider_listings','ingestion_jobs','collection_attempts',
    'legacy_tracking_map','legacy_event_map','legacy_snapshot_map'
  ] loop
    execute format('create trigger protected_delete before delete on public.%I for each row execute function biletify_private.reject_history_change()', t);
  end loop;
  foreach t in array array[
    'catalog_entities','artists','catalog_events','event_participants','shows','venues','venue_spaces',
    'providers','provider_listings','ingestion_jobs','collection_attempts','collection_results',
    'ticket_observations','ticket_observation_tiers','legacy_tracking_map','legacy_event_map','legacy_snapshot_map'
  ] loop
    execute format('create trigger protected_truncate before truncate on public.%I for each statement execute function biletify_private.reject_history_change()', t);
  end loop;
end;
$$;

grant select on public.catalog_entities, public.artists, public.catalog_events,
  public.event_participants, public.shows, public.venues, public.venue_spaces,
  public.providers, public.provider_listings to authenticated;
grant select, insert, delete on public.user_follows, public.user_favorites to authenticated;
grant delete on public.user_follows, public.user_favorites to service_role;

create policy catalog_published_read on public.catalog_entities for select to authenticated
using (publication_status = 'published');
create policy artists_published_read on public.artists for select to authenticated
using (exists (select 1 from public.catalog_entities e where e.id = artists.id));
create policy events_published_read on public.catalog_events for select to authenticated
using (exists (select 1 from public.catalog_entities e where e.id = catalog_events.id));
create policy participants_published_read on public.event_participants for select to authenticated
using (exists (select 1 from public.catalog_events e where e.id = event_id)
  and exists (select 1 from public.artists a where a.id = artist_id));
create policy venues_published_read on public.venues for select to authenticated
using (publication_status = 'published');
create policy spaces_published_read on public.venue_spaces for select to authenticated
using (exists (select 1 from public.venues v where v.id = venue_id));
create policy shows_published_read on public.shows for select to authenticated
using (exists (select 1 from public.catalog_entities e where e.id = shows.id)
  and exists (select 1 from public.catalog_events e where e.id = shows.event_id));
create policy providers_published_read on public.providers for select to authenticated
using (is_published);
create policy listings_published_read on public.provider_listings for select to authenticated
using (publication_status = 'published' and data_access = 'shared'
  and exists (select 1 from public.shows s where s.id = show_id)
  and exists (select 1 from public.providers p where p.id = provider_id));

create policy follows_own_read on public.user_follows for select to authenticated
using ((select auth.uid()) = user_id);
create policy follows_own_insert on public.user_follows for insert to authenticated
with check ((select auth.uid()) = user_id
  and exists (select 1 from public.catalog_entities e where e.id = entity_id));
create policy follows_own_delete on public.user_follows for delete to authenticated
using ((select auth.uid()) = user_id);
create policy favorites_own_read on public.user_favorites for select to authenticated
using ((select auth.uid()) = user_id);
create policy favorites_own_insert on public.user_favorites for insert to authenticated
with check ((select auth.uid()) = user_id
  and exists (select 1 from public.catalog_entities e where e.id = entity_id));
create policy favorites_own_delete on public.user_favorites for delete to authenticated
using ((select auth.uid()) = user_id);

-- Operational data, raw payloads and observations are backend-only in Phase 1.
-- A later read contract must explicitly project safe metrics and freshness.
commit;
