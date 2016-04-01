
# === {{CMD}} "{.. JSON .. }"  /path
POST () {
  curl -k -X POST --header "Content-Type:application/json" -d "$1" http://localhost:4567$2
  echo ""
} # === end function
