
# === {{CMD}}
snapshot () {

  local +x DIR="$THIS_DIR/config/mariadb_snapshot"

  if mksh_setup is-dev; then

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

    local +x GRANTS="$DIR/megauni.localhost.grants.sql"
    echo "$(echo "SHOW GRANTS FOR 'megauni'@'localhost' ;" | mysql | tail -n+3 | sed 's/DROP[\,\ ]\+//')" > "$GRANTS"

    return 0

  fi # ==== if is-dev

  ensure-no-drop-grants
  ensure-dev-snapshot matches prod snapshot

} # === end function


specs () {
  IS_DEV=""    should-exit 1 "megauni snapshot"
  IS_DEV="yes" should-exit 0 "megauni snapshot"
} # === specs ()

