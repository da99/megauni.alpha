
source "$THIS_DIR/bin/lib/list-types.sh"
source "$THIS_DIR/bin/lib/is-dev.sh"

# === {{CMD}}
# === {{CMD}} Type_Name Another_Type ...
DOWN () {
  if ! is-dev; then
    mksh_setup RED "!!! Running {{DOWN}} on a non-{{DEV}} machine."
    exit 1
  fi

  local +x TYPES="$@"
  if [[ -z "$TYPES" ]]; then
    TYPES="$(list-types | tac)"
  else
    TYPES="$(echo $TYPES | tr ' ' '\n')"
  fi

  local +x IFS=$'\n'
  for NAME in $TYPES; do
    local +x MIGRATE_DIRS="$(find "Server/$NAME/migrates" -mindepth 1 -maxdepth 1 -type d)"
    if [[ -z "$MIGRATE_DIRS" ]]; then
      mksh_setup ORANGE "=== No migrate dirs found in: {{$NAME}}"
      continue
    fi

    for SQL_TARGET in $MIGRATE_DIRS; do
      mksh_setup BOLD "=== in: {{$SQL_TARGET}}"
      local +x FILES="$(find "$SQL_TARGET" -mindepth 1 -maxdepth 1 -type f -name "*.sql" | sort -V | tac)"

      if [[ -z "$FILES" ]]; then
        mksh_setup ORANGE "=== No sql files found in: {{$NAME}}"
        continue
      fi

      for SQL_FILE in $FILES; do
        mariadb_setup sql DOWN  "$SQL_FILE" | mysql && mksh_setup GREEN "=== SQL {{DOWN}}: BOLD{{$SQL_FILE}}" || {
          local +x STAT="$?"
          mksh_setup RED "!!! {{SQL DOWN failed}}: exit {{$STAT}} in BOLD{{$SQL_FILE}}"
          exit "$STAT"
        }
      done # === each SQL File
    done # === DIR of sql file groups

  done

  if is-dev; then
    rm -rf config/mariadb_snapshot
  fi
} # === end function

specs () {
  local + SNAPSHOT="config/mariadb_snapshot"
  mkdir "$SNAPSHOT"
  $0 megauni DOWN
  should-not-exist "$SNAPSHOT"

  IS_DEV="" should-exit 1 "megauni DOWN"
} # === specs ()



