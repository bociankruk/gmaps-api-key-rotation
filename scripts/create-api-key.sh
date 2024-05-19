#/bin/bash

api_key_name=${API_KEY_NAME:-gha-rotated-key}

gcloud projects get-iam-policy canvas-rampart-423616-b0

echo "List existing keys"
gcloud services api-keys list --format="value(name)"

NEW_KEY=$(gcloud services api-keys create \
    --display-name="${api_key_name}" \
    --format="value(key)")
