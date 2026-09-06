\set ON_ERROR_STOP on
\ir phase1_bootstrap.sql
\ir ../migrations/20260904000000_initial_schema.sql
\ir phase1_legacy_fixture.sql
\ir ../migrations/20260905191100_shared_catalog_foundation.sql

create function pg_temp.assert_true(ok boolean, label text) returns void
language plpgsql as $$
begin
  if ok is distinct from true then raise exception 'FAIL: %', label; end if;
  raise notice 'PASS: %', label;
end;
$$;
create function pg_temp.expect_error(statement text, expected_state text, label text) returns void
language plpgsql as $$
begin
  begin
    execute statement;
  exception when others then
    if sqlstate = expected_state then raise notice 'PASS: %', label; return; end if;
    raise exception 'FAIL: %; expected %, got %: %', label, expected_state, sqlstate, sqlerrm;
  end;
  raise exception 'FAIL: %; statement unexpectedly succeeded', label;
end;
$$;

insert into auth.users (id) values (md5('user-a')::uuid), (md5('user-b')::uuid), (md5('user-c')::uuid);
set role service_role;
insert into public.catalog_entities (id, entity_kind, display_name, publication_status) values
  (md5('artist')::uuid, 'artist', 'Shared artist', 'published'),
  (md5('event')::uuid, 'event', 'Shared series', 'published'),
  (md5('show')::uuid, 'show', 'Shared performance', 'published'),
  (md5('draft')::uuid, 'artist', 'Unpublished artist', 'draft');
insert into public.artists (id) values (md5('artist')::uuid);
insert into public.catalog_events (id, event_type) values (md5('event')::uuid, 'future_event_type');
insert into public.event_participants (event_id, artist_id) values (md5('event')::uuid, md5('artist')::uuid);
insert into public.venues (id, name, publication_status) values (md5('venue')::uuid, 'Venue', 'published');
insert into public.venue_spaces (id, venue_id, name) values (md5('space')::uuid, md5('venue')::uuid, 'Hall');
insert into public.shows (id, event_id, venue_id, venue_space_id, starts_at)
values (md5('show')::uuid, md5('event')::uuid, md5('venue')::uuid, md5('space')::uuid, '2026-09-10T18:00:00Z');
insert into public.providers (id, code, name, is_published)
values (md5('provider')::uuid, 'future-provider', 'Future provider', true);
insert into public.provider_listings (id, provider_id, show_id, external_id, publication_status, data_access)
values (md5('listing')::uuid, md5('provider')::uuid, md5('show')::uuid, 'legacy-external', 'published', 'shared');

-- Unknown values and legitimate measured zeros are distinct.
insert into public.ingestion_jobs (id, provider_id, listing_id, idempotency_key, job_kind)
values (md5('job')::uuid, md5('provider')::uuid, md5('listing')::uuid, 'fixture-job', 'collection');
insert into public.collection_attempts (id, job_id, provider_id, attempt_number, status, finished_at, error_code) values
  (md5('attempt1')::uuid, md5('job')::uuid, md5('provider')::uuid, 1, 'succeeded', now(), null),
  (md5('attempt2')::uuid, md5('job')::uuid, md5('provider')::uuid, 2, 'failed', now(), 'timeout'),
  (md5('attempt3')::uuid, md5('job')::uuid, md5('provider')::uuid, 3, 'succeeded', now(), null),
  (md5('attempt4')::uuid, md5('job')::uuid, md5('provider')::uuid, 4, 'failed', now(), 'blocked');
insert into public.collection_results (id, attempt_id, provider_id, attempt_status, listing_id, status, collected_at, error_code) values
  (md5('result1')::uuid, md5('attempt1')::uuid, md5('provider')::uuid, 'succeeded', md5('listing')::uuid, 'succeeded', '2026-09-05T10:00:00Z', null),
  (md5('result2')::uuid, md5('attempt2')::uuid, md5('provider')::uuid, 'failed', md5('listing')::uuid, 'failed', '2026-09-05T11:00:00Z', 'timeout'),
  (md5('result3')::uuid, md5('attempt3')::uuid, md5('provider')::uuid, 'succeeded', md5('listing')::uuid, 'succeeded', '2026-09-05T12:00:00Z', null);
insert into public.ticket_observations (id, collection_result_id, listing_id, observed_at, measurement_scope, measurement_origin, parser_version, normalizer_version)
values (md5('observation1')::uuid, md5('result1')::uuid, md5('listing')::uuid, '2026-09-05T10:00:00Z', 'unknown', 'unknown', 'test-v1', 'test-v1');
select pg_temp.assert_true((select sold_count is null and capacity is null and occupancy is null
  and min_price is null and max_price is null and revenue is null and availability is null
  from public.ticket_observations where id = md5('observation1')::uuid), 'Unknown metrics remain NULL');
select pg_temp.expect_error($q$
  insert into public.ticket_observations (collection_result_id, listing_id, observed_at, measurement_scope, measurement_origin, parser_version, normalizer_version, sold_count, capacity, occupancy, availability)
  values (md5('result2')::uuid, md5('listing')::uuid, now(), 'unknown', 'unknown', 'test', 'test', 0, 0, 0, 'sold_out')
$q$, '23503', 'Failed collection cannot create a fake zero or sold-out observation');
select pg_temp.expect_error($q$
  update public.collection_attempts set status = 'succeeded', error_code = null where id = md5('attempt2')::uuid
$q$, '55000', 'Failed terminal attempt cannot be rewritten');
select pg_temp.expect_error($q$
  insert into public.collection_results (attempt_id, provider_id, attempt_status, listing_id, status, collected_at)
  values (md5('attempt4')::uuid, md5('provider')::uuid, 'succeeded', md5('listing')::uuid, 'succeeded', now())
$q$, '23503', 'Spoofed successful result cannot reference a failed attempt');
select pg_temp.expect_error($q$
  insert into public.ticket_observations (collection_result_id, listing_id, observed_at, measurement_scope, measurement_origin, parser_version, normalizer_version)
  values (md5('result1')::uuid, md5('listing')::uuid, now(), 'unknown', 'unknown', 'test', 'test')
$q$, '23505', 'Reprocessing the same result cannot duplicate an observation');
select pg_temp.expect_error($q$
  insert into public.ticket_observations (collection_result_id, listing_id, observed_at, measurement_scope, scope_key, measurement_origin, parser_version, normalizer_version)
  values (md5('result1')::uuid, md5('listing')::uuid, now(), 'category', 'changed-scope', 'reported', 'v2', 'v2')
$q$, '23505', 'Changed scope or parser version cannot bypass result idempotency');
insert into public.ticket_observations (collection_result_id, listing_id, observed_at, measurement_scope, measurement_origin, parser_version, normalizer_version, sold_count, capacity, occupancy)
values (md5('result3')::uuid, md5('listing')::uuid, '2026-09-05T12:00:00Z', 'provider_allocation', 'reported', 'test', 'test', 0, 100, 0);
select pg_temp.assert_true((select count(*) = 2 from public.ticket_observations), 'Later legitimate collection creates a new observation');
insert into public.ticket_observation_tiers (observation_id, tier_key, name)
values (md5('observation1')::uuid, 'standard', 'Standard');
select pg_temp.expect_error('update public.ticket_observations set sold_count = 0', '42501', 'Backend has no observation UPDATE privilege');
select pg_temp.expect_error('delete from public.ticket_observations', '42501', 'Backend has no observation DELETE privilege');
select pg_temp.expect_error($q$update public.provider_listings set external_id = 'another-performance'$q$,
  '55000', 'Provider listing identity cannot retarget existing history');
reset role;
select pg_temp.expect_error('update public.ticket_observations set sold_count = 0', '55000', 'Owner updates also hit history trigger');
select pg_temp.expect_error('truncate public.ticket_observation_tiers', '55000', 'History cannot be truncated');

set role authenticated;
select set_config('request.jwt.claim.sub', md5('user-a')::uuid::text, false);
select pg_temp.assert_true((select count(*) = 3 from public.catalog_entities), 'Only published catalog is readable');
select pg_temp.assert_true((select count(*) = 1 from public.provider_listings), 'Published shared listing is readable');
insert into public.user_follows (user_id, entity_id) values (auth.uid(), md5('artist')::uuid);
insert into public.user_favorites (user_id, entity_id) values (auth.uid(), md5('event')::uuid);
select pg_temp.expect_error($q$insert into public.user_follows (user_id, entity_id)
  values (md5('user-b')::uuid, md5('artist')::uuid)$q$, '42501', 'Cannot create another user follow');
select pg_temp.expect_error($q$insert into public.user_follows (user_id, entity_id)
  values (auth.uid(), md5('draft')::uuid)$q$, '42501', 'Cannot follow an unpublished target');
select pg_temp.expect_error($q$insert into public.catalog_entities(entity_kind, display_name)
  values ('artist', 'Forbidden')$q$, '42501', 'Client cannot write catalog');
select pg_temp.expect_error('select * from public.collection_results', '42501', 'Client cannot read raw operational data');
select pg_temp.expect_error('select * from public.ticket_observations', '42501', 'History awaits a safe read contract');
select pg_temp.expect_error($q$
  insert into public.ticket_observations (collection_result_id, listing_id, observed_at, measurement_scope, measurement_origin, parser_version, normalizer_version)
  values (md5('result3')::uuid, md5('listing')::uuid, now(), 'unknown', 'unknown', 'test', 'test')
$q$, '42501', 'Client cannot insert history');
select pg_temp.expect_error('update public.user_follows set user_id = md5(''user-b'')::uuid', '42501', 'Relationship ownership cannot be reassigned');
select set_config('request.jwt.claim.sub', md5('user-b')::uuid::text, false);
select pg_temp.assert_true((select count(*) = 0 from public.user_follows), 'User B cannot read User A follows');
select pg_temp.assert_true((select count(*) = 0 from public.user_favorites), 'User B cannot read User A favorites');
delete from public.user_follows where user_id = md5('user-a')::uuid;
delete from public.user_favorites where user_id = md5('user-a')::uuid;
insert into public.user_follows (user_id, entity_id) values (auth.uid(), md5('artist')::uuid);
insert into public.user_favorites (user_id, entity_id) values (auth.uid(), md5('event')::uuid);
reset role;
select pg_temp.assert_true((select count(*) = 2 from public.user_follows), 'Two users follow the same shared entity');
select pg_temp.assert_true((select count(*) = 2 from public.user_favorites), 'Cross-user deletes did not remove favorites');
set role authenticated;
select set_config('request.jwt.claim.sub', md5('user-a')::uuid::text, false);
select pg_temp.assert_true((select count(*) = 1 from public.user_follows), 'User A cannot read User B follows');
select pg_temp.assert_true((select count(*) = 1 from public.user_favorites), 'User A cannot read User B favorites');
delete from public.user_follows where user_id = auth.uid();
delete from public.user_favorites where user_id = auth.uid();
reset role;
select pg_temp.assert_true((select count(*) = 2 from public.ticket_observations), 'Removing relationships preserves history');
delete from auth.users where id = md5('user-b')::uuid;
select pg_temp.assert_true((select count(*) = 0 from public.user_follows) and
  (select count(*) = 2 from public.ticket_observations) and (select count(*) = 4 from public.catalog_entities),
  'Deleting a new user cascades only relationships, not catalog/history');
set role anon;
select pg_temp.expect_error('select * from public.catalog_entities', '42501', 'Anonymous catalog access denied');
reset role;

select pg_temp.expect_error('delete from public.tracked_entities', '55000', 'Legacy tracking cascade is blocked');
select pg_temp.expect_error('delete from public.events', '55000', 'Legacy event deletion is blocked');
select pg_temp.expect_error('update public.ticket_snapshots set sold_count = 0', '55000', 'Legacy observations cannot be overwritten');
select pg_temp.expect_error('delete from auth.users where id = md5(''legacy-user'')::uuid', '55000', 'Legacy user deletion aborts atomically');
select pg_temp.expect_error('truncate public.tracked_entities cascade', '55000', 'TRUNCATE CASCADE cannot bypass protection');

\ir ../scripts/phase1_legacy_backfill.sql
\ir ../scripts/phase1_legacy_backfill.sql
select pg_temp.assert_true((select count(*) = 1 from public.legacy_tracking_map) and
  (select count(*) = 1 from public.legacy_event_map) and (select count(*) = 3 from public.legacy_snapshot_map),
  'Repeated inventory is idempotent');
select pg_temp.assert_true((select count(*) = 2 from public.ticket_observations), 'Unreviewed legacy data produces no guessed observations');
update public.legacy_tracking_map set entity_id = md5('artist')::uuid, mapping_status = 'approved',
  reviewed_at = now(), review_note = 'Fixture verified identity; not a name match';
update public.legacy_event_map set catalog_event_id = md5('event')::uuid, show_id = md5('show')::uuid,
  listing_id = md5('listing')::uuid, mapping_status = 'approved', reviewed_at = now(),
  review_note = 'Fixture verified source, external ID, performance and publication rights';
\ir ../scripts/phase1_legacy_backfill.sql
\ir ../scripts/phase1_legacy_backfill.sql
select pg_temp.assert_true((select count(*) = 4 from public.ticket_observations), 'Approved snapshot import is idempotent');
select pg_temp.expect_error($q$update public.legacy_snapshot_map set mapping_status = 'pending_review',
  observation_id = null, imported_at = null where legacy_snapshot_id = 1001$q$,
  '55000', 'Imported mapping cannot be reset to rewrite provenance');
select pg_temp.assert_true((select mapping_status = 'blocked' from public.legacy_snapshot_map where legacy_snapshot_id = 1003),
  'Invalid historical prices are preserved and flagged, not corrected');
select pg_temp.assert_true((select o.sold_count = 12 and o.capacity = 100 and o.min_price = 50 and o.max_price = 75
  and o.observed_at = '2026-09-01T10:00:00Z'::timestamptz and o.revenue is null and o.currency is null
  from public.ticket_observations o join public.legacy_snapshot_map m on m.observation_id = o.id where m.legacy_snapshot_id = 1001),
  'Legacy values and timestamp survive without invented currency/revenue');
select pg_temp.assert_true((select o.sold_count is null and o.capacity is null and o.occupancy is null
  from public.ticket_observations o join public.legacy_snapshot_map m on m.observation_id = o.id where m.legacy_snapshot_id = 1002),
  'Legacy unknowns remain NULL after import');
delete from public.user_follows where user_id = md5('legacy-user')::uuid;
\ir ../scripts/phase1_legacy_backfill.sql
select pg_temp.assert_true((select count(*) = 0 from public.user_follows where user_id = md5('legacy-user')::uuid),
  'Repeat import does not resurrect removed follows');
select pg_temp.assert_true(not exists (
  (select * from legacy_before except
    (select 'tracking', to_jsonb(t) from public.tracked_entities t union all
     select 'event', to_jsonb(e) from public.events e union all
     select 'snapshot', to_jsonb(s) from public.ticket_snapshots s))
  union all
  ((select 'tracking', to_jsonb(t) from public.tracked_entities t union all
    select 'event', to_jsonb(e) from public.events e union all
    select 'snapshot', to_jsonb(s) from public.ticket_snapshots s) except select * from legacy_before)
), 'All original legacy rows remain byte-equivalent as JSONB');
select pg_temp.assert_true((select count(*) = 19 from pg_tables where schemaname = 'public'
  and tablename not in ('tracked_entities', 'events', 'ticket_snapshots') and rowsecurity), 'All 19 new tables have RLS');
\echo PHASE1_ALL_TESTS_PASSED
