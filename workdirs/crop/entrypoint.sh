#!/usr/bin/env bash
set -Eeuo pipefail

TASK_NAME="crop"
STATE_DIR="/tmp/opencode-harness"
CONFIG_DIR="$HOME/.config/opencode"
SESSION_ID_FILE="$STATE_DIR/session-id"
SESSION_URL_FILE="$STATE_DIR/session-url"

WORKDIR_DIR=""
PROJECT_DIR=""
OUTPUT_DIR=""
AUTH_DIR=""
OPENCODE_SRC=""
MODE=""
RUN_INFO_PATH=""
INTERNAL_URL=""
PUBLIC_URL=""
WEB_PID=""
WATCHER_PID=""
SESSION_ID=""
SESSION_URL=""
SESSION_URL_STATUS="disabled"
EXIT_CODE=""
FINISHED_AT=""
STARTED_AT="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

log() { printf '%s\n' "$*"; }
die() { printf 'error: %s\n' "$*" >&2; exit 1; }

is_true() {
  case "${1:-}" in 1|true|TRUE|yes|YES|on|ON) return 0 ;; *) return 1 ;; esac
}

json_escape() {
  local value="${1-}"
  value="${value//\\/\\\\}"
  value="${value//\"/\\\"}"
  value="${value//$'\n'/\\n}"
  value="${value//$'\r'/\\r}"
  value="${value//$'\t'/\\t}"
  printf '%s' "$value"
}

json_or_null() {
  [ -n "${1-}" ] && printf '"%s"' "$(json_escape "$1")" || printf 'null'
}

project_url() {
  local encoded
  encoded="$(printf '%s' "$PROJECT_DIR" | base64 | tr '+/' '-_' | tr -d '=\n')"
  printf '%s/%s' "$PUBLIC_URL" "$encoded"
}

session_url_for() {
  printf '%s/session/%s' "$(project_url)" "$1"
}

apply_task_defaults() {
  export HARNESS_WORKDIR="${HARNESS_WORKDIR:-/scan/opencode}"
  export HARNESS_MODE="${HARNESS_MODE:-harness}"
  export HARNESS_WEB="${HARNESS_WEB:-true}"
  export HARNESS_KEEP_WEB="${HARNESS_KEEP_WEB:-true}"
  export OPENCODE_AGENT="${OPENCODE_AGENT:-orchestrator}"
  export OPENCODE_FORMAT="${OPENCODE_FORMAT:-default}"

  if [ -z "${OPENCODE_INITIAL_PROMPT:-}" ] && [ -n "${HARNESS_PROMPT:-}" ]; then
    export OPENCODE_INITIAL_PROMPT="$HARNESS_PROMPT"
  fi
}

load_runtime_config() {
  WORKDIR_DIR="${HARNESS_WORKDIR:-/scan/opencode}"
  PROJECT_DIR="${HARNESS_PROJECT_DIR:-/scan/project}"
  OUTPUT_DIR="${HARNESS_OUTPUT_DIR:-/scan/output}"
  AUTH_DIR="${HARNESS_AUTH_DIR:-/scan/auth}"
  RUN_INFO_PATH="$OUTPUT_DIR/runtime/run-info.json"

  OPENCODE_PORT="${OPENCODE_PORT:-4096}"
  OPENCODE_HOSTNAME="${OPENCODE_HOSTNAME:-${OPENCODE_HOST:-0.0.0.0}}"
  export OPENCODE_PORT OPENCODE_HOSTNAME

  INTERNAL_URL="${HARNESS_INTERNAL_URL:-http://127.0.0.1:$OPENCODE_PORT}"
  PUBLIC_URL="${HARNESS_PUBLIC_URL:-http://127.0.0.1:$OPENCODE_PORT}"
  HARNESS_SESSION_DISCOVERY_TIMEOUT="${HARNESS_SESSION_DISCOVERY_TIMEOUT:-60}"
  HARNESS_POST_RUN_SESSION_WAIT="${HARNESS_POST_RUN_SESSION_WAIT:-5}"
  MODE="${HARNESS_MODE:-harness}"
  if [ "$MODE" = "run" ]; then
    MODE="harness"
  fi

  if [ -n "${HARNESS_OPENCODE_DIR:-}" ]; then
    [ -d "$HARNESS_OPENCODE_DIR" ] || die "HARNESS_OPENCODE_DIR does not exist: $HARNESS_OPENCODE_DIR"
    OPENCODE_SRC="$HARNESS_OPENCODE_DIR"
  elif [ -d "$WORKDIR_DIR/.opencode" ]; then
    OPENCODE_SRC="$WORKDIR_DIR/.opencode"
  elif [ -f "$WORKDIR_DIR/opencode.jsonc" ]; then
    OPENCODE_SRC="$WORKDIR_DIR"
  else
    OPENCODE_SRC=""
  fi
}

copy_opencode_config() {
  mkdir -p "$CONFIG_DIR"
  [ -n "$OPENCODE_SRC" ] || return 0

  shopt -s dotglob nullglob
  local entry name
  for entry in "$OPENCODE_SRC"/*; do
    name="$(basename "$entry")"
    [ "$name" = "node_modules" ] && continue
    rm -rf "$CONFIG_DIR/$name"
    cp -a "$entry" "$CONFIG_DIR"/
  done
  shopt -u dotglob nullglob

  export OPENCODE_CONFIG_DIR="$CONFIG_DIR"
  if [ -f "$CONFIG_DIR/opencode.jsonc" ]; then
    export OPENCODE_CONFIG="$CONFIG_DIR/opencode.jsonc"
  elif [ -f "$CONFIG_DIR/opencode.json" ]; then
    export OPENCODE_CONFIG="$CONFIG_DIR/opencode.json"
  fi
}

prepare_auth() {
  local auth_dir="$HOME/.local/share/opencode"
  local auth_file="$auth_dir/auth.json"
  mkdir -p "$auth_dir"

  if [ -f "$AUTH_DIR/auth.json" ]; then
    cp "$AUTH_DIR/auth.json" "$auth_file"
  elif [ -n "${HARNESS_AUTH_PROVIDER:-}" ] || [ -n "${HARNESS_AUTH_KEY:-}" ]; then
    [ -n "${HARNESS_AUTH_PROVIDER:-}" ] || die "HARNESS_AUTH_PROVIDER is required when HARNESS_AUTH_KEY is set"
    [ -n "${HARNESS_AUTH_KEY:-}" ] || die "HARNESS_AUTH_KEY is required when HARNESS_AUTH_PROVIDER is set"
    cat > "$auth_file" <<EOF_AUTH
{
  "$(json_escape "$HARNESS_AUTH_PROVIDER")": {
    "type": "api",
    "key": "$(json_escape "$HARNESS_AUTH_KEY")"
  }
}
EOF_AUTH
  else
    return 0
  fi

  chmod 600 "$auth_file"
}

prepare_runtime() {
  mkdir -p "$STATE_DIR"
  rm -f "$SESSION_ID_FILE" "$SESSION_URL_FILE"
  copy_opencode_config
  prepare_auth
}

apply_web_defaults() {
  [ -z "${OPENCODE_CONFIG_CONTENT:-}" ] || return 0
  [ -n "${OPENCODE_MODEL:-}${OPENCODE_AGENT:-}" ] || return 0

  local -a fields=()
  [ -z "${OPENCODE_MODEL:-}" ] || fields+=("\"model\":\"$(json_escape "$OPENCODE_MODEL")\"")
  [ -z "${OPENCODE_AGENT:-}" ] || fields+=("\"default_agent\":\"$(json_escape "$OPENCODE_AGENT")\"")
  local IFS=,
  export OPENCODE_CONFIG_CONTENT="{${fields[*]}}"
}

write_run_info() {
  local status="$1"
  local now
  now="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  mkdir -p "$OUTPUT_DIR/runtime"

  cat > "$RUN_INFO_PATH" <<EOF_INFO
{
  "run_status": "$(json_escape "$status")",
  "started_at": "$(json_escape "$STARTED_AT")",
  "updated_at": "$(json_escape "$now")",
  "finished_at": $(json_or_null "$FINISHED_AT"),
  "exit_code": ${EXIT_CODE:-null},
  "task": "$(json_escape "$TASK_NAME")",
  "mode": "$(json_escape "$MODE")",
  "project_dir": "$(json_escape "$PROJECT_DIR")",
  "opencode_dir": $(json_or_null "$OPENCODE_SRC"),
  "config_dir": "$(json_escape "$CONFIG_DIR")",
  "output_dir": "$(json_escape "$OUTPUT_DIR")",
  "agent": $(json_or_null "${OPENCODE_AGENT:-}"),
  "model": $(json_or_null "${OPENCODE_MODEL:-}"),
  "server_url": $(is_true "$HARNESS_WEB" && json_or_null "$PUBLIC_URL" || printf 'null'),
  "project_url": $(is_true "$HARNESS_WEB" && json_or_null "$(project_url)" || printf 'null'),
  "session_id": $(json_or_null "$SESSION_ID"),
  "session_url": $(json_or_null "$SESSION_URL"),
  "session_url_status": "$(json_escape "$SESSION_URL_STATUS")"
}
EOF_INFO
}

curl_auth_args() {
  [ -n "${OPENCODE_SERVER_PASSWORD:-}" ] && printf '%s\n%s\n' -u "${OPENCODE_SERVER_USERNAME:-opencode}:$OPENCODE_SERVER_PASSWORD"
  return 0
}

start_web() {
  local i code
  local -a auth_args=()
  mapfile -t auth_args < <(curl_auth_args)

  log "Starting OpenCode Web on $INTERNAL_URL"
  opencode web --hostname "$OPENCODE_HOSTNAME" --port "$OPENCODE_PORT" &
  WEB_PID=$!

  for ((i = 0; i < 120; i++)); do
    code="$(curl -s -o /dev/null -w '%{http_code}' "${auth_args[@]}" "$INTERNAL_URL" 2>/dev/null || true)"
    if [ "$code" != "000" ]; then
      SESSION_URL_STATUS="pending"
      log "OpenCode project URL: $(project_url)"
      return 0
    fi
    sleep 0.5
  done
  die "OpenCode Web did not become reachable at $INTERNAL_URL"
}

stop_web() {
  if [ -n "$WEB_PID" ] && kill -0 "$WEB_PID" 2>/dev/null; then
    kill "$WEB_PID" 2>/dev/null || true
    wait "$WEB_PID" 2>/dev/null || true
  fi
}

find_session_id() {
  local json lines id
  local -a auth_args=()
  mapfile -t auth_args < <(curl_auth_args)

  json="$(curl -fsS "${auth_args[@]}" "$INTERNAL_URL/session?directory=$PROJECT_DIR" 2>/dev/null || true)"
  [ -n "$json" ] || return 1
  lines="$(printf '%s' "$json" | tr -d '\n' | sed 's/},{"id"/}\n{"id"/g')"

  if [ -n "${OPENCODE_AGENT:-}" ]; then
    id="$(printf '%s\n' "$lines" | grep -F "\"$OPENCODE_AGENT\"" | grep -v '"parentID"' | grep -o 'ses_[A-Za-z0-9]*' | head -n 1 || true)"
    [ -n "$id" ] && printf '%s' "$id" && return 0
  fi

  id="$(printf '%s\n' "$lines" | grep -v '"parentID"' | grep -o 'ses_[A-Za-z0-9]*' | head -n 1 || true)"
  [ -n "$id" ] && printf '%s' "$id"
}

load_session() {
  [ -f "$SESSION_ID_FILE" ] || return 1
  SESSION_ID="$(cat "$SESSION_ID_FILE")"
  SESSION_URL="$(cat "$SESSION_URL_FILE")"
  SESSION_URL_STATUS="found"
}

watch_session() {
  local deadline id
  deadline=$((SECONDS + HARNESS_SESSION_DISCOVERY_TIMEOUT))
  while [ "$SECONDS" -le "$deadline" ]; do
    id="$(find_session_id || true)"
    if [ -n "$id" ]; then
      SESSION_ID="$id"
      SESSION_URL="$(session_url_for "$id")"
      SESSION_URL_STATUS="found"
      printf '%s' "$SESSION_ID" > "$SESSION_ID_FILE"
      printf '%s' "$SESSION_URL" > "$SESSION_URL_FILE"
      log "OpenCode session URL: $SESSION_URL"
      write_run_info "running"
      return 0
    fi
    sleep 1
  done
  return 1
}

cleanup() {
  if [ -n "$WATCHER_PID" ] && kill -0 "$WATCHER_PID" 2>/dev/null; then
    kill "$WATCHER_PID" 2>/dev/null || true
    wait "$WATCHER_PID" 2>/dev/null || true
  fi
  is_true "$HARNESS_KEEP_WEB" || stop_web
}

build_prompt() {
  if [ -n "${HARNESS_PROMPT_FILE:-}" ]; then
    [ -f "$HARNESS_PROMPT_FILE" ] || die "HARNESS_PROMPT_FILE does not exist: $HARNESS_PROMPT_FILE"
    cat "$HARNESS_PROMPT_FILE"
  elif [ -n "${OPENCODE_INITIAL_PROMPT:-}" ]; then
    printf '%s' "$OPENCODE_INITIAL_PROMPT"
  elif [ -n "${HARNESS_PROMPT:-}" ]; then
    printf '%s' "$HARNESS_PROMPT"
  else
    die "OPENCODE_INITIAL_PROMPT is required in harness mode. Set it in docker run, or set HARNESS_PROMPT_FILE."
  fi
}

run_harness() {
  [ -d "$PROJECT_DIR" ] || die "project directory does not exist: $PROJECT_DIR"
  mkdir -p "$OUTPUT_DIR/runtime"
  prepare_runtime
  trap cleanup EXIT INT TERM

  if is_true "$HARNESS_WEB"; then
    start_web
    write_run_info "server_ready"
    watch_session &
    WATCHER_PID=$!
  else
    SESSION_URL_STATUS="disabled"
  fi

  local prompt status
  local -a cmd
  prompt="$(build_prompt)"
  export OPENCODE_INITIAL_PROMPT="$prompt"
  cmd=(opencode run --dir "$PROJECT_DIR" --format "${OPENCODE_FORMAT:-default}")
  [ -z "${OPENCODE_AGENT:-}" ] || cmd+=(--agent "$OPENCODE_AGENT")
  [ -z "${OPENCODE_MODEL:-}" ] || cmd+=(--model "$OPENCODE_MODEL")
  [ -z "${OPENCODE_VARIANT:-}" ] || cmd+=(--variant "$OPENCODE_VARIANT")
  [ -z "${HARNESS_TITLE:-}" ] || cmd+=(--title "$HARNESS_TITLE")
  is_true "$HARNESS_WEB" && cmd+=(--attach "$INTERNAL_URL")
  [ -z "$OPENCODE_INITIAL_PROMPT" ] || cmd+=("$OPENCODE_INITIAL_PROMPT")

  write_run_info "running"
  set +e
  "${cmd[@]}" "$@"
  status=$?
  set -e

  EXIT_CODE="$status"
  FINISHED_AT="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  if is_true "$HARNESS_WEB"; then
    local deadline=$((SECONDS + HARNESS_POST_RUN_SESSION_WAIT))
    while [ "$SECONDS" -le "$deadline" ] && ! load_session; do sleep 1; done
    if [ -z "$SESSION_ID" ]; then
      SESSION_URL_STATUS="not_found"
      log "OpenCode session URL: not found"
      log "OpenCode project URL: $(project_url)"
    fi
  fi

  [ "$status" -eq 0 ] && write_run_info "completed" || write_run_info "failed"
  if is_true "$HARNESS_WEB" && is_true "$HARNESS_KEEP_WEB" && [ -n "$WEB_PID" ]; then
    log "Keeping OpenCode Web alive. Stop the container to exit."
    wait "$WEB_PID"
  fi
  exit "$status"
}

run_web() {
  prepare_runtime
  apply_web_defaults
  exec opencode web --hostname "$OPENCODE_HOSTNAME" --port "$OPENCODE_PORT" "$@"
}

run_serve() {
  prepare_runtime
  apply_web_defaults
  exec opencode serve --hostname "$OPENCODE_HOSTNAME" --port "$OPENCODE_PORT" "$@"
}

run_shell() {
  prepare_runtime
  apply_web_defaults
  [ "$#" -gt 0 ] && exec /bin/sh "$@"
  exec /bin/sh
}

main() {
  apply_task_defaults
  load_runtime_config

  case "$MODE" in
    web) run_web "$@" ;;
    harness) run_harness "$@" ;;
    serve) run_serve "$@" ;;
    shell) run_shell "$@" ;;
    *) die "unsupported HARNESS_MODE: $MODE" ;;
  esac
}

main "$@"
