
source "$THIS_DIR/bin/public/list-types/_.sh"
source "$THIS_DIR/bin/public/is-dev/_.sh"

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
      sh_color ORANGE "=== No migrate dirs found in: {{$NAME}}"
      continue
    fi

    for SQL_TARGET in $MIGRATE_DIRS; do
      sh_color BOLD "=== in: {{$SQL_TARGET}}"
      local +x FILES="$(find "$SQL_TARGET" -mindepth 1 -maxdepth 1 -type f -name "*.sql" | sort -V)"

      if [[ -z "$FILES" ]]; then
        sh_color ORANGE "=== No sql files found in: {{$NAME}}"
        continue
      fi

      for SQL_FILE in $FILES; do
        local +x SQL_IF="$(mariadb_setup sql UP-IF "$SQL_FILE")"
        local +x SQL_DO="yes"
        local +x RESULT=""

        if [[ -n "$(echo -n $SQL_IF)" ]]; then
          RESULT="$(echo "$SQL_IF" | mysql --skip-column-names)"
          if [[ -z "$RESULT" || "$(echo $RESULT)" == "0" ]]; then
            SQL_DO=""
          fi
        fi

        if [[ -z "$SQL_DO" ]]; then
          sh_color ORANGE "=== Skipping because UP-IF == \"{{$RESULT}}\" : $SQL_FILE"
        else
          mariadb_setup sql UP "$SQL_FILE" | mysql && sh_color GREEN "=== SQL: {{$SQL_FILE}}" || {
            local +x STAT="$?"
            sh_color RED "!!! SQL failed: exit {{$STAT}} in BOLD{{$SQL_FILE}}"
            exit "$STAT"
          }
        fi
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
    sh_color BOLD "=== Snapshot made."
  fi

  # === Copy mariadb snapshot files over to their respective migrate/ counterparts
  # === This helps in development if the logic of an DB object is spread out.
  # === For example: a table as a create and alter files. By copying to the migrate/*/build
  # === file, you can see the total completed output in one file.
  local +x ALL_MIGRATE_FOLDERS="$(find Server/*/migrates -mindepth 1 -maxdepth 1 -type d -print | sort -V)"
  for SQL_FILE in $(find "config/mariadb_snapshot" -mindepth 1 -maxdepth 1 -type f -name "*.sql" -print) ; do
    local +x NAME="$(basename "$SQL_FILE" | cut -d'.' -f1)"
    for DIR in $(echo "$ALL_MIGRATE_FOLDERS" | grep -P  "/migrates/[\d\-]+${NAME}$"); do
      local +x DIR="$(dirname "$SQL_FILE")"
      test -d "$DIR/build" && trash-put "$DIR/build" || :
      mkdir -p "$DIR/build"
      cp -i "$SQL_FILE" "$DIR/build"
    done
  done

} # === end function


