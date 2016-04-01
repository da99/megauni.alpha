

source "$THIS_DIR/bin/lib/start.sh"

# === {{CMD}}
restart () {
  echo "=== Stopping..."
  start -s stop
  echo "=== Starting..."
  start
} # === end function
