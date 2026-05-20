#!/usr/bin/env bash
# verify_frames.sh
# Checks that all expected frames exist and are valid PNGs.
# Usage: verify_frames.sh <frames_dir> <expected_total_frames>

set -euo pipefail

FRAMES_DIR="$1"
EXPECTED="$2"

echo "=== verify_frames.sh ==="
echo "Directory : $FRAMES_DIR"
echo "Expected  : $EXPECTED frames"

if ! [[ "$EXPECTED" =~ ^[0-9]+$ ]] || [ "$EXPECTED" -lt 1 ]; then
    echo "ERROR: Invalid expected frame count: $EXPECTED"
    exit 1
fi

MISSING=0
CORRUPT=0

for i in $(seq 1 "$EXPECTED"); do
    FNAME=$(printf "frame_%06d.png" "$i")
    FPATH="$FRAMES_DIR/$FNAME"

    # Check file exists
    if [ ! -f "$FPATH" ]; then
        echo "MISSING: $FNAME"
        MISSING=$((MISSING + 1))
        continue
    fi

    # Check file is not empty
    SIZE=$(stat -c%s "$FPATH")
    if [ "$SIZE" -lt 100 ]; then
        echo "CORRUPT (too small, ${SIZE}B): $FNAME"
        CORRUPT=$((CORRUPT + 1))
        continue
    fi

    # Check PNG header magic bytes (first 8 bytes: 89 50 4E 47 0D 0A 1A 0A)
    MAGIC=$(xxd -p -l 8 "$FPATH")
    if [ "$MAGIC" != "89504e470d0a1a0a" ]; then
        echo "CORRUPT (invalid PNG header): $FNAME"
        CORRUPT=$((CORRUPT + 1))
    fi
done

echo "Missing frames : $MISSING"
echo "Corrupt frames : $CORRUPT"

if [ "$MISSING" -gt 0 ] || [ "$CORRUPT" -gt 0 ]; then
    echo "ERROR: Frame verification failed."
    exit 1
fi

echo "All $EXPECTED frames verified OK."
