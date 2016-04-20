
# === {{CMD}}  Applet-Name/File-Name     # e.g Browser/Megauni
# === Builds a JavaScript file for the browser.

append-file-if-exists () {
  local +x FILE="$1"; shift
  local +x OUTPUT="$1"; shift

  if [[ -s "$FILE" ]]; then
    cat "$FILE" >>"$OUTPUT"
  fi
}

build-browser () {

  local +x DIR="$1"; shift
  local +x NAME=$(basename "$DIR")
  local +x APPLET_NAME=$(basename "$(dirname "$DIR")")
  local +x OUTPUT="Public/applets/$APPLET_NAME/$NAME"
  local +x FILES=$(find Server/$DIR -type f -name "*.js")

  mkdir -p "$(dirname "$OUTPUT")"
  rm -rf "$OUTPUT".js
  rm -rf "$OUTPUT".specs.js

  append-file-if-exists "$DIR"/_.top.js      "$OUTPUT".js
  paste --delimiter=\\n --serial $(echo -e "$FILES" | grep -v '_.\(top\|bottom\).js') >> "$OUTPUT".js
  append-file-if-exists "$DIR"/_.bottom.js  "$OUTPUT".js

  js_setup jshint "$OUTPUT".js
  mksh_setup GREEN "=== wrote {{$OUTPUT.js}}"

} # === end function
