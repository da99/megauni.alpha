
source "$THIS_DIR/bin/lib/list-types.sh"

# === {{CMD}}
UP () {
  local +x IFS=$'\n'
  for NAME in $(list-types) ; do
    mariadb_setup UP "$NAME" "Server/$NAME/migrates"
  done
} # === end function
