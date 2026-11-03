# Creates the Environment "production" with YOU as required reviewer, so the write workflows (deploy-functions, ship-migration, ship-web)
# pause until you approve. PowerShell 5.1. Run it before the first use of any of them: a workflow that names a missing environment
# creates it WITHOUT reviewers, and then nothing pauses.
# Environment secrets are handed to a job only after approval: put the powerful ones here, not at repository level.
$ErrorActionPreference = 'Stop'
$Repo = 'Outlist2026/outlist-runner'
gh auth status
$me = gh api user --jq .id
'{"reviewers":[{"type":"User","id":' + $me + '}],"deployment_branch_policy":{"protected_branches":false,"custom_branch_policies":true}}' | gh api -X PUT "repos/$Repo/environments/production" --input -
gh api -X POST "repos/$Repo/environments/production/deployment-branch-policies" -f name=main | Out-Null
Write-Host 'Environment production created: required reviewer = you, only the main branch may run.' -ForegroundColor Green
Write-Host 'Now set the environment secrets (values are typed at the prompt, never printed):'
foreach ($s in 'SUPABASE_ACCESS_TOKEN', 'PERSONAL_WRITE_TOKEN', 'ORG_WRITE_TOKEN') { gh secret set $s --env production --repo $Repo }
Write-Host 'PERSONAL_WRITE_TOKEN: fine-grained, owner FlavioApric, repo outlist, Pull requests: write + Contents: read.'
Write-Host 'ORG_WRITE_TOKEN: fine-grained, owner Outlist2026, repo outlist, Contents: write.'
Write-Host 'Also set PERSONAL_REPO_TOKEN (repository secret): fine-grained, owner FlavioApric, repo outlist, Contents: read-only.'
