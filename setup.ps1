# Creates the public repo, pushes it and sets the secrets. PowerShell 5.1. Run it yourself; values are typed at the prompt and never printed.
$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot
$Repo = 'FlavioApric/outlist-runner'
gh auth status
gh repo create $Repo --public --source . --remote origin --push
foreach ($s in 'SOURCE_REPO_TOKEN', 'SUPABASE_ACCESS_TOKEN') { gh secret set $s --repo $Repo }
gh variable set SUPABASE_PROJECT_REF --repo $Repo --body 'mvstcieoabimbwiuhsof'
Write-Host 'Done. Actions tab: Hotfix verify, Deploy edge functions, Verify OTA.' -ForegroundColor Green
