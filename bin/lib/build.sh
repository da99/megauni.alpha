
# === {{CMD}}
# === {{CMD}}  "NAME"

reset-dir () {
  local +x DIR="$1"; shift
  if [[ "$DIR" != Public/applets/* ]]; then
    mksh_setup RED "!!! Invalid directory to reset: $DIR"
    exit 1
  fi
  rm -rf "$DIR"
  mkdir -p "$DIR"
}

build () {
  if [[ -z "$@" ]]; then
    reset-dir Public/applets/

    build "Homepage"
    build "MUE"
    build "Browser"
    $0 build-browser "Browser/Megauni"

    local +x JS_FILES=$(find Public/applets -type f -name "*.js")
    mksh_setup ORANGE "=== {{eslinting}}: $JS_FILES"
    js_setup eslint browser $JS_FILES
    tput cuu1; tput el
    mksh_setup GREEN "=== {{Passed}} eslint: $JS_FILES"

    mksh_setup GREEN "=== Done {{building}}."
    return 0
  fi # =====================================================

  local +x NAME="$1"; shift
  local +x INPUT="Server/$NAME"
  local +x OUTPUT="Public/applets/$NAME"

  # === Reset OUTPUT  dir:
  reset-dir "$OUTPUT"

  # === Build it:
  cd "$THIS_DIR"
  mksh_setup ORANGE "=== {{Building}} $INPUT ..."
  dum_dum_boom_boom html           \
    --input-dir  "$INPUT"           \
    --output-dir "$OUTPUT"           \
    --public-dir "Public/"

  # === Finish. Print results:
  tput cuu1; tput el
  mksh_setup GREEN "-n" "=== Output in: {{$OUTPUT}}: "
  echo $OUTPUT/*.html
} # === end function
