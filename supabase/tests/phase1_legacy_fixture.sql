\set ON_ERROR_STOP on
insert into auth.users (id) values (md5('legacy-user')::uuid);
insert into public.tracked_entities (id, user_id, name)
values (md5('legacy-tracking')::uuid, md5('legacy-user')::uuid, 'Ambiguous Artist');
insert into public.events (id, tracked_entity_id, external_id, source, title, starts_at)
values (md5('legacy-event')::uuid, md5('legacy-tracking')::uuid, 'legacy-external', 'fixture', 'Ambiguous Event', '2026-09-10T18:00:00Z');
insert into public.ticket_snapshots (id, event_id, captured_at, sold_count, capacity, price_min, price_max, raw_payload)
overriding system value values
  (1001, md5('legacy-event')::uuid, '2026-09-01T10:00:00Z', 12, 100, 50, 75, '{"original":true}'),
  (1002, md5('legacy-event')::uuid, '2026-09-02T10:00:00Z', null, null, null, null, '{}'),
  (1003, md5('legacy-event')::uuid, '2026-09-03T10:00:00Z', null, null, -5, 10, '{"invalid_legacy_price":true}');
-- Survive through the same psql session to detect any source changes.
create temporary table legacy_before as
select 'tracking' as kind, to_jsonb(t) as row_data from public.tracked_entities t
union all select 'event', to_jsonb(e) from public.events e
union all select 'snapshot', to_jsonb(s) from public.ticket_snapshots s;
