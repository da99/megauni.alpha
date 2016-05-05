
source "$THIS_DIR/bin/lib/list-types.sh"

# === {{CMD}}
# === {{CMD}} Type_Name Another_Type ...
UP () {
  local +x TYPES="$@"
  if [[ -z "$TYPES" ]]; then
    TYPES="$(list-types | tr '\n' ' ')"
  fi

  for NAME in $TYPES ; do
    local +x MIGRATES="Server/$NAME/migrates"
    for SQL_TARGET in $(find "$MIGRATES" -mindepth 1 -maxdepth 1 -type d); do
      mksh_setup BOLD "=== in: {{$SQL_TARGET}}"
      for SQL_FILE in $(find "$SQL_TARGET" -mindepth 1 -maxdepth 1 -type f -name "*.sql" | sort -V); do
        mariadb_setup sql UP   "$SQL_FILE" | mysql && mksh_setup GREEN "=== SQL: {{$SQL_FILE}}" || {
          local +x STAT="$?"
          mksh_setup RED "!!! SQL failed: {{$STAT}} BOLD{{$SQL_FILE}}"
          exit "$STAT"
        }
      done
    done
  done

  # if [[ -n "$IS_DEV" ]]; then
  #   $0 snapshot
  # fi
} # === end function
