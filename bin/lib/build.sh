
# === {{CMD}}
# === {{CMD}}  "NAME"
build () {
  if [[ -z "$@" ]]; then
    mksh_setup ORANGE "=== {{Building}}..." >&2
    build "Homepage"
    mksh_setup GREEN "=== Done {{building}}." >&2
    return 0
  fi

  local +x NAME="$1"; shift
  local +x INPUT="Server/$NAME"
  local +x OUTPUT="Public/applets/$NAME"
  mkdir -p "$OUTPUT"

  cd "$THIS_DIR"
  dum_dum_boom_boom html           \
    --input-dir  "$INPUT"           \
    --output-dir "$OUTPUT"           \
    --public-dir "Public/"
} # === end function
