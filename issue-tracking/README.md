# Issue tracking

Local [It's a Plan](https://itsaplan.dev) instance used to plan DevOps Sandbox. The decision, requirements and the model are in [ISSUE-TRACKING.md](../ISSUE-TRACKING.md).

## Requirements

- Docker with Compose v2
- `git`, `curl`, `python3`

## Commands

```bash
./issue-tracking/itsaplan.sh install      # clone the pinned version, generate secrets
./issue-tracking/itsaplan.sh start        # start and wait for the API
./issue-tracking/itsaplan.sh status
./issue-tracking/itsaplan.sh logs [api]
./issue-tracking/itsaplan.sh backup       # database + attachments + .env
./issue-tracking/itsaplan.sh restore <dir>
./issue-tracking/itsaplan.sh upgrade 1.10.0
./issue-tracking/itsaplan.sh stop
./issue-tracking/itsaplan.sh destroy      # removes containers and data volumes
```

Web: <http://localhost:3001>. API: <http://localhost:3000> (reference at `/docs`).

## Where things live

Nothing here is committed. Everything is under `.local/`, which is git-ignored.

- `.local/itsaplan/` - the cloned release, `.env` with generated secrets, and `api-token`.
- `.local/backups/itsaplan/<timestamp>/` - `db.dump`, `files.tgz`, `env`, `version`. The newest 14 are kept (`KEEP_BACKUPS`).
- Data volumes: `itsaplan_postgres-data`, `itsaplan_minio-data`, `itsaplan_db-backups`.

## Notes

- The version is pinned in `.env` (`VERSION`) and the clone is checked out at the matching git tag. The project is young and may have breaking changes, so upgrade deliberately: `upgrade` takes a backup first.
- Keep the `env` file from a backup. `APP_ENCRYPTION_KEY` is needed to decrypt stored credentials after a restore.
- Telemetry is disabled (`TELEMETRY_DISABLED=1`).
- The first account registered becomes the instance admin. Close registration afterwards in god mode under **Authentication**.
- API calls use the `x-api-key` header. The API is rate limited and answers 429 as 500 under bursts, so scripts need a pause and retry.
- A personal API key is created under Account settings and can be kept in `.local/itsaplan/api-token`.
