# Stops Plex, tars its library (minus Cache) to the NAS, starts it again.
# Env: PLEX_DATA_DIR PLEX_UNIT BACKUP_DIR BACKUP_LOG DISCORD_WEBHOOK

log() {
  echo "$(date '+%Y-%b-%d at %k:%M:%S') :: $*" | tee -a "$BACKUP_LOG"
}

send_discord() {
  local status=$1 message=$2 color=$3
  curl -fsS -m 30 -X POST "$DISCORD_WEBHOOK" \
    -H "Content-Type: application/json" \
    -d "{\"embeds\": [{
          \"title\": \"Plex Backup $status\",
          \"description\": \"$message\",
          \"color\": $color,
          \"timestamp\": \"$(date -u +%Y-%m-%dT%H:%M:%S.000Z)\",
          \"footer\": {\"text\": \"$(hostname)\"}
        }]}" >>"$BACKUP_LOG" 2>&1 || true
}

fail() {
  log "ERROR: $1"
  send_discord "Failed" "$1" 15548997
  systemctl start "$PLEX_UNIT" >>"$BACKUP_LOG" 2>&1 || true
  exit 1
}

mountpoint -q "$BACKUP_DIR" || fail "NFS share not mounted at $BACKUP_DIR"

plex_dir="$PLEX_DATA_DIR/Library/Application Support/Plex Media Server"

# Wait until no one is watching, up to 2 hours, polling the sessions API with
# the token Plex keeps in Preferences.xml. The token is never printed.
wait_for_plex_idle() {
  local token sessions waited=0 max_wait=120
  token=$(sed -n 's/.*PlexOnlineToken="\([^"]*\)".*/\1/p' "$plex_dir/Preferences.xml" 2>/dev/null | head -1 || true)
  if [[ -z $token ]]; then
    log "WARNING: No Plex token found. Continuing backup without session check."
    return 0
  fi
  while true; do
    sessions=$(curl -s -m 10 "http://127.0.0.1:32400/status/sessions?X-Plex-Token=${token}" |
      sed -n 's/.*<MediaContainer[^>]* size="\([0-9][0-9]*\)".*/\1/p' | head -1 || true)
    if [[ -z $sessions ]]; then
      log "WARNING: Plex sessions check failed. Continuing backup."
      return 0
    fi
    if [[ $sessions == 0 ]]; then
      log "No active Plex sessions. Continuing backup."
      return 0
    fi
    if ((waited >= max_wait)); then
      log "Plex still in use after ${max_wait} minutes ($sessions session(s)). Continuing backup anyway."
      return 0
    fi
    log "Plex in use ($sessions active session(s)). Waiting 5 minutes."
    sleep 300
    waited=$((waited + 5))
  done
}
wait_for_plex_idle

log "Starting Backup."
log "Stopping Plex container."
systemctl stop "$PLEX_UNIT" >>"$BACKUP_LOG" 2>&1 || fail "Failed to stop Plex container"

cd "$plex_dir" || fail "Failed to access Plex directory"
backup_file="$BACKUP_DIR/buplex-$(date '+%Y-%m(%b)-%d_%khr_%Mmin').tar.gz"
backup_file=${backup_file// /}
tar cz --exclude='Cache' -f "$backup_file" . >>"$BACKUP_LOG" 2>&1 || fail "Tar backup failed"
backup_size=$(du -h "$backup_file" | cut -f1)

log "Starting Plex container."
systemctl start "$PLEX_UNIT" >>"$BACKUP_LOG" 2>&1 || fail "Failed to start Plex container"

log "Backup Completed."
send_discord "Success" "Backup completed successfully\\nSize: $backup_size" 5763719
