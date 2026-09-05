# Biletify

## Project Goal
Biletify is a ticket discovery, tracking and reporting platform.

The system aggregates event and ticket information from multiple providers such as Biletix, Bubilet, Biletinial and similar platforms.

Initial MVP focus:
- Turkey
- Events and artists
- Ticket availability
- Ticket prices
- Occupancy / sales indicators when available
- Historical snapshots
- Daily changes and reporting

The system must be designed so that new artists, events, films and ticket providers can be added later without architectural rewrites.

## Stack

### Mobile
- Flutter
- Dart
- Android
- iOS

### Web
- Next.js
- TypeScript

### Backend
- Supabase
- PostgreSQL

### Infrastructure
- GitHub
- Docker
- Vercel

## Repository Structure

- `/app` → Next.js web application
- `/mobile` → Flutter mobile application
- `/design` → design source files and Claude Design outputs
- `/supabase` → database migrations and backend configuration

Do not mix web and mobile implementations.

## Architecture Rules

- Preserve the existing architecture.
- Do not rewrite working modules unnecessarily.
- Inspect only files relevant to the requested task before coding.
- Avoid scanning the entire repository unless necessary.
- Reuse existing components and services.
- Do not introduce new dependencies without justification.
- Prefer small, reviewable changes.
- Do not perform broad refactors unless explicitly requested.
- Do not rename or move working files without a clear reason.
- Maintain backward compatibility whenever possible.

## Mobile Architecture

Flutter mobile code must remain inside `/mobile`.

Use:
- Feature-first architecture
- Repository pattern
- Clear separation between UI, domain and data layers
- Reusable widgets
- Centralized design system

Do not place scraping logic directly inside the Flutter application.

The mobile application should consume normalized backend data.

## Web Architecture

The Next.js application is primarily for:
- Dashboard
- Administration
- Reporting
- Event / artist management
- Provider monitoring

Do not duplicate mobile business logic unnecessarily.

Shared business rules should live in backend/database services when appropriate.

## Backend Architecture

Supabase is the central backend.

Core entities should support:
- Users
- Artists
- Events
- Venues
- Ticket providers
- Event-provider relationships
- Prices
- Ticket availability
- Historical snapshots
- User follows / favorites
- Reports

Use PostgreSQL migrations for schema changes.

Never make destructive database changes without explicitly explaining the impact first.

## Ticket Data Sources

Ticket providers may initially be accessed through:
- Official APIs
- Approved third-party APIs
- Temporary scraping / crawling during development

Provider-specific logic must be isolated behind adapters or services.

Example:

TicketProvider
- BiletixProvider
- BubiletProvider
- BiletinialProvider

Do not tightly couple the application to one provider.

If one provider changes, the rest of the system should continue working.

## Data Flow

Preferred architecture:

Ticket Provider / API / Crawler
↓
Backend ingestion layer
↓
Normalization
↓
Supabase PostgreSQL
↓
Web + Flutter applications

Do NOT build the architecture as:

Flutter
↓
Direct scraping of ticket websites

## Historical Data

Ticket and availability data should support snapshots over time.

Never overwrite historical observations when a new snapshot should be created.

The system must support:
- Daily changes
- Price changes
- Availability changes
- Occupancy changes when measurable
- Provider status changes

## Error Handling

External ticket providers are unreliable dependencies.

The system must detect and report:
- API failures
- Scraper failures
- HTML structure changes
- Bot / Cloudflare blocking
- Missing events
- Invalid prices
- Duplicate events
- Stale data

Never silently convert a provider failure into valid-looking data.

Store or expose data freshness information where appropriate.

## UI / Design

Existing Claude Design screens are the design source of truth unless explicitly changed.

Rules:
- Reusable design system
- Responsive layouts
- Android and iOS compatibility
- Consistent typography
- Consistent spacing
- Consistent colors
- Reusable cards, buttons and navigation components

Do not redesign working screens unless requested.

When converting a design to Flutter:
- Preserve visual hierarchy
- Preserve spacing
- Preserve typography
- Preserve component behavior
- Prefer reusable widgets over duplicated screen code

## Coding Workflow

Before implementation:

1. Understand the requested task.
2. Inspect only relevant files.
3. Explain any architectural risk.
4. Reuse existing implementation where possible.

During implementation:

1. Make the smallest safe change.
2. Preserve existing behavior.
3. Avoid unrelated refactoring.
4. Follow existing naming and folder conventions.

After implementation:

1. Run formatting.
2. Run static analysis.
3. Run relevant tests.
4. Verify the application still builds.
5. Summarize exactly what changed.

## Flutter Validation

When changing Flutter code, run where applicable:

```bash
flutter pub get
flutter analyze
flutter test