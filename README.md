# Outlist runner

Public repository that holds only GitHub Actions workflows for Outlist, so the heavy jobs run on free public-repository minutes. **No source code lives here**: each workflow checks out `Outlist2026/outlist` (private) with a read-only token.

## Read this first: everything here is public
- Workflow files, run logs and artifacts are readable by anyone. Secrets are masked in logs, but never print a file, a key or a token in a step.
- Every workflow is started by hand (`workflow_dispatch`). Do not add `push`, `pull_request` or `pull_request_target` triggers. Only people with write access can start a run, so add no collaborators you do not trust: a collaborator could edit a workflow and read the secrets.
- Leave "Run workflows from fork pull requests" at its default and keep "Send secrets to workflows from fork pull requests" off.
- Nothing is uploaded as an artifact (it would be public).

## Workflows
| Workflow | Writes? | What it does |
|---|---|---|
| `hotfix-verify` | no | Checks out a ref of the private repo and runs lint, typecheck, build, unit tests, covers tests and the OTA-compatibility test. Tells you if the change is web only (OTA) or needs a store build. |
| `deploy-functions` | production (needs `confirm=YES`) | Deploys the listed edge functions with the Supabase CLI from the runner, so no local network is needed. `verify_jwt` comes from `supabase/config.toml`. |
| `verify-ota` | no | Waits until `https://app.outlist.org/ota/manifest.json` reaches a commit. Needs no secret. |

## Set it up (you run this; nothing here runs it)
```powershell
.\setup.ps1
```
It creates the public repo, pushes it and asks for each secret value (nothing is printed):
- `SOURCE_REPO_TOKEN`: fine-grained token, read-only "Contents" on `Outlist2026/outlist`.
- `SUPABASE_ACCESS_TOKEN`: the `sbp_...` personal access token (only used by `deploy-functions`).
- variable `SUPABASE_PROJECT_REF`.

## Check before relying on it
GitHub's free-minutes policy for public repositories can change; check it before you depend on it.
