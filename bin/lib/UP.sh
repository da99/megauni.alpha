
source "$THIS_DIR/bin/lib/list-types.sh"
source "$THIS_DIR/bin/lib/is-dev.sh"

# === {{CMD}}
# === {{CMD}} Type_Name Another_Type ...
UP () {
  local +x TYPES="$@"
  if [[ -z "$TYPES" ]]; then
    TYPES="$(list-types | tr '\n' ' ')"
  fi

  for NAME in $TYPES ; do

    local +x MIGRATE_DIRS="$(find "Server/$NAME/migrates" -mindepth 1 -maxdepth 1 -type d)"

    if [[ -z "$MIGRATE_DIRS" ]]; then
      mksh_setup ORANGE "=== No migrate dirs found in: {{$NAME}}"
      continue
    fi

    for SQL_TARGET in $MIGRATE_DIRS; do
      mksh_setup BOLD "=== in: {{$SQL_TARGET}}"
      local +x FILES="$(find "$SQL_TARGET" -mindepth 1 -maxdepth 1 -type f -name "*.sql" | sort -V)"

      if [[ -z "$FILES" ]]; then
        mksh_setup ORANGE "=== No sql files found in: {{$NAME}}"
        continue
      fi

      for SQL_FILE in $FILES; do
        mariadb_setup sql UP   "$SQL_FILE" | mysql && mksh_setup GREEN "=== SQL: {{$SQL_FILE}}" || {
          local +x STAT="$?"
          mksh_setup RED "!!! SQL failed: exit {{$STAT}} in BOLD{{$SQL_FILE}}"
          exit "$STAT"
        }
      done # === each SQL File
    done # === DIR of sql file groups

  done # === TYPES


  # === IF not a DEV machine:
  if ! is-dev; then
    return 0
  fi

  # === DEV machine:
  if is-dev; then
    $0 snapshot
    mksh_setup BOLD "=== Snapshot made."
  fi

  for NAME in $TYPES ; do
    for SQL_TARGET in $(find "Server/$NAME/migrates" -mindepth 1 -maxdepth 1 -type d); do
      local +x SQL_NAME="$(basename "$SQL_TARGET")"
      local +x MIGRATES="Server/$NAME/migrates/$SQL_NAME"
      local +x BUILD="$MIGRATES/build"
      local +x OUTPUT="$(find "config/mariadb_snapshot" -mindepth 1 -maxdepth 1 -type f -name "${SQL_NAME}.*.sql" -print)"
      if [[ ! -z "$OUTPUT" ]]; then
        if [[ -d "$BUILD" ]]; then
          trash-put "$BUILD"
        fi
        mkdir -p "$BUILD"
        echo "$OUTPUT" | xargs -I FILE cp -i FILE "$BUILD/"
      fi
    done
  done # === each $TYPES

} # === end function


