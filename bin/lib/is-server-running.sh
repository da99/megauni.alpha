source "$THIS_DIR/bin/lib/server-pid.sh"

# === {{CMD}}
is-server-running () {
  test -s "$(cat $(server-pid))" && ( ps aux | grep megauni | grep --color=always nginx ) >/dev/null
} # === end function
