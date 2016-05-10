
# === {{CMD}}
# === {{CMD}}   "my command --with --args"
# === {{CMD}}   "bash       /tmp/lots-of-cmds-with-quotes.sh"

reload-browser () {
  mksh_setup BOLD "=== Reloading browser: "
  gui_setup reload-browser
  wget -q -S -O- http://localhost:4567/ 2>&1 | grep HTTP
}

watch () {
  mkdir -p /tmp/watch

  local +x CMD=""
  local +x CMD_FILE="$(mktemp /tmp/watch/XXXXXXXXXXXXXXXXX)"

  if [[ ! -z "$@" ]]; then
    CMD="$@"
    echo "$@" > "$CMD_FILE"
    bash "$CMD_FILE" || :
  fi

  mksh_setup BOLD "\n=== Watching: "

  inotifywait --quiet --monitor --event close_write -r config/ Public/ Server/ bin/ | while read -r CHANGE; do
    local +x DIR=$(echo "$CHANGE" | cut -d' ' -f 1)
    local +x FILE="${DIR}$(echo "$CHANGE" | cut -d' ' -f 3)"
    local +x FILE_NAME="$(basename $PATH)"

    # Temp/swap file:
    if [[ ! -f "$FILE" ]]; then
      mksh_setup BOLD "=== Skipping {{non-file}}: $FILE"
      continue
    fi

    # SQL generated:
    if [[ "$FILE" == */migrates/*/build/*.sql || "$FILE" == */config/mariadb_snapshot/* ]]; then
      mksh_setup BOLD "\n=== Skipping {{generated sql file}}: BOLD{{$FILE}}"
      continue
    fi

    mksh_setup BOLD "=== {{CHANGE}}: $CHANGE  {{FILE}}: {{$FILE}}"

    if [[ "$FILE" == bin/megauni* || "$FILE" == bin/lib/watch.sh ]]; then
      mksh_setup ORANGE "\n=== {{Reloading}} this script: $0 $THE_ARGS"
      $0 watch "$CMD"
      exit 0
    fi

    if [[ "$FILE" == config/* ]]; then
      megauni server restart && reload-browser || :
      continue
    fi

    if echo "$FILE" | grep -P "Server/.+?\.(css|js|html|styl|sass)$" >/dev/null; then
      mksh_setup ORANGE "=== {{Rebuilding}}..."
      $0 build && reload-browser || :
      continue
    fi

    if [[ "$FILE" == *.json ]]; then
      (js_setup jshint! $FILE && $0 test $@)  || :
      continue
    fi

    if mksh_setup is-dev && [[ "$FILE" == *.sql ]]; then
      if [[ -z "$CMD" ]]; then
        $0 DOWN
        $0 UP
      fi
    fi

    if [[ ! -z "$CMD" ]]; then
      bash "$CMD_FILE" || :
    fi
  done # === watch

} # === end function

