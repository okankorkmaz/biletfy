-- Explicit, privileged operation; NOT automatically executed by migrations.
-- First pass inventories pending mappings only. No name-based matching.
-- Review and approve tracking/event mappings before a later pass can import.
begin;
set local lock_timeout = '5s';
set local statement_timeout = '120s';
select pg_advisory_xact_lock(5192026, 1);

insert into public.legacy_tracking_map (legacy_tracking_id)
select id from public.tracked_entities on conflict (legacy_tracking_id) do nothing;
insert into public.legacy_event_map (legacy_event_id)
select id from public.events on conflict (legacy_event_id) do nothing;
insert into public.legacy_snapshot_map (legacy_snapshot_id)
select id from public.ticket_snapshots on conflict (legacy_snapshot_id) do nothing;

-- Record completion even for inactive relationships. A repeat run must not
-- resurrect a follow the user deliberately removed after the first import.
insert into public.user_follows (user_id, entity_id, created_at)
select t.user_id, m.entity_id, t.created_at
from public.legacy_tracking_map m
join public.tracked_entities t on t.id = m.legacy_tracking_id
where m.mapping_status = 'approved' and m.relationship_imported_at is null and t.is_active
on conflict (user_id, entity_id) do nothing;
update public.legacy_tracking_map set relationship_imported_at = now()
where mapping_status = 'approved' and relationship_imported_at is null;

do $$
declare
  item record;
  job_uuid uuid;
  attempt_uuid uuid;
  result_uuid uuid;
  observation_uuid uuid;
begin
  for item in
    select s.*, m.listing_id, l.provider_id, l.external_id as mapped_external_id,
           e.external_id as legacy_external_id
    from public.ticket_snapshots s
    join public.events e on e.id = s.event_id
    join public.legacy_event_map m on m.legacy_event_id = e.id and m.mapping_status = 'approved'
    join public.provider_listings l on l.id = m.listing_id
    join public.legacy_snapshot_map sm on sm.legacy_snapshot_id = s.id
    where sm.mapping_status = 'pending_review'
    order by s.id
    limit 1000
  loop
    begin
      if item.mapped_external_id <> item.legacy_external_id then
        raise check_violation using message = 'External listing ID mismatch; manual review required';
      end if;
      insert into public.ingestion_jobs (provider_id, listing_id, idempotency_key, job_kind, status)
      values (item.provider_id, item.listing_id, 'legacy-snapshot:' || item.id, 'legacy_import', 'succeeded')
      returning id into job_uuid;
      insert into public.collection_attempts (job_id, provider_id, attempt_number, status, finished_at)
      values (job_uuid, item.provider_id, 1, 'succeeded', now()) returning id into attempt_uuid;
      insert into public.collection_results (
        attempt_id, provider_id, attempt_status, listing_id, status, result_origin,
        collected_at, raw_payload, metadata
      ) values (
        attempt_uuid, item.provider_id, 'succeeded', item.listing_id, 'succeeded', 'legacy_import',
        item.captured_at, item.raw_payload,
        jsonb_build_object('legacy_snapshot_id', item.id, 'legacy_event_id', item.event_id,
          'legacy_availability_status', item.availability_status,
          'provenance', 'Historical import; original provider collection outcome is unknown')
      ) returning id into result_uuid;
      insert into public.ticket_observations (
        collection_result_id, listing_id, observed_at, measurement_scope, measurement_origin,
        parser_version, normalizer_version, sold_count, capacity, min_price, max_price,
        quality_metadata, freshness_metadata
      ) values (
        result_uuid, item.listing_id, item.captured_at, 'unknown', 'unknown',
        'legacy-unknown', 'legacy-import-v1', item.sold_count, item.capacity, item.price_min, item.price_max,
        jsonb_build_object('legacy_snapshot_id', item.id, 'currency', 'unknown',
          'availability', 'unmapped; original value preserved in collection result',
          'original_collection_outcome', 'unknown'),
        jsonb_build_object('imported_history', true)
      ) returning id into observation_uuid;
      update public.legacy_snapshot_map
      set observation_id = observation_uuid, mapping_status = 'imported', imported_at = now(),
          review_note = 'Imported through explicitly approved event mapping; original row retained.'
      where legacy_snapshot_id = item.id;
    exception when check_violation or numeric_value_out_of_range then
      -- The inner subtransaction removes partial new writes, never the source.
      update public.legacy_snapshot_map set mapping_status = 'blocked', review_note = sqlerrm
      where legacy_snapshot_id = item.id;
    end;
  end loop;
end;
$$;
commit;
