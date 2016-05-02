
source "$THIS_DIR/bin/lib/list-types.sh"

# === {{CMD}}
# === {{CMD}} Type_Name Another_Type ...
UP () {
  local +x TYPES="$@"
  if [[ -z "$TYPES" ]]; then
    TYPES="$(list-types | tr '\n' ' ')"
  fi

  for NAME in $TYPES ; do
    mariadb_setup UP "$NAME" "Server/$NAME/migrates"
  done
} # === end function
