
# === {{CMD}}
# === {{CMD}}  FILE
jslint () {
    if [[ -n "$@" ]]; then
      js_setup jshint! $@
      exit 0
    fi

    js_files="$(echo -e lib/*/specs/*.json)"
    local +x IFS=$' '
    for file in $js_files
    do
      if [[ -f $file ]]; then
        js_setup jshint $file
      fi
    done
} # === end function


