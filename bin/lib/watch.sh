
# === {{CMD}}
# === {{CMD}}   "my command --with --args"
# === {{CMD}}   "bash       /tmp/lots-of-cmds-with-quotes.sh"

reload-browser () {
  mksh_setup BOLD "=== Reloading browser: "
  gui_setup reload-browser
  wget -q -S -O- http://localhost:4567/ 2>&1 | grep HTTP
}

watch () {
  local +x CMD=""
  if [[ ! -z "$@" ]]; then
    CMD="$1"; shift
    $CMD
  fi
  # $(git ls-files | grep -E "\.js$|bin\/megauni" | tr '\n' ' ' 


  mksh_setup BOLD "\n=== Watching: "

  inotifywait --quiet --monitor --event close_write -r config/ -r lib/ Server/ bin/ | while read -r CHANGE; do
    dir=$(echo "$CHANGE" | cut -d' ' -f 1)
    path="${dir}$(echo "$CHANGE" | cut -d' ' -f 3)"
    file="$(basename $path)"

    # Make sure this is not a temp/swap file:
    if [[ ! -f "$path" ]]; then
      mksh_setup BOLD "=== Skipping: $path"
      continue
    fi

    mksh_setup BOLD "=== {{CHANGE}}: $CHANGE  {{PATH}}: {{$path}}"
    if [[ ! -z "$CMD" ]]; then
      $CMD
    fi

    if [[ "$path" == bin/megauni* || "$path" == bin/lib/watch.sh ]]; then
      mksh_setup ORANGE "\n=== {{Reloading}} this script: $0 $THE_ARGS"
      exec $0 $THE_ARGS
    fi

    if [[ "$file" == *.sql ]]; then
      ( bin/megauni migrate up "$(basename $(dirname $(dirname "$path")))" && $0 test $@ ) || :
      continue
    fi

    if [[ "$path" == config/* ]]; then
      megauni server restart && reload-browser || :
      continue
    fi

    if echo "$path" | grep -P "Server/.+?\.(css|js|html|styl|sass)$" >/dev/null; then
      mksh_setup ORANGE "=== {{Rebuilding}}..."
      $0 build || :
      reload-browser
      continue
    fi

    if [[ "$path" == *.json ]]; then
      (js_setup jshint! $path && $0 test $@)  || :
      continue
    fi
  done # === watch

} # === end function

