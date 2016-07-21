
# === {{CMD}}  Name  type
run-specs () {
  local +x COMPUTER="$1"; shift
  local +x SPEC_TYPE="$1"; shift
  local +x DIR="Server/$COMPUTER/specs/$SPEC_TYPE"
  local +x IFS=$'\n'
  echo ""
  for SPEC in $(sh_specs ls-specs "$DIR"); do
    mksh_setup BOLD "Server/{{$COMPUTER}}/specs/{{$SPEC_TYPE}}/{{$(basename "$SPEC")}}"
    sh_specs run-file "$SPEC"
    echo ""
  done
} # === end function
