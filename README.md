# personal-animations-export

Public export server for the **Personal Animations** Android app.
This repo contains only FFmpeg shell scripts and GitHub Actions workflows.
No app source code lives here.

## How it works

1. User taps **Export MP4** in the app
2. App renders all frames as PNG files, zips them
3. App uploads the ZIP and triggers `export_mp4.yml` via GitHub API
4. This workflow:
   - Downloads the ZIP
   - Verifies all frames
   - Runs FFmpeg to produce a 1080p H.264 MP4
   - Uploads the MP4 as a GitHub Actions artifact
5. App polls for the artifact, downloads it, saves to device Downloads
6. Artifact auto-deletes after 24 hours

## Repo secrets required

Set these in **Settings → Secrets and variables → Actions** of this repo:

| Secret | Purpose |
|---|---|
| `APP_UPLOAD_TOKEN` | Token to authenticate frame ZIP download |
| `APP_CALLBACK_TOKEN` | Fine-grained PAT scoped to `personal-animations` repo for dispatch notify |

## Scripts

| Script | Purpose |
|---|---|
| `scripts/render_mp4.sh` | FFmpeg render — 1080p H.264 MP4 |
| `scripts/verify_frames.sh` | Validates frame sequence before render |
| `scripts/notify_app.sh` | Sends export result back to app repo |
| `scripts/cleanup_artifacts.sh` | Wipes local runner disk after job |

## Output

- Format: MP4 (H.264, yuv420p)
- Resolution: 1920×1080 fixed
- Quality: Low (CRF 28) / Medium (CRF 23) / High (CRF 18)
- Artifact retention: 1 day (auto-deleted)

## License

All scripts: MIT License. FFmpeg used server-side under LGPL.
