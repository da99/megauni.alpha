
# === {{CMD}}
is-dev () {
   test -n "$IS_DEV"
} # === end function

specs () {
   IS_DEV="yes" should-exit 0 "megauni is-dev"
   IS_DEV=""    should-exit 1 "megauni is-dev"
} # === specs ()
