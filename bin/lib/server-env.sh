
# === {{CMD}}
server-env () {
 if [[ -z "${IS_DEV:-}" ]] ; then
   echo "PROD"
 else
   echo "DEV"
 fi
} # === end function
