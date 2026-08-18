# Shell functions, kept as plain zsh so they need no nix string escaping.
# Sourced from apps/zsh/zsh.nix via its store path.

# battery time remaining
batt() {
  time_remaining=$(pmset -g batt | grep -Eo "([0-9]+:[0-9]+)")
  pct_remaining=$(pmset -g batt | grep -Eo "([0-9]+\%)")
  echo "$time_remaining remaining ($pct_remaining)"
}

# Backup a file or directory to ~/backups with a timestamped filename
backup() {
  if [ -z "$1" ]; then
    echo "usage: backup FILE"
    return
  fi

  local backup_dir="$HOME/backups"
  if [ ! -d "$backup_dir" ]; then
    echo "backup directory $backup_dir does not exist"
    return
  fi

  if [ ! -e "$1" ]; then
    echo "no file or directory found at path '$1'"
    return
  fi

  local src_path=$(realpath "$1")
  local timestamp=$(date "+%Y-%m-%d--%H-%M-%S")
  local dst_path="$backup_dir/$timestamp$src_path"
  local dst_dir=$(dirname "$dst_path")

  echo "Creating backup"
  echo "  source      = $src_path"
  echo "  destination = $dst_path"
  [ ! -d "$dst_dir" ] && mkdir -p "$dst_dir"
  cp -r "$src_path" "$dst_path"
}

# keep the mac awake ;)
awake() {
  if [[ "$1" == "-t" && -n "$2" ]]; then
    echo "☕ Caffeinated for $2 seconds"
    caffeinate -u -d -t "$2"
  else
    echo "☕ Caffeinated indefinitely (Ctrl+C to stop)"
    caffeinate -u -d -i
  fi
}

gh-open() {
  local file="$1"
  if git rev-parse --git-dir > /dev/null 2>&1; then
    repo=$(git remote get-url origin|sed "s/:/\//; s/\.git//; s/git@/https:\/\//; s/https\/\//https:\//")
    if [ -z "$file" ]; then
      open "${repo}"
    else
      local branch=$(git rev-parse --abbrev-ref HEAD)
      open "${repo}/blob/${branch}/${file}"
    fi
  else
    echo "not in a git repo"
  fi
}

gh-pr() {
  if git rev-parse --git-dir > /dev/null 2>&1; then
    local repo=$(git remote get-url origin|sed "s/:/\//; s/\.git//; s/git@/https:\/\//")
    local branch=$(git rev-parse --abbrev-ref HEAD)
    open "${repo}/compare/${branch}?expand=1"
  else
    echo "not in a git repo"
  fi
}

# Upload a file to S3 and print a presigned URL.
awsupload() {
  if [[ -z "$1" ]]; then
    echo "usage: awsupload <file> [expiry: 1h, 2h, ..., 1d, ..., 7d]" >&2
    return 1
  fi

  if [[ ! -f "$1" ]]; then
    echo "awsupload: not a file: $1" >&2
    return 1
  fi

  local EXPIRY="${2:-1h}"
  local EXPIRY_SECONDS
  if [[ "$EXPIRY" =~ '^([0-9]+)([hd])$' ]]; then
    local num="${match[1]}" unit="${match[2]}"
    if [[ "$unit" == "h" ]]; then
      EXPIRY_SECONDS=$(( num * 3600 ))
    else
      # SigV4 presigned URLs cap out at 7 days.
      if (( num < 1 || num > 7 )); then
        echo "awsupload: days must be 1–7" >&2
        return 1
      fi
      EXPIRY_SECONDS=$(( num * 86400 ))
    fi
  else
    echo "awsupload: invalid expiry '$EXPIRY' (use e.g. 1h, 2h, 1d, 7d)" >&2
    return 1
  fi

  local BUCKET_NAME=assets-raskin-private
  local PUBLIC_HOST=            # e.g. download.example.com; blank keeps the S3 host

  # Must match the bucket's actual region: a presigned URL signed for the wrong
  # one comes back as PermanentRedirect. Exported so the CLI uses it too rather
  # than falling back to ~/.aws/config.
  local -x AWS_DEFAULT_REGION=us-west-2
  local REGION="$AWS_DEFAULT_REGION"

  local AGE_IDENTITY="op://Private/Main 1password SSH Key/private key"
  local SECRETS="$HOME/nix-config/secrets/aws.env.age"

  if [[ -z "$AWS_ACCESS_KEY_ID" ]]; then
    local -x AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY
    local creds
    if [[ ! -f "$SECRETS" ]]; then
      echo "awsupload: missing $SECRETS" >&2
      return 1
    fi
    creds=$(op read "$AGE_IDENTITY" | age -d -i /dev/stdin "$SECRETS") || return 1
    eval "$creds"
  fi

  local FILENAME=$(basename "$1")

  command aws s3 cp "$1" "s3://$BUCKET_NAME/$FILENAME" || return 1

  local URL
  URL=$(command aws s3 presign "s3://$BUCKET_NAME/$FILENAME" \
        --expires-in "$EXPIRY_SECONDS") || return 1

  if [[ -n "$PUBLIC_HOST" ]]; then
    echo "${URL/$BUCKET_NAME.s3.$REGION.amazonaws.com/$PUBLIC_HOST}"
  else
    echo "$URL"
  fi
}
