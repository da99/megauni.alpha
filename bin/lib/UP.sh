
source "$THIS_DIR/bin/lib/list-types.sh"
source "$THIS_DIR/bin/lib/is-dev.sh"

# === {{CMD}}
# === {{CMD}} Type_Name Another_Type ...
UP () {
  local +x TYPES="$@"
  local +x ORIGINAL_ARGS="$@"
  if [[ -z "$TYPES" ]]; then
    TYPES="$(list-types | tr '\n' ' ')"
  fi

  for NAME in $TYPES ; do

    local +x MIGRATE_DIRS="$(find "Server/$NAME/migrates" -mindepth 1 -maxdepth 1 -type d | sort -V)"

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
  if [[ ! -z "$ORIGINAL_ARGS" ]] || ! is-dev; then
    return 0
  fi

  # === DEV machine:
  if is-dev; then
    $0 snapshot
    mksh_setup BOLD "=== Snapshot made."
  fi

  # === Copy mariadb snapshot files over to their respective migrate/ counterparts
  # === This helps in development if the logic of an DB object is spread out.
  # === For example: a table as a create and alter files. By copying to the migrate/*/build
  # === file, you can see the total completed output in one file.
  local +x ALL_MIGRATE_FOLDERS="$(find Server/*/migrates -mindepth 1 -maxdepth 1 -type d -print | sort -V)"
  for SQL_FILE in $(find "config/mariadb_snapshot" -mindepth 1 -maxdepth 1 -type f -name "*.sql" -print) ; do
    local NAME="$(basename "$SQL_FILE" | cut -d'.' -f1)"
    test -d "$DIR/build" && trash-put "$DIR/build" || :
    for DIR in $(echo "$ALL_MIGRATE_FOLDERS" | grep -P  "/migrates/[\d\-]+${NAME}$"); do
      mkdir -p "$DIR/build"
      cp -i "SQL_FILE" "$DIR/build"
    done
  done

} # === end function


