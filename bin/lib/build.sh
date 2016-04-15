
# === {{CMD}}
build () {
  cd "$THIS_DIR"
  dum_dum_boom_boom html           \
    --input-dir "Server/"           \
    --output-dir "Public/applets"    \
    --public-dir "Public/"
} # === end function
