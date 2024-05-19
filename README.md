# gmaps-api-key-rotation

## Description
Automation with GitHub Action for Google Maps API keys rotation.

Flow:
1. Authenticate to Google Cloud.
2. Generate a new Google Maps API key.
3. Store the new API key securely in the Azure Key Vault secret GoogleMapKey.
4. Delete the old API key from Google Cloud.


## Repository configuration
GitHub actions need to connect to Google Cloud to manage API keys and to Azure Cloud to store secret in Key vault.
In both cases Workload identity is used to assure password-less ans secure authentication.

### Google Cloud IAM
```
POOL_ID="github-actions-apikey-rotation"
REPOSITORY_ID="802606416"
PROJECT_ID="canvas-rampart-423616-b0"

# Create workload identity
gcloud iam workload-identity-pools create "$POOL_ID" \
  --location="global" \
  --description="To authenticate for GitHUb repo gmaps-api-key-rotation"

# Create provider
PROVIDER_ID="${POOL_ID}"
gcloud iam workload-identity-pools providers create-oidc "$PROVIDER_ID" \
  --location="global" \
  --workload-identity-pool="$POOL_ID" \
  --attribute-mapping="google.subject=assertion.sub,attribute.repository=assertion.repository" \
  --attribute-condition="attribute.repository_id==\"${REPOSITORY_ID}\""
  --issuer-uri="https://token.actions.githubusercontent.com"

# Add required permissions assigned to desired repository
gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
    --member "principalSet://iam.googleapis.com/projects/736236199161/locations/global/workloadIdentityPools/github-actions-apikey-rotation/attribute.repository_id/${REPOSITORY_ID}" \
    --role "roles/iam.workloadIdentityUser"
gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
    --member "principalSet://iam.googleapis.com/projects/736236199161/locations/global/workloadIdentityPools/github-actions-apikey-rotation/attribute.repository_id/${REPOSITORY_ID}" \
    --role "roles/iam.serviceAccountKeyAdmin"
```

### Azure managed identity
Manual configuration according to https://www.gatevnotes.com/passwordless-authentication-github-actions-to-microsoft-azure/.
Once managed identity has been created, create Key Vault and assign role "Key Vault Secrets Officer" for created managed identity.


## Potential improvements

### Setup workload identity with IaC
Instead of manual code execution and manual UI operation, workload identity configuration should be performed with Infrastructure as a Code approach. Ideal candidate here will be to use Terraform to do that.

### Switch to multi job workflow
It make sense to split Rotate workflow into multiple jobs, like:
* create new key
* update key on key vault
* delete old API keys

Unfortunately, GitHUb actions forbid passing secrets between jobs.

More can be found: https://github.com/orgs/community/discussions/25225#discussioncomment-6776295

Official documentation states that to do it, some external mechanism needs to be implemented. In case of this exercise to make it simpler, all logic is within single job. Official recommendation is described here: https://docs.github.com/en/actions/using-workflows/workflow-commands-for-github-actions#example-masking-and-passing-a-secret-between-jobs-or-workflows

### PR test
Write some simple workflow for pull request, to test that new changes are not breaking the flow.


## Links
 * https://cloud.google.com/iam/docs/workload-identity-federation-with-deployment-pipelines
 * https://cloud.google.com/blog/products/identity-security/enabling-keyless-authentication-from-github-actions
 * https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-azure
