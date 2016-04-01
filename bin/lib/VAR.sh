source "$THIS_DIR/bin/lib/server-env.sh"

# === {{CMD}}  name
VAR () {
  cat "config/$(server-env)/$1"
} # === end function
