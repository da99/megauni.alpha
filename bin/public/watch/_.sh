
# === {{CMD}}
# === {{CMD}}   "my command --with --args"
# === {{CMD}}   "bash       /tmp/lots-of-cmds-with-quotes.sh"

reload-browser () {
  sh_color BOLD "=== Reloading browser: "
  gui_setup reload-browser
  wget -q -S -O- http://localhost:4567/ 2>&1 | grep HTTP
}

watch () {
  mkdir -p /tmp/watch

  local +x CMD=""
  local +x CMD_FILE="$(mktemp /tmp/watch/XXXXXXXXXXXXXXXXX)"

  if [[ ! -z "$@" ]]; then
    CMD="$@"
    echo "set -u -e -o pipefail" >  "$CMD_FILE"
    echo "$@"                    >> "$CMD_FILE"
    bash "$CMD_FILE" || :
  fi

  sh_color BOLD "\n=== Watching: "

  inotifywait --quiet --monitor --event close_write -r config/ Public/ Server/ bin/ | while read -r CHANGE; do
    local +x DIR=$(echo "$CHANGE" | cut -d' ' -f 1)
    local +x FILE="${DIR}$(echo "$CHANGE" | cut -d' ' -f 3)"
    local +x FILE_NAME="$(basename $PATH)"

    # Temp/swap file:
    if [[ ! -f "$FILE" ]]; then
      sh_color BOLD "=== Skipping {{non-file}}: $FILE"
      continue
    fi

    # SQL generated:
    if [[ "$FILE" == */migrates/*/build/*.sql || "$FILE" == */mariadb_snapshot/* ]]; then
      sh_color BOLD "=== Skipping {{generated sql file}}: $FILE"
      continue
    fi

    sh_color BOLD "=== {{CHANGE}}: $CHANGE  {{FILE}}: {{$FILE}}"

    if [[ "$FILE" == bin/megauni* || "$FILE" == bin/public/watch/_.sh ]]; then
      sh_color ORANGE "\n=== {{Reloading}} this script: $0 $THE_ARGS"
      $0 watch "$CMD"
      exit 0
    fi

    if [[ "$FILE" == config/* ]]; then
      megauni server restart && reload-browser || :
      echo "" && continue
    fi

    if echo "$FILE" | grep -P "Server/.+?\.(css|js|html|styl|sass)$" >/dev/null; then
      sh_color ORANGE "=== {{Rebuilding}}..."
      $0 build && reload-browser || :
      echo "" && continue
    fi

    if [[ "$FILE" == *.json ]]; then
      (js_setup jshint! $FILE && $0 test $@)  || :
      echo "" && continue
    fi

    if mksh_setup is-dev && [[ "$FILE" == *.sql ]]; then
      if [[ -z "$CMD" ]] && mksh_setup is-dev; then
        {
          mariadb_setup drop-everything
          $0 UP $(echo "$FILE" | cut -d'/' -f2)
        } || :
        echo "" && continue
      fi
    fi

    if [[ ! -z "$CMD" ]]; then
      bash "$CMD_FILE" || :
    fi
  done # === watch

} # === end function

