
source "$THIS_DIR/bin/lib/list-types.sh"

# === {{CMD}}
# === {{CMD}} Type_Name Another_Type ...
DOWN () {
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
} # === end function
