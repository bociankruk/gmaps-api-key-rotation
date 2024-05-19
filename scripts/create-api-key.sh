#/bin/bash

set -euo pipefail

api_key_name=${API_KEY_NAME:-gha-rotated-key}

gcloud info

echo "List existing keys"
gcloud services api-keys list --format="value(name)"

NEW_KEY=$(gcloud services api-keys create \
    --display-name="${api_key_name}" \
    --format="value(key)")

echo $NEW_KEY
