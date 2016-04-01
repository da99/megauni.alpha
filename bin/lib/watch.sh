
# === {{CMD}}
# === {{CMD}}   "my command --with --args"
# === {{CMD}}   "bash       /tmp/lots-of-cmds-with-quotes.sh"
watch () {
    cmd () {
      if [[ -z "$@" ]]; then
        path="some.file"
      else
        path="$1"
        shift
      fi
    }
    cmd

    echo -e "\n=== Watching: $files"
    inotifywait --quiet --monitor --event close_write -r lib/ -r specs/ $(git ls-files | grep -E "\.js$|bin\/megauni" | tr '\n' ' ' | while read -r CHANGE; do
      dir=$(echo "$CHANGE" | cut -d' ' -f 1)
      path="${dir}$(echo "$CHANGE" | cut -d' ' -f 3)"
      file="$(basename $path)"

      # Make sure this is not a temp/swap file:
      { [[ ! -f "$path" ]] && continue; } || :

        if [[ "$path" == *bin/megauni* ]]; then
          break
        fi

        if [[ "$file" == *.sql ]]; then
          ( bin/megauni migrate up "$(basename $(dirname $(dirname "$path")))" && $0 test $@ ) || :
        else
          if [[ "$file" == *.js ]]; then
            js_pass="true"
            js_setup jshint! $path || js_pass=""

            if [[ -n "$js_pass" ]]; then
              $0 run_specs $@ || :
              bin/megauni restart
            fi # === if $js_pass
          else
            if [[ "$path" == *.json ]]; then
              (js_setup jshint! $path && $0 test $@)  || :
            else
              $0 test $@ || :
            fi
          fi # === if $file == *.js
        fi
    done

    echo ""
    echo "=== ${GREEN}Reloading${RESET_COLOR} this script: $0 $action"
    $0 watch $THE_ARGS
} # === end function

