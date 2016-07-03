# === 
# === 
set -u -e -o pipefail


should-match "200" "curl --write-out %{http_code} --silent --output /dev/null http://localhost:4567/" \
  "Homepage returns: 200"
