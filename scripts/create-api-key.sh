#/bin/bash

set -euo pipefail

api_key_name=${API_KEY_NAME:-gha-rotated-key}
GITHUB_ENV=${GITHUB_ENV:-/tmp/github-output-local}

echo "List existing keys"
gcloud services api-keys list --format="value(name)"

new_key_json=$(gcloud services api-keys create \
    --display-name="${api_key_name}" \
    --format=json \
    2> /dev/null \
    | jq -c '.response | {name: .name, api_key: .keyString}')


NEW_API_KEY_ID=$(echo $new_key_json | jq -r '.name')
NEW_API_KEY_SECRET=$(echo $new_key_json | jq -r '.api_key')

echo "NEW_API_KEY_ID=$NEW_API_KEY_ID" >> $GITHUB_ENV
echo "NEW_API_KEY_SECRET=$NEW_API_KEY_SECRET" >> $GITHUB_ENV
