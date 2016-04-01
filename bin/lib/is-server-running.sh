
# === {{CMD}}
is-server-running () {
  test -s tmp/nginx.pid && ( ps aux | grep megauni | grep --color=always nginx ) >/dev/null
} # === end function
