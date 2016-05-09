
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
    mariadb_setup DOWN "$NAME" "Server/$NAME/migrates"
  done

  if [[ -n "$IS_DEV" ]]; then
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



