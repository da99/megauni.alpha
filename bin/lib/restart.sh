

source "$THIS_DIR/bin/lib/stop.sh"
source "$THIS_DIR/bin/lib/start.sh"

# === {{CMD}}
restart () {
  stop
  start
} # === end function
