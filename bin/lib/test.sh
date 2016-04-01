
# === {{CMD}}
# === {{CMD}} reset
# === {{CMD}} Model spec
test () {
  file="/tmp/specs.are.running"
  # === Run all the specs of the projects.
  touch $file
  PORT=4001 mix run specs/Spec.ex $@
  rm "$file" || :
} # === end function
