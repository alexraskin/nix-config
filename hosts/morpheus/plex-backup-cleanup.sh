# Keeps the newest $keep Plex backups on the NAS.
# Env: BACKUP_DIR BACKUP_LOG DISCORD_WEBHOOK

keep=5

log() {
  echo "$(date '+%Y-%b-%d at %k:%M:%S') :: $*" | tee -a "$BACKUP_LOG"
}

send_discord() {
  local status=$1 message=$2 color=$3
  curl -fsS -m 30 -X POST "$DISCORD_WEBHOOK" \
    -H "Content-Type: application/json" \
    -d "{\"embeds\": [{
          \"title\": \"Plex Cleanup $status\",
          \"description\": \"$message\",
          \"color\": $color,
          \"timestamp\": \"$(date -u +%Y-%m-%dT%H:%M:%S.000Z)\",
          \"footer\": {\"text\": \"$(hostname)\"}
        }]}" >>"$BACKUP_LOG" 2>&1 || true
}

if [[ ! -d $BACKUP_DIR ]]; then
  log "ERROR: Backup directory $BACKUP_DIR does not exist!"
  send_discord "Failed" "Backup directory does not exist" 15548997
  exit 1
fi

mapfile -t backups < <(find "$BACKUP_DIR" -maxdepth 1 -name 'buplex-*.tar.gz' | sort)
total=${#backups[@]}

if ((total > keep)); then
  deleted=$((total - keep))
  rm -- "${backups[@]:0:deleted}"
  log "Deleted $deleted old backup(s). Kept latest $keep backups."
  send_discord "Success" "Deleted $deleted old backup(s)\\nTotal backups: $total → $keep" 5763719
else
  log "No cleanup needed. Total backups: $total"
  send_discord "Success" "No cleanup needed\\nTotal backups: $total" 5763719
fi
