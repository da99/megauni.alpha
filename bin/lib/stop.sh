
source "$THIS_DIR/bin/lib/nginx.sh"

# === {{CMD}}
stop () {
  echo "=== Stopping..."
  nginx -s stop || :
  ps aux | grep megauni | grep --color=always nginx
  return 0


  pids="$($THIS_DIR/bin/megauni status)"
  if [[ -z "$pids" ]]; then
    echo "=== No server procs found." 1>&2
  fi

  for num in $pids; do
    if [[ -n "$num" ]]; then
      echo "=== KILL-ing: $num"
      kill $num || echo "=== kill error"
    fi
  done
} # === end function
