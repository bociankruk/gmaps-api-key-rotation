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
REPOSITORY_ID="802606416"

# Create workload identity
gcloud iam workload-identity-pools create "$POOL_ID" \
  --location="global" \
  --description="To authenticate for GitHUb repo gmaps-api-key-rotation"

PROVIDER_ID="${POOL_ID}"
gcloud iam workload-identity-pools providers create-oidc "$PROVIDER_ID" \
  --location="global" \
  --workload-identity-pool="$POOL_ID" \
  --attribute-mapping="google.subject=assertion.sub,attribute.repository=assertion.repository" \
  --attribute-condition="attribute.repository_id==\"${REPOSITORY_ID}\""
  --issuer-uri="https://token.actions.githubusercontent.com"
```

## Potential improvements

## Links
 * https://cloud.google.com/iam/docs/workload-identity-federation-with-deployment-pipelines
 * https://cloud.google.com/blog/products/identity-security/enabling-keyless-authentication-from-github-actions
 * https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-azure
