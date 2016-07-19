
specs () {
  local + SNAPSHOT="config/mariadb_snapshot"
  mkdir "$SNAPSHOT"
  $0 megauni DOWN
  should-not-exist "$SNAPSHOT"

  IS_DEV="" should-exit 1 "megauni DOWN"
} # === specs ()

specs
