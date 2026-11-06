#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RUNTIME_DIR="${ROOT_DIR}/.local/itsaplan"
BACKUP_DIR="${ROOT_DIR}/.local/backups/itsaplan"
ENV_FILE="${RUNTIME_DIR}/.env"
REPO_URL="https://github.com/croffasia/itsaplan.git"
DEFAULT_VERSION="1.10.0"
PROJECT="itsaplan"
KEEP_BACKUPS="${KEEP_BACKUPS:-14}"

usage() {
  cat <<EOF
Usage: $0 <command> [args]

Commands:
  install              Clone It's a Plan ${DEFAULT_VERSION}, generate secrets, write .env
  start                Start the stack and wait until it is healthy
  stop                 Stop and remove the containers (data volumes are kept)
  restart              Stop, then start
  status               Show container status and installed version
  logs [service]       Follow all logs or one service (api, web, worker, bot, postgres, minio)
  backup               Back up database, attachments and .env (keeps the last ${KEEP_BACKUPS})
  restore <dir>        Restore a backup made by 'backup' (replaces current data)
  upgrade [version]    Back up, switch to a version (default ${DEFAULT_VERSION}) and restart
  open                 Open the web UI
  url                  Print the web and API URLs
  destroy              Remove containers, volumes and the runtime directory
EOF
}

env_value() {
  grep -E "^$1=" "${ENV_FILE}" | tail -1 | cut -d= -f2-
}

set_env() {
  python3 - "${ENV_FILE}" "$1" "$2" <<'PY'
import re, sys
path, key, value = sys.argv[1:4]
text = open(path).read()
line = f"{key}={value}"
if re.search(rf"^{key}=.*$", text, flags=re.M):
    text = re.sub(rf"^{key}=.*$", line, text, flags=re.M)
else:
    text = text.rstrip("\n") + "\n" + line + "\n"
open(path, "w").write(text)
PY
}

require_install() {
  if [[ ! -f "${ENV_FILE}" || ! -f "${RUNTIME_DIR}/docker-compose.yml" ]]; then
    echo "It's a Plan is not installed. Run: $0 install" >&2
    exit 1
  fi
}

compose() {
  (cd "${RUNTIME_DIR}" && docker compose -p "${PROJECT}" "$@")
}

web_url() { env_value APP_URL; }
api_url() { env_value API_URL; }

wait_healthy() {
  local url
  url="$(api_url)/"
  printf 'Waiting for the API at %s ' "${url}"
  for _ in $(seq 1 60); do
    if curl -fsS -o /dev/null "${url}"; then
      echo "ok"
      return 0
    fi
    printf '.'
    sleep 2
  done
  echo
  echo "The API did not become healthy. Check: $0 logs api" >&2
  exit 1
}

generate_env() {
  python3 - "${RUNTIME_DIR}/.env.example" "${ENV_FILE}" "$1" <<'PY'
import base64, re, secrets, sys
src, dst, version = sys.argv[1:4]
text = open(src).read()
def put(key, value):
    global text
    text = re.sub(rf"^{key}=.*$", lambda _: f"{key}={value}", text, flags=re.M)
put("POSTGRES_PASSWORD", secrets.token_urlsafe(24))
put("BETTER_AUTH_SECRET", base64.b64encode(secrets.token_bytes(32)).decode())
put("APP_ENCRYPTION_KEY", base64.b64encode(secrets.token_bytes(32)).decode())
put("S3_ACCESS_KEY_ID", "itsaplan" + secrets.token_hex(4))
put("S3_SECRET_ACCESS_KEY", secrets.token_urlsafe(24))
text = text.rstrip("\n") + f"\nVERSION={version}\nTELEMETRY_DISABLED=1\n"
open(dst, "w").write(text)
PY
  chmod 600 "${ENV_FILE}"
}

install_itsaplan() {
  local version="${1:-${DEFAULT_VERSION}}"
  if [[ -f "${ENV_FILE}" ]]; then
    echo "Already installed in ${RUNTIME_DIR}. Use '$0 upgrade' to change the version."
    exit 0
  fi
  mkdir -p "${ROOT_DIR}/.local"
  git clone --depth 1 --branch "v${version}" "${REPO_URL}" "${RUNTIME_DIR}"
  generate_env "${version}"
  echo "Installed It's a Plan ${version}. Start it with: $0 start"
}

start_itsaplan() {
  require_install
  compose up -d
  wait_healthy
  echo "Web: $(web_url)"
  echo "API: $(api_url) (reference: $(api_url)/docs)"
}

backup_itsaplan() {
  require_install
  local stamp target
  stamp="$(date +%Y%m%d-%H%M%S)"
  target="${BACKUP_DIR}/${stamp}"
  mkdir -p "${target}"
  chmod 700 "${BACKUP_DIR}" "${target}"

  local pg_user pg_db
  pg_user="$(env_value POSTGRES_USER)"; pg_user="${pg_user:-itsaplan}"
  pg_db="$(env_value POSTGRES_DB)"; pg_db="${pg_db:-itsaplan}"

  echo "Dumping database ${pg_db}..."
  compose exec -T postgres pg_dump -U "${pg_user}" -Fc "${pg_db}" > "${target}/db.dump"

  echo "Archiving attachments..."
  docker run --rm -v "${PROJECT}_minio-data:/data:ro" -v "${target}:/backup" alpine \
    tar czf /backup/files.tgz -C /data .

  # The encryption key in .env is required to read stored credentials after a restore.
  cp "${ENV_FILE}" "${target}/env"
  chmod 600 "${target}/env" "${target}/db.dump" "${target}/files.tgz"
  echo "$(env_value VERSION)" > "${target}/version"

  echo "Backup written to ${target}"
  # Keep only the newest KEEP_BACKUPS backups.
  # shellcheck disable=SC2012
  ls -1dt "${BACKUP_DIR}"/*/ 2>/dev/null | tail -n +"$((KEEP_BACKUPS + 1))" | while read -r old; do
    rm -rf "${old}"
  done
}

restore_itsaplan() {
  require_install
  local source="${1:-}"
  if [[ -z "${source}" || ! -f "${source}/db.dump" || ! -f "${source}/files.tgz" ]]; then
    echo "Usage: $0 restore <backup-dir> (a directory made by '$0 backup')" >&2
    exit 1
  fi
  echo "This replaces the current database and attachments with ${source}."
  read -r -p "Type 'restore' to continue: " answer
  [[ "${answer}" == "restore" ]] || { echo "Aborted."; exit 1; }

  local pg_user pg_db
  pg_user="$(env_value POSTGRES_USER)"; pg_user="${pg_user:-itsaplan}"
  pg_db="$(env_value POSTGRES_DB)"; pg_db="${pg_db:-itsaplan}"

  compose up -d postgres minio
  compose stop api worker bot web || true

  echo "Restoring database..."
  compose exec -T postgres psql -U "${pg_user}" -d postgres -v ON_ERROR_STOP=1 \
    -c "DROP DATABASE IF EXISTS \"${pg_db}\" WITH (FORCE);" \
    -c "CREATE DATABASE \"${pg_db}\" OWNER \"${pg_user}\";"
  compose exec -T postgres pg_restore -U "${pg_user}" -d "${pg_db}" --no-owner --exit-on-error < "${source}/db.dump"

  echo "Restoring attachments..."
  docker run --rm -v "${PROJECT}_minio-data:/data" -v "${source}:/backup:ro" alpine \
    sh -c 'find /data -mindepth 1 -delete && tar xzf /backup/files.tgz -C /data'

  if [[ -f "${source}/env" ]] && ! cmp -s "${source}/env" "${ENV_FILE}"; then
    echo "Note: the backup's .env differs from the current one (keys, ports or version)." >&2
    echo "Compare ${source}/env with ${ENV_FILE} if stored credentials do not decrypt." >&2
  fi
  start_itsaplan
}

upgrade_itsaplan() {
  require_install
  local version="${1:-${DEFAULT_VERSION}}"
  backup_itsaplan
  (cd "${RUNTIME_DIR}" && git fetch --depth 1 origin "refs/tags/v${version}:refs/tags/v${version}" \
    && git checkout --quiet "v${version}")
  set_env VERSION "${version}"
  compose pull
  compose up -d
  wait_healthy
  echo "Running version: $(installed_version)"
}

installed_version() {
  local key
  key="$(tr -d '[:space:]' < "${RUNTIME_DIR}/api-token" 2>/dev/null || true)"
  curl -fsS ${key:+-H "x-api-key: ${key}"} "$(api_url)/settings/version" 2>/dev/null \
    | python3 -c 'import json,sys; print(json.load(sys.stdin)["version"])' 2>/dev/null \
    || echo "unknown (pinned: $(env_value VERSION))"
}

destroy_itsaplan() {
  require_install
  echo "This deletes the containers, ALL data volumes and ${RUNTIME_DIR}."
  echo "Backups in ${BACKUP_DIR} are kept."
  read -r -p "Type 'destroy' to continue: " answer
  [[ "${answer}" == "destroy" ]] || { echo "Aborted."; exit 1; }
  compose down -v
  rm -rf "${RUNTIME_DIR}"
}

command="${1:-}"
case "${command}" in
  install)  shift; install_itsaplan "$@" ;;
  start)    start_itsaplan ;;
  stop)     require_install; compose down ;;
  restart)  require_install; compose down; start_itsaplan ;;
  status)   require_install; compose ps; echo "Version: $(installed_version)" ;;
  logs)     require_install; shift; compose logs -f "$@" ;;
  backup)   backup_itsaplan ;;
  restore)  shift; restore_itsaplan "$@" ;;
  upgrade)  shift; upgrade_itsaplan "$@" ;;
  open)     require_install; open "$(web_url)" ;;
  url)      require_install; echo "$(web_url)"; echo "$(api_url)" ;;
  destroy)  destroy_itsaplan ;;
  *)        usage; [[ -n "${command}" ]] && exit 1 ;;
esac
