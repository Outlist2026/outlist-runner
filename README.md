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
| `hotfix-verify` | no | Checks out a ref of a private repo (org or personal) and runs lint, typecheck, build, unit tests, covers tests, the delivery-type check and the OTA-compatibility test. Tells you if the change is web only (OTA) or needs a store build. |
| `deploy-functions` | production, **needs your approval** | Deploys the listed edge functions with the Supabase CLI from the runner, so no local network is needed. `verify_jwt` comes from `supabase/config.toml`. |
| `ship-migration` | production, **needs your approval** | Applies ONE additive migration (14-digit version) with its `schema_migrations` row in a single request. Refuses DROP/TRUNCATE unless `allow_destructive=YES`. |
| `ship-web` | production, **needs your approval** | Gate, then merge the PR, push main fast-forward to the org repo (Cloudflare builds web + OTA), wait for the OTA manifest. |
| `verify-ota` | no | Waits until `https://app.outlist.org/ota/manifest.json` reaches a commit. Needs no secret. |

## Set it up (you run this; nothing here runs it)
```powershell
.\setup.ps1               # repo, read-only tokens, project ref
.\setup-environment.ps1   # Environment "production" with you as required reviewer, and the write secrets
```
Repository secrets (read-only, for the checkout): `SOURCE_REPO_TOKEN` (Contents: read on `Outlist2026/outlist`) and `PERSONAL_REPO_TOKEN` (Contents: read on `FlavioApric/outlist`, where fix PR branches live). Variable `SUPABASE_PROJECT_REF`.

Environment secrets (only given to a job after you approve it): `SUPABASE_ACCESS_TOKEN`, `PERSONAL_WRITE_TOKEN` (pull requests: write on `FlavioApric/outlist`), `ORG_WRITE_TOKEN` (contents: write on `Outlist2026/outlist`).

**Run `setup-environment.ps1` before the first write workflow.** A workflow that names a missing environment creates it with no reviewer, and then nothing pauses.

## Check before relying on it
GitHub's free-minutes policy for public repositories can change; check it before you depend on it.
