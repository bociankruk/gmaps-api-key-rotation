#/bin/bash

set -euo pipefail

api_key_name=${API_KEY_NAME:-gha-rotated-key}
new_api_key_id=${NEW_API_KEY_ID}
api_key_name=${API_KEY_NAME:-gha-rotated-key}

old_key_ids=$(gcloud services api-keys list \
    --filter="displayName:${api_key_name}" \
    --format="value(name)")

echo "Found old keys:"
echo "$old_key_ids"

echo "Key to retain:"
echo "$new_api_key_id"

for key in $old_key_ids; do
    if [ "$key" != "$new_api_key_id" ]; then
        gcloud services api-keys delete $key
        echo "Deleted API key $key."
    fi
done
