
# === {{CMD}}
# === Prints a list of server OS process.
# === Prints to STDERR if no proces found.
# === Always exits w/ 0
status () {
    pgrep -f "elixir.+megauni\.server(\s|$|,)" || (echo "=== No process found" 1>&2)
} # === end function
