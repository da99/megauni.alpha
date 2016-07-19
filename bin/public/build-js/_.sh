
# === {{CMD}}  Applet-Name/File-Name     # e.g Browser/Megauni
# === Builds a JavaScript file for the browser and saves it to
# === Public/applets/Applet-Name/File-Name.js

append-file-if-exists () {
  local +x FILE="$1"; shift
  local +x OUTPUT="$1"; shift

  if [[ -s "$FILE" ]]; then
    cat "$FILE" >>"$OUTPUT"
  fi
}

build-js () {

  local +x DIR="$1"; shift
  local +x NAME=$(basename "$DIR")
  local +x APPLET_NAME=$(basename "$(dirname "$DIR")")
  local +x OUTPUT="Public/applets/$APPLET_NAME/$NAME"

  mkdir -p "$(dirname "$OUTPUT")"
  rm -rf "$OUTPUT".js
  rm -rf "$OUTPUT".specs.js

  dum_dum_boom_boom build-js "$OUTPUT" "$DIR"
} # === end function
