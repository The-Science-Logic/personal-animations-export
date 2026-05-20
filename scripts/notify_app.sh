#!/usr/bin/env bash
# notify_app.sh
# Notifies the app's GitHub repo via repository_dispatch that the export
# job succeeded or failed. The app polls its own repo's dispatch events
# or checks artifact availability directly via GitHub API.
#
# Usage: notify_app.sh <job_id> <status> <callback_token>
# status: "success" | "failed"

set -euo pipefail

JOB_ID="$1"
STATUS="$2"
CALLBACK_TOKEN="$3"

APP_REPO="your-account/personal-animations"

echo "=== notify_app.sh ==="
echo "Job ID : $JOB_ID"
echo "Status : $STATUS"
echo "Repo   : $APP_REPO"

# Send repository_dispatch event to private app repo
# The app polls /repos/{owner}/{repo}/actions/artifacts filtered by job_id name
# This notify step is a secondary signal — artifact presence is the primary signal

HTTP_CODE=$(curl -s -o /tmp/notify_response.json -w "%{http_code}" \
    -X POST \
    -H "Accept: application/vnd.github+json" \
    -H "Authorization: Bearer $CALLBACK_TOKEN" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    "https://api.github.com/repos/$APP_REPO/dispatches" \
    -d "{
        \"event_type\": \"export_complete\",
        \"client_payload\": {
            \"job_id\": \"$JOB_ID\",
            \"status\": \"$STATUS\"
        }
    }")

echo "GitHub API response code: $HTTP_CODE"
cat /tmp/notify_response.json || true

# 204 = success (no content), 404 = repo not found, 422 = bad payload
if [ "$HTTP_CODE" != "204" ]; then
    echo "WARNING: Notify returned HTTP $HTTP_CODE. App will fall back to polling."
    # Do not exit 1 here — a notify failure should not fail the whole workflow
fi

echo "=== notify_app.sh done ==="
