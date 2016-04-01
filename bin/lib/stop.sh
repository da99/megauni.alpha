
source "$THIS_DIR/bin/lib/nginx.sh"
source "$THIS_DIR/bin/lib/is-server-running.sh"

# === {{CMD}}
stop () {
  if ! is-server-running; then
    mksh_setup ORANGE "=== Server is already {{shutdown}}."
    return 0
  fi

  echo "=== Stopping..."
  nginx -s stop

  if is-server-running; then
    mksh_setup RED "!!! Something went wrong. Server is {{still running}}."
    return 1
  fi

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
