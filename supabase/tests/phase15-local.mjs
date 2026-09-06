// Real LOCAL Supabase HTTP integration tests. No npm dependencies.
// Credentials arrive via stdin from `supabase status --output json`; never log them.
import assert from 'node:assert/strict';
import { randomUUID } from 'node:crypto';
import { spawnSync } from 'node:child_process';
import { readFileSync, writeFileSync } from 'node:fs';
import { resolve, relative, isAbsolute } from 'node:path';
import { tmpdir } from 'node:os';

const input = JSON.parse(readFileSync(0, 'utf8').replace(/^\uFEFF/, ''));
const { mode, projectId, statePath, status } = input;
assert.match(projectId, /^biletify-phase15-[a-z0-9]+$/);
const stateRelative = relative(tmpdir(), resolve(statePath));
assert.ok(!stateRelative.startsWith('..') && !isAbsolute(stateRelative), 'State must stay in the OS temporary directory');
const api = new URL(status.API_URL);
assert.equal(api.protocol, 'http:');
assert.equal(api.hostname, '127.0.0.1');
assert.equal(api.port, '56321');
const anon = status.ANON_KEY;
const service = status.SERVICE_ROLE_KEY;
assert.ok(anon && service, 'Local CLI JWT keys required');
const container = `supabase_db_${projectId}`;
const password = 'Phase15-local-fixture-only-Aa7!';
const passed = [];
function pass(label) { passed.push(label); console.log(`PASS: ${label}`); }
function check(condition, label) { assert.ok(condition, label); pass(label); }

function db(sql) {
  const result = spawnSync('docker', ['exec', '-i', container, 'psql', '-X', '-A', '-t', '-U', 'postgres', '-d', 'postgres', '-v', 'ON_ERROR_STOP=1'],
    { input: sql, encoding: 'utf8', windowsHide: true });
  if (result.status !== 0) throw new Error(`Local SQL failed: ${result.stderr}`);
  return result.stdout.trim();
}
async function request(path, { method = 'GET', token = service, key = service, body, headers = {} } = {}) {
  const response = await fetch(new URL(path, api), {
    method,
    redirect: 'error',
    signal: AbortSignal.timeout(20000),
    headers: { apikey: key, Authorization: `Bearer ${token}`, 'Content-Type': 'application/json', ...headers },
    body: body === undefined ? undefined : JSON.stringify(body),
  });
  const text = await response.text();
  let data;
  try { data = text ? JSON.parse(text) : null; } catch { data = { message: text.slice(0, 200) }; }
  return { status: response.status, data };
}
function expect(response, expected, label) {
  assert.equal(response.status, expected, `${label}: HTTP ${response.status}, code ${response.data?.code ?? response.data?.error_code ?? 'none'}`);
  return response.data;
}
const rest = (table, options) => request(`/rest/v1/${table}`, options);
const client = token => ({ token, key: anon });
async function insert(table, body, options = {}) {
  return expect(await rest(table, { method: 'POST', body, headers: { Prefer: 'return=representation' }, ...options }), 201, `Insert ${table}`);
}
async function rows(table, options = {}) { return expect(await rest(table, options), 200, `Read ${table}`); }
async function login(email) {
  const result = expect(await request('/auth/v1/token?grant_type=password', {
    ...client(anon), method: 'POST', body: { email, password },
  }), 200, 'Auth password login');
  assert.ok(result.access_token && result.refresh_token && result.user?.id);
  return result;
}
async function createUser(name) {
  const email = `phase15-${name}@example.test`;
  const user = expect(await request('/auth/v1/admin/users', {
    method: 'POST', body: { email, password, email_confirm: true },
  }), 200, 'Auth admin create user');
  return { id: user.id, email };
}
async function legacyRows() {
  return {
    tracking: await rows('tracked_entities?order=id'),
    events: await rows('events?order=id'),
    snapshots: await rows('ticket_snapshots?order=id'),
  };
}
function migrationVersions() {
  return JSON.parse(db("select coalesce(json_agg(version order by version),'[]'::json) from supabase_migrations.schema_migrations;"));
}

if (mode === 'clean') {
  assert.deepEqual(migrationVersions(), ['20260904000000', '20260905191100']);
  pass('CLI clean migration history contains initial then Phase 1');
  check(db("select count(*) from pg_tables where schemaname='public' and rowsecurity;") === '22', 'All 22 application tables exist with RLS on real Supabase');
  check(db('select count(*) from auth.users;') === '0', 'Clean Supabase Auth database has no fixture users');
  check((await rows('catalog_entities')).length === 0, 'PostgREST exposes clean catalog to local backend');
  writeFileSync(statePath, JSON.stringify({ cleanAssertions: passed }, null, 2));
} else if (mode === 'legacy-setup') {
  assert.deepEqual(migrationVersions(), ['20260904000000']);
  pass('CLI reset to initial migration verified before legacy fixtures');
  const legacyUser = await createUser('legacy');
  const session = await login(legacyUser.email);
  const tracking = (await insert('tracked_entities', { user_id: legacyUser.id, name: 'Legacy unmerged fixture' }, client(session.access_token)))[0];
  const event = (await insert('events', {
    tracked_entity_id: tracking.id, external_id: 'phase15-legacy-event', source: 'fixture-only',
    title: 'Legacy fixture event', starts_at: '2026-09-10T18:00:00Z',
  }))[0];
  await insert('ticket_snapshots', [
    { event_id: event.id, captured_at: '2026-09-01T10:00:00Z', sold_count: 12, capacity: 100, price_min: 50, price_max: 75, raw_payload: { fixture: true } },
    { event_id: event.id, captured_at: '2026-09-02T10:00:00Z', sold_count: null, capacity: null, price_min: null, price_max: null, raw_payload: { unknown: true } },
  ]);
  const previous = JSON.parse(readFileSync(statePath, 'utf8'));
  pass('Real Auth user and legacy data created through HTTP before Phase 1');
  writeFileSync(statePath, JSON.stringify({ ...previous, legacyUser, before: await legacyRows(), setupAssertions: passed }, null, 2));
} else if (mode === 'validate') {
  const state = JSON.parse(readFileSync(statePath, 'utf8'));
  assert.deepEqual(migrationVersions(), ['20260904000000', '20260905191100']);
  pass('CLI incremental upgrade applied Phase 1 after initial migration');
  assert.deepEqual(await legacyRows(), state.before);
  pass('Legacy rows, raw payloads and timestamps unchanged by upgrade');

  const userA = await createUser('a');
  const userB = await createUser('b');
  const deleteUser = await createUser('delete-new');
  const sessionA = await login(userA.email);
  const sessionB = await login(userB.email);
  const a = client(sessionA.access_token);
  const b = client(sessionB.access_token);
  const legacySession = await login(state.legacyUser.email);
  const legacy = client(legacySession.access_token);
  check(expect(await request('/auth/v1/user', a), 200, 'Auth current user').id === userA.id,
    'Real Auth password token identifies User A');
  const refreshed = expect(await request('/auth/v1/token?grant_type=refresh_token', {
    ...client(anon), method: 'POST', body: { refresh_token: sessionA.refresh_token },
  }), 200, 'Auth refresh');
  check(refreshed.user.id === userA.id && !!refreshed.access_token, 'Real Auth refresh succeeds');
  a.token = refreshed.access_token;
  const now = new Date().toISOString();
  const artistId = randomUUID(), eventId = randomUUID(), showId = randomUUID(), draftId = randomUUID();
  await insert('catalog_entities', [
    { id: artistId, entity_kind: 'artist', display_name: 'Shared test artist', publication_status: 'published' },
    { id: eventId, entity_kind: 'event', display_name: 'Shared test event', publication_status: 'published' },
    { id: showId, entity_kind: 'show', display_name: 'Shared test performance', publication_status: 'published' },
    { id: draftId, entity_kind: 'artist', display_name: 'Unpublished fixture', publication_status: 'draft' },
  ]);
  await insert('artists', { id: artistId });
  await insert('catalog_events', { id: eventId, event_type: 'future-fixture-type' });
  await insert('event_participants', { event_id: eventId, artist_id: artistId });
  const venue = (await insert('venues', { name: 'Fixture venue', publication_status: 'published' }))[0];
  const space = (await insert('venue_spaces', { venue_id: venue.id, name: 'Fixture hall' }))[0];
  await insert('shows', { id: showId, event_id: eventId, venue_id: venue.id, venue_space_id: space.id, starts_at: now });
  const provider = (await insert('providers', { code: 'phase15-fixture', name: 'Not a live provider', is_published: true }))[0];
  const listing = (await insert('provider_listings', {
    provider_id: provider.id, show_id: showId, external_id: 'phase15-shared', publication_status: 'published', data_access: 'shared',
  }))[0];
  await insert('provider_listings', { provider_id: provider.id, show_id: showId, external_id: 'phase15-restricted', publication_status: 'published' });
  check((await rows('catalog_entities', a)).length === 3, 'Authenticated catalog read hides drafts');
  for (const table of ['artists', 'catalog_events', 'event_participants', 'shows', 'venues', 'venue_spaces', 'providers', 'provider_listings']) {
    check((await rows(table, a)).length === 1, `Published ${table} accessible through PostgREST`);
  }
  check((await rows(`catalog_entities?id=eq.${draftId}`, a)).length === 0, 'Direct draft ID lookup remains hidden');
  const hidden = await insert('user_follows', { user_id: userA.id, entity_id: artistId }, a);
  check(hidden[0].user_id === userA.id, 'User A inserts own follow with Auth JWT');
  await insert('user_follows', { user_id: userB.id, entity_id: artistId }, b);
  await insert('user_favorites', { user_id: userA.id, entity_id: eventId }, a);
  await insert('user_favorites', { user_id: userB.id, entity_id: eventId }, b);
  check((await rows(`user_follows?entity_id=eq.${artistId}`)).length === 2, 'Two authenticated users independently follow one shared entity');
  for (const [table, entityId] of [['user_follows', artistId], ['user_favorites', eventId]]) {
    check((await rows(table, a)).every(row => row.user_id === userA.id) && (await rows(table, a)).length === 1,
      `${table}: User A sees only own row`);
    check((await rows(table, b)).every(row => row.user_id === userB.id) && (await rows(table, b)).length === 1,
      `${table}: User B sees only own row`);
    check((await rows(`${table}?user_id=eq.${userB.id}`, a)).length === 0, `${table}: direct cross-user SELECT returns empty`);
    const forbiddenInsert = await rest(table, { ...a, method: 'POST', body: { user_id: userB.id, entity_id: showId } });
    check(forbiddenInsert.status === 403 && forbiddenInsert.data.code === '42501', `${table}: cross-user INSERT rejected`);
    const forbiddenPatch = await rest(`${table}?user_id=eq.${userB.id}`, { ...a, method: 'PATCH', body: { entity_id: showId } });
    check(forbiddenPatch.status === 403 && forbiddenPatch.data.code === '42501', `${table}: cross-user UPDATE rejected`);
    const deleted = expect(await rest(`${table}?user_id=eq.${userB.id}`, {
      ...a, method: 'DELETE', headers: { Prefer: 'return=representation' },
    }), 200, 'Cross-user delete');
    check(deleted.length === 0 && (await rows(`${table}?user_id=eq.${userB.id}`, b)).length === 1,
      `${table}: cross-user DELETE affects zero rows`);
  }
  const draftFollow = await rest('user_follows', { ...a, method: 'POST', body: { user_id: userA.id, entity_id: draftId } });
  check(draftFollow.status === 403 && draftFollow.data.code === '42501', 'Cannot follow unpublished catalog entity');

  const job = (await insert('ingestion_jobs', { provider_id: provider.id, listing_id: listing.id, idempotency_key: randomUUID(), job_kind: 'collection' }))[0];
  async function attempt(number, success) {
    return (await insert('collection_attempts', {
      job_id: job.id, provider_id: provider.id, attempt_number: number, status: success ? 'succeeded' : 'failed',
      started_at: now, finished_at: now, error_code: success ? null : 'fixture_timeout',
    }))[0];
  }
  async function result(attemptRow) {
    return (await insert('collection_results', {
      attempt_id: attemptRow.id, provider_id: provider.id, attempt_status: attemptRow.status, listing_id: listing.id,
      status: attemptRow.status, collected_at: now, error_code: attemptRow.error_code, raw_payload: { fixture: true },
    }))[0];
  }
  const successful = await result(await attempt(1, true));
  const failed = await result(await attempt(2, false));
  const observationBody = resultId => ({
    collection_result_id: resultId, listing_id: listing.id, observed_at: now,
    measurement_scope: 'unknown', measurement_origin: 'unknown', parser_version: 'phase15-fixture', normalizer_version: 'phase15-fixture',
  });
  const observation = (await insert('ticket_observations', observationBody(successful.id)))[0];
  const nullMetrics = ['sold_count', 'capacity', 'occupancy', 'min_price', 'max_price', 'revenue'];
  check(nullMetrics.every(field => Object.hasOwn(observation, field) && observation[field] === null), 'PostgREST INSERT representation preserves all six NULL metrics');
  const observedRead = (await rows(`ticket_observations?id=eq.${observation.id}`))[0];
  check(nullMetrics.every(field => Object.hasOwn(observedRead, field) && observedRead[field] === null), 'PostgREST backend GET preserves explicit JSON null metrics');
  check(db(`select sold_count is null and capacity is null and occupancy is null and min_price is null and max_price is null and revenue is null from public.ticket_observations where id='${observation.id}';`) === 't',
    'Underlying Supabase PostgreSQL metrics remain SQL NULL');
  const tier = (await insert('ticket_observation_tiers', { observation_id: observation.id, tier_key: 'standard', name: 'Standard' }))[0];
  check(tier.price === null && tier.sold_count === null && tier.capacity === null, 'Tier unknowns stay null');
  const fake = await rest('ticket_observations', { method: 'POST', body: {
    ...observationBody(failed.id), sold_count: 0, capacity: 0, occupancy: 0, availability: 'sold_out',
  } });
  check(fake.status === 409 && fake.data.code === '23503', 'Failed collection cannot create fake zeros or sold_out through PostgREST');
  check((await rows(`ticket_observations?collection_result_id=eq.${failed.id}`)).length === 0, 'Failed collection has no observation row');
  const duplicate = await rest('ticket_observations', { method: 'POST', body: observationBody(successful.id) });
  check(duplicate.status === 409 && duplicate.data.code === '23505', 'PostgREST replay cannot duplicate a successful observation');
  const later = await result(await attempt(3, true));
  await insert('ticket_observations', { ...observationBody(later.id), observed_at: new Date().toISOString() });
  check((await rows('ticket_observations')).length === 2, 'Later legitimate collection creates a separate observation');

  const forbiddenTables = ['catalog_entities', 'artists', 'catalog_events', 'event_participants', 'shows', 'venues', 'venue_spaces',
    'providers', 'provider_listings', 'ingestion_jobs', 'collection_attempts', 'collection_results', 'ticket_observations',
    'ticket_observation_tiers', 'legacy_tracking_map', 'legacy_event_map', 'legacy_snapshot_map'];
  for (const table of forbiddenTables) {
    const response = await rest(table, { ...a, method: 'POST', body: {} });
    check(response.status === 403 && response.data.code === '42501', `Authenticated INSERT denied on ${table}`);
  }
  const noFilter = await rest('catalog_entities', { ...a, method: 'PATCH', body: { display_name: 'forbidden' } });
  check(noFilter.status === 400 && noFilter.data.code === '21000', 'Supabase safeupdate rejects unfiltered UPDATE before privilege checks');
  for (const [table, body, id] of [['catalog_entities', { display_name: 'forbidden' }, artistId], ['providers', { name: 'forbidden' }, provider.id],
    ['ingestion_jobs', { status: 'failed' }, job.id], ['ticket_observations', { sold_count: 0 }, observation.id]]) {
    const patch = await rest(`${table}?id=eq.${id}`, { ...a, method: 'PATCH', body });
    check(patch.status === 403 && patch.data.code === '42501', `Authenticated UPDATE denied on ${table}`);
    const deletion = await rest(`${table}?id=eq.${id}`, { ...a, method: 'DELETE' });
    check(deletion.status === 403 && deletion.data.code === '42501', `Authenticated DELETE denied on ${table}`);
  }
  check(db("select count(*) from information_schema.role_table_grants where table_schema='public' and grantee='authenticated' and privilege_type in ('INSERT','UPDATE','DELETE','TRUNCATE') and table_name not in ('tracked_entities','events','ticket_snapshots','user_follows','user_favorites');") === '0',
    'Authenticated role has no mutation grants on any shared, operational, mapping or history table');
  const anonymousRead = await rest('catalog_entities', client(anon));
  check(anonymousRead.status === 401 && anonymousRead.data.code === '42501', 'Anonymous catalog access denied');
  const historyRead = await rest('ticket_observations', a);
  check(historyRead.status === 403 && historyRead.data.code === '42501', 'Authenticated history read remains intentionally backend-only');
  const rawRead = await rest('collection_results', a);
  check(rawRead.status === 403 && rawRead.data.code === '42501', 'Authenticated clients cannot read raw collection results');

  const ownDelete = expect(await rest(`user_follows?entity_id=eq.${artistId}`, { ...a, method: 'DELETE', headers: { Prefer: 'return=representation' } }), 200, 'Own unfollow');
  check(ownDelete.length === 1 && (await rows('ticket_observations')).length === 2 && (await rows(`catalog_entities?id=eq.${artistId}`)).length === 1,
    'Own unfollow leaves shared catalog and observations intact');
  await insert('user_follows', { user_id: deleteUser.id, entity_id: artistId });
  await insert('user_favorites', { user_id: deleteUser.id, entity_id: eventId });
  expect(await request(`/auth/v1/admin/users/${deleteUser.id}`, { method: 'DELETE', body: { should_soft_delete: false } }), 200, 'Delete user with new relationships only');
  check((await rows(`user_follows?user_id=eq.${deleteUser.id}`)).length === 0 &&
    (await rows(`user_favorites?user_id=eq.${deleteUser.id}`)).length === 0 && (await rows('ticket_observations')).length === 2,
    'Real Auth hard deletion of new-only user removes relationships and preserves history');

  const legacyVisible = await rows('ticket_snapshots?order=id', legacy);
  assert.deepEqual(legacyVisible, state.before.snapshots);
  pass('Legacy owner still reads original snapshots via Auth JWT and old RLS');
  check((await rows('ticket_snapshots', a)).length === 0, 'New User A cannot read legacy user snapshots');
  const deleteLegacy = await request(`/auth/v1/admin/users/${state.legacyUser.id}`, { method: 'DELETE', body: { should_soft_delete: false } });
  check(deleteLegacy.status === 500, 'Real Auth hard deletion of legacy owner is blocked (HTTP 500)');
  const authAfter = expect(await request(`/auth/v1/admin/users/${state.legacyUser.id}`), 200, 'Read user after blocked deletion');
  check(authAfter.id === state.legacyUser.id && !authAfter.deleted_at, 'Blocked deletion leaves Auth account intact');
  check(expect(await request('/auth/v1/user', legacy), 200, 'Existing legacy session').id === state.legacyUser.id,
    'Legacy session remains valid after blocked deletion');
  await login(state.legacyUser.email);
  pass('Legacy account can still sign in after blocked deletion');
  assert.deepEqual(await legacyRows(), state.before);
  pass('Blocked Auth deletion leaves every original legacy row intact');
  const softUnfollow = await rest(`tracked_entities?id=eq.${state.before.tracking[0].id}`, {
    ...legacy, method: 'PATCH', body: { is_active: false }, headers: { Prefer: 'return=representation' },
  });
  check(expect(softUnfollow, 200, 'Legacy logical unfollow')[0].is_active === false, 'Legacy is_active=false works under actual Auth/RLS');
  assert.deepEqual((await legacyRows()).snapshots, state.before.snapshots);
  pass('Legacy logical unfollow preserves historical snapshots');
  const deleteInactive = await request(`/auth/v1/admin/users/${state.legacyUser.id}`, { method: 'DELETE', body: { should_soft_delete: false } });
  check(deleteInactive.status === 500, 'Inactive legacy tracking still blocks physical Auth deletion');
  writeFileSync(statePath, JSON.stringify({ ...state, validationAssertions: passed,
    authDelete: { status: deleteLegacy.status, errorCode: deleteLegacy.data?.error_code ?? deleteLegacy.data?.code, message: deleteLegacy.data?.msg ?? deleteLegacy.data?.message },
    inactiveDeleteStatus: deleteInactive.status,
  }, null, 2));
} else {
  throw new Error('Unknown local test mode');
}
console.log(`PHASE15_${mode.toUpperCase().replaceAll('-', '_')}_PASSED (${passed.length} assertions)`);
