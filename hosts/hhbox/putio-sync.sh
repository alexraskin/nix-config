# Download new items from a put.io RSS feed.
# Env: PUTIO_RSS_URL, PUTIO_DEST, PUTIO_INCOMING, PUTIO_SORT_TV (1 = sort into Show/Season NN/), STATE_DIRECTORY

seen="$STATE_DIRECTORY/seen"
touch "$seen"

feed=$(curl -fsS -m 60 --retry 3 "$PUTIO_RSS_URL")
# xmlstarlet exits 1 when nothing matches, i.e. an empty feed
items=$(xmlstarlet sel -t -m '//item[enclosure/@url]' -v 'guid' -o $'\t' -v 'enclosure/@url' -n <<<"$feed" || true)

# Show.Name.S01E02... -> Show Name/Season 01/; unmatched files stay in $PUTIO_DEST
target_for() {
  local re='^(.+)[. _-]+[Ss]([0-9]{1,2})[Ee][0-9]{1,3}'
  if [ "${PUTIO_SORT_TV:-0}" = 1 ] && [[ $(basename "$1") =~ $re ]]; then
    local show
    show=$(echo "${BASH_REMATCH[1]}" | tr '._' '  ' | sed -E 's/ +/ /g; s/^ | $//g')
    printf '%s/%s/Season %02d' "$PUTIO_DEST" "$show" "$((10#${BASH_REMATCH[2]}))"
  else
    printf '%s' "$PUTIO_DEST"
  fi
}

while IFS=$'\t' read -r guid url; do
  [ -n "$url" ] || continue
  key="${guid:-$url}"
  grep -qxF "$key" "$seen" && continue

  tmp=$(mktemp -d -p "$PUTIO_INCOMING")
  echo "downloading $key"
  # abort if throughput stays under 10KB/s for 5 minutes so a stalled transfer retries next run
  if curl -fL --retry 5 --speed-limit 10240 --speed-time 300 \
    -J -O --output-dir "$tmp" "$url" </dev/null; then
    for f in "$tmp"/*; do
      target=$(target_for "$f")
      mkdir -p "$target"
      mv -n "$f" "$target/"
    done
    echo "$key" >>"$seen"
  else
    echo "failed $key, will retry"
  fi
  rm -rf "$tmp"
done <<<"$items"
