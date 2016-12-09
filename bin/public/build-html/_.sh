
# === {{CMD}}  "Server/NAME"
build-html () {
  cd "$THIS_DIR"

  local +x INPUT="$1"; shift
  local +x NAME="$(basename "$INPUT")"
  local +x OUTPUT="Public/applets/$NAME"

  # === Reset OUTPUT  dir:
  mkdir -p "$OUTPUT"
  reset-dir "$NAME"

  # === Build it:
  dum_dum_boom_boom build-html   "$INPUT"  "$OUTPUT"  "Public/"

  # === Finish. Print results:
  # tput cuu1; tput el
  # sh_color GREEN "-n" "=== Output in: {{$OUTPUT}}: "
  # echo $OUTPUT/*.html
} # === end function

reset-dir () {
  local +x FILES="$(find Public/applets/$1 -type f -name "*.html")"
  if [[ -z "$FILES" ]]; then
    return 0
  fi

  set -x
  rm -rf "$FILES"
}
