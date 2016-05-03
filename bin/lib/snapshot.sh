
# === {{CMD}}
snapshot () {

  local +x DIR="$THIS_DIR/config/mariadb_snapshot"

  if [[ -d "$DIR" ]]; then
    local +x INVALID_FILES="$(find "$DIR" -type f | grep -v ".sql")"
    if [[ ! -z "$INVALID_FILES" ]]; then
      mksh_setup RED "!!! Invalid files:\n$INVALID_FILES"
      exit 1
    fi

    mksh_setup ORANGE "=== Removing: {{$DIR}}"
    rm -rf "$DIR"
  fi

  mariadb_setup snapshot "$DIR"

} # === end function
