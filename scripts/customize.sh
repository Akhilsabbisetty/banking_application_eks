#!/usr/bin/env bash
# Replace the tutor's hard-coded values with yours, in one go.
# Run ONCE from the repo root, BEFORE your first commit/push.
#
#   DOMAIN=ascloud.space ACCOUNT_ID=463423328685 \
#   GH_OWNER=Akhilsabbisetty GH_REPO=banking_application_eks \
#   ACME_EMAIL=sabbsiettyakhil2414@gmail.com ./scripts/customize.sh
set -euo pipefail

: "${DOMAIN:?set DOMAIN, e.g. ascloud.space}"
: "${ACCOUNT_ID:?set ACCOUNT_ID (12-digit AWS account id)}"
: "${GH_OWNER:?set GH_OWNER (your GitHub username/org)}"
: "${GH_REPO:?set GH_REPO (your repo name)}"
: "${ACME_EMAIL:?set ACME_EMAIL (for Lets Encrypt expiry notices)}"

FILES=$(grep -rIl --exclude-dir=node_modules --exclude-dir=.git \
  -e 'vijaygiduthuri' -e '118178010323' -e '<YOUR_ACCOUNT_ID>' \
  terraform deploy .github 2>/dev/null || true)

for f in $FILES; do
  sed -i \
    -e "s#github.com/vijaygiduthuri/banking_application_eks.git#github.com/${GH_OWNER}/${GH_REPO}.git#g" \
    -e "s#vijaygiduthuri@gmail.com#${ACME_EMAIL}#g" \
    -e "s#vijaygiduthuri\.in#${DOMAIN}#g" \
    -e "s#118178010323#${ACCOUNT_ID}#g" \
    -e "s#<YOUR_ACCOUNT_ID>#${ACCOUNT_ID}#g" \
    "$f"
  echo "updated $f"
done

echo
echo "Remaining tutor references (should be none in terraform/ deploy/ .github/):"
grep -rIn --exclude-dir=node_modules -e 'vijaygiduthuri' -e '118178010323' -e '<YOUR_ACCOUNT_ID>' terraform deploy .github || echo "  none"
