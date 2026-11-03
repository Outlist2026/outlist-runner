# Creates the public repo, pushes it and sets the secrets. PowerShell 5.1. Run it yourself; values are typed at the prompt and never printed.
$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot
$Repo = 'Outlist2026/outlist-runner'
gh auth status
gh repo view $Repo 2>$null; if ($LASTEXITCODE -ne 0) { gh repo create $Repo --public --source . --remote origin --push }
foreach ($s in 'SOURCE_REPO_TOKEN', 'PERSONAL_REPO_TOKEN') { gh secret set $s --repo $Repo }
gh variable set SUPABASE_PROJECT_REF --repo $Repo --body 'mvstcieoabimbwiuhsof'
Write-Host 'Done. Read-only workflows ready: Hotfix verify, Verify OTA.' -ForegroundColor Green
Write-Host 'Next, for the write workflows (Deploy edge functions, Ship migration, Ship web): .\setup-environment.ps1' -ForegroundColor Yellow
