#!/usr/bin/env bash
# cleanup_artifacts.sh
# Deletes the export artifact from GitHub after the app confirms download,
# and wipes all local working files for this job.
#
# Usage: cleanup_artifacts.sh <job_id> <working_dir>
# Called by the workflow's "always" step — runs even if render failed.

set -euo pipefail

JOB_ID="$1"
WORKING_DIR="$2"

echo "=== cleanup_artifacts.sh ==="
echo "Job ID      : $JOB_ID"
echo "Working dir : $WORKING_DIR"

# Remove local working files
if [ -d "$WORKING_DIR" ]; then
    rm -rf "$WORKING_DIR"
    echo "Deleted working directory: $WORKING_DIR"
fi

# Note: GitHub artifact deletion via API requires the artifact ID.
# The artifact is named "export-{job_id}" and has retention-days: 1 set
# in the workflow, so it auto-expires within 24 hours regardless.
# Explicit API deletion is done by the app after confirming download.
# This script handles only local disk cleanup on the runner.

echo "Local cleanup complete for job: $JOB_ID"
echo "Artifact 'export-$JOB_ID' will auto-expire in 24h or be deleted by app."
echo "=== cleanup done ==="
