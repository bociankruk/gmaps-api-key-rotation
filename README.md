# gmaps-api-key-rotation

## Description
Automation with GitHub Action for Google Maps API keys rotation.

Flow:
1. Authenticate to Google Cloud.
2. Generate a new Google Maps API key.
3. Store the new API key securely in the Azure Key Vault secret GoogleMapKey.
4. Delete the old API key from Google Cloud.

## Repository configuration
To authenticate to...


```
POOL_ID="github-actions-apikey-rotation"
SVC_ACCOUNT_NAME="svc-gh-rotator"
PROJECT_ID="canvas-rampart-423616-b0"

# Create workload identity
gcloud iam workload-identity-pools create "$POOL_ID" \
  --location="global" \
  --description="To authenticate for GitHUb repo gmaps-api-key-rotation"

PROVIDER_ID="${POOL_ID}"
gcloud iam workload-identity-pools providers create-oidc "$PROVIDER_ID" \
  --location="global" \
  --workload-identity-pool="$POOL_ID" \
  --attribute-mapping="google.subject=assertion.sub,attribute.actor=assertion.actor,attribute.aud=assertion.aud" \
  --issuer-uri="https://token.actions.githubusercontent.com"

# Create service account
gcloud iam service-accounts create "$SVC_ACCOUNT_NAME" \
  --description="Google Maps API key rotation" \
  --display-name="$SVC_ACCOUNT_NAME"

# Assign roles to service account
gcloud iam service-accounts add-iam-policy-binding "${SVC_ACCOUNT_NAME}@${PROJECT_ID}.iam.gserviceaccount.com" \
  --role="roles/iam.workloadIdentityUser" \
  --member="principalSet://iam.googleapis.com/projects/736236199161/locations/global/workloadIdentityPools/${POOL_ID}/attribute.repository/bociankruk/gmaps-api-key-rotation"
```

## Links
 * https://cloud.google.com/iam/docs/workload-identity-federation-with-deployment-pipelines
 * https://cloud.google.com/blog/products/identity-security/enabling-keyless-authentication-from-github-actions
