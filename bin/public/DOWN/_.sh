
source "$THIS_DIR/bin/public/list-types/_.sh"
source "$THIS_DIR/bin/public/is-dev/_.sh"

# === {{CMD}}
# === {{CMD}} Type_Name Another_Type ...
DOWN () {
  if ! is-dev; then
    sh_color RED "!!! Running {{DOWN}} on a non-{{DEV}} machine."
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
    local +x MIGRATE_DIRS="$(find "Server/$NAME/migrates" -mindepth 1 -maxdepth 1 -type d | sort -V)"
    if [[ -z "$MIGRATE_DIRS" ]]; then
      sh_color ORANGE "=== No migrate dirs found in: {{$NAME}}"
      continue
    fi

    for SQL_TARGET in $MIGRATE_DIRS; do
      sh_color BOLD "=== in: {{$SQL_TARGET}}"
      local +x FILES="$(find "$SQL_TARGET" -mindepth 1 -maxdepth 1 -type f -name "*.sql" | sort -V | tac)"

      if [[ -z "$FILES" ]]; then
        sh_color ORANGE "=== No sql files found in: {{$NAME}}"
        continue
      fi

      for SQL_FILE in $FILES; do
        mariadb_setup sql DOWN  "$SQL_FILE" | mysql && sh_color GREEN "=== SQL {{DOWN}}: BOLD{{$SQL_FILE}}" || {
          local +x STAT="$?"
          sh_color RED "!!! {{SQL DOWN failed}}: exit {{$STAT}} in BOLD{{$SQL_FILE}}"
          exit "$STAT"
        }
      done # === each SQL File
    done # === DIR of sql file groups

  done

  if is-dev; then
    rm -rf config/mariadb_snapshot
  fi
} # === end function




