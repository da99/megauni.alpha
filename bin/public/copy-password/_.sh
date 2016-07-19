
source "$THIS_DIR/bin/public/is-dev/_.sh"

# === {{CMD}}
copy-password () {
  if ! is-dev; then
    mksh_setup RED "!!! Not a {{dev}} machine."
    exit 1
  fi
  echo -n $(cat ~/.my.cnf | grep password  | cut -d'=' -f2) | xclip -selection clip
} # === end function
