source "$THIS_DIR/bin/lib/VAR.sh"

# === {{CMD}}
is-server-running () {
  test -s "$(cat $(VAR PID))" && ( ps aux | grep megauni | grep --color=always nginx ) >/dev/null
} # === end function
