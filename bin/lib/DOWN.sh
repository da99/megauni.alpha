
source "$THIS_DIR/bin/lib/list-types.sh"

# === {{CMD}}
DOWN () {
  local +x IFS=$'\n'
  for NAME in $(list-types | tac) ; do
    mariadb_setup DOWN "$NAME" "Server/$NAME/migrates"
  done
} # === end function
