
source "$THIS_DIR/bin/lib/list-types.sh"

# === {{CMD}}
# === {{CMD}} Type_Name Another_Type ...
UP () {
  local +x TYPES="$@"
  if [[ -z "$TYPES" ]]; then
    TYPES="$(list-types | tr '\n' ' ')"
  fi

  for NAME in $TYPES ; do
    for SQL_TARGET in $(find "Server/$NAME/migrates" -mindepth 1 -maxdepth 1 -type d); do
      mksh_setup BOLD "=== in: {{$SQL_TARGET}}"
      for SQL_FILE in $(find "$SQL_TARGET" -mindepth 1 -maxdepth 1 -type f -name "*.sql" | sort -V); do
        mariadb_setup sql UP   "$SQL_FILE" | mysql && mksh_setup GREEN "=== SQL: {{$SQL_FILE}}" || {
          local +x STAT="$?"
          mksh_setup RED "!!! SQL failed: {{$STAT}} BOLD{{$SQL_FILE}}"
          exit "$STAT"
        }
      done # === each SQL File
    done # === DIR of sql file groups
  done # === TYPES


  # === IF not a DEV machine:
  if [[ ! -n "$IS_DEV" ]]; then
    return 0
  fi

  # === DEV machine:
  if [[ -n "$IS_DEV" ]]; then
    $0 snapshot
  fi

  for NAME in $TYPES ; do
    for SQL_TARGET in $(find "Server/$NAME/migrates" -mindepth 1 -maxdepth 1 -type d); do
      local +x SQL_NAME="$(basename "$SQL_TARGET")"
      local +x MIGRATES="Server/$NAME/migrates/$SQL_NAME"
      local +x BUILD="$MIGRATES/build"
      local +x OUTPUT="$(find "config/mariadb_snapshot" -mindepth 1 -maxdepth 1 -type f -name "${SQL_NAME}.*.sql" -print)"
      if [[ ! -z "$OUTPUT" ]]; then
        trash-put "$BUILD"
        mkdir -p "$BUILD"
        cp -i "$OUTPUT" "$BUILD/"
      fi
    done
  done # === each $TYPES

} # === end function


