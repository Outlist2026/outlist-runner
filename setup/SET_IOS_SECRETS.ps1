# Outlist runner - one time: put the iOS signing and App Store Connect secrets into the Environment "production"
# of the PUBLIC repo Outlist2026/outlist-runner. Environment secrets are encrypted, never shown in logs, and the
# job gets them only after you approve the run. Run it yourself (Windows PowerShell):
#   powershell -NoProfile -ExecutionPolicy Bypass -File C:\Users\flavi\dev\outlist-runner\setup\SET_IOS_SECRETS.ps1
# It reads the files in the Drive folder DEPLOY\capacitor and asks only for the .p12 password, the Key ID and the Issuer ID.
# Nothing is printed or written to disk.
$ErrorActionPreference = 'Stop'
$Repo = 'Outlist2026/outlist-runner'
$Env = 'production'
$Cap = 'G:\Il mio Drive\HD_Acer_Copia\_F\progetti\progetto social-app-amsterdam\specifiche e documentazione tecnica\DEPLOY\capacitor'
$ApiKeys = 'G:\Il mio Drive\HD_Acer_Copia\_F\progetti\progetto social-app-amsterdam\specifiche e documentazione tecnica\apikeys.txt'

function Put($name, [string]$value) {
  if (-not $value) { throw "$name is empty" }
  $value | gh secret set $name -R $Repo --env $Env
  if ($LASTEXITCODE) { throw "gh secret set $name failed" }
  Write-Host "  set $name" -ForegroundColor Green
}
function B64($path) { if (-not (Test-Path $path)) { throw "missing file: $path" }; [Convert]::ToBase64String([IO.File]::ReadAllBytes($path)) }
function Plain($secure) { [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure)) }

gh auth status *> $null; if ($LASTEXITCODE) { throw 'gh is not logged in: run  gh auth login' }
Write-Host "Secrets go to $Repo, Environment '$Env'." -ForegroundColor Cyan

Put 'IOS_DISTRIBUTION_CERTIFICATE_BASE64' (B64 (Join-Path $Cap 'Certificates.p12'))
Put 'IOS_PROVISIONING_PROFILE_BASE64' (B64 (Join-Path $Cap 'Outlist_Distribution_Profile.mobileprovision'))
$pw = Plain (Read-Host 'Password of Certificates.p12 (Enter if it has none)' -AsSecureString)
if ($pw) { Put 'IOS_CERTIFICATE_PASSWORD' $pw } else { ' ' | gh secret set IOS_CERTIFICATE_PASSWORD -R $Repo --env $Env; Write-Host '  set IOS_CERTIFICATE_PASSWORD (empty)' }

Write-Host "`nApp Store Connect API key (App Store Connect > Users and Access > Integrations > Keys)." -ForegroundColor Cyan
$p8s = @(Get-ChildItem $Cap -Filter '*.p8')
for ($i = 0; $i -lt $p8s.Count; $i++) { Write-Host "  [$i] $($p8s[$i].Name)" }
$pick = Read-Host "Which .p8 is the key used by GitHub Actions? (number)"
$keyId = Read-Host 'Key ID of that key (10 characters)'
$issuer = Read-Host 'Issuer ID (uuid shown above the keys list)'
Put 'APP_STORE_CONNECT_API_KEY' (Get-Content $p8s[[int]$pick].FullName -Raw)
Put 'APP_STORE_CONNECT_KEY_ID' $keyId.Trim()
Put 'APP_STORE_CONNECT_ISSUER_ID' $issuer.Trim()

# Public values of the web build (the anon key is public by design)
$pat = [regex]::Match((Get-Content $ApiKeys -Raw), 'sbp_[A-Za-z0-9]+').Value
$keys = Invoke-RestMethod -Uri 'https://api.supabase.com/v1/projects/mvstcieoabimbwiuhsof/api-keys' -Headers @{ Authorization = "Bearer $pat" }
Put 'VITE_SUPABASE_URL' 'https://mvstcieoabimbwiuhsof.supabase.co'
Put 'VITE_SUPABASE_ANON_KEY' (($keys | Where-Object { $_.name -eq 'anon' } | Select-Object -First 1).api_key)

Write-Host "`nDone. Start the build with:" -ForegroundColor Green
Write-Host '  gh workflow run ios-build.yml -R Outlist2026/outlist-runner -f repo=Outlist2026/outlist -f ref=main -f version_number=3.4.0 -f build_number=340 -f upload_to_testflight=true'
Write-Host 'then approve it: GitHub > Outlist2026/outlist-runner > Actions > the run > Review deployments > production > Approve.'
