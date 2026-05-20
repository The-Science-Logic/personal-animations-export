#!/usr/bin/env bash
# render_mp4.sh
# Usage: render_mp4.sh <frames_dir> <output_path> <fps> <quality>
# All arguments are required.
# Frames must be named frame_000001.png, frame_000002.png ... (6-digit zero-padded)

set -euo pipefail

FRAMES_DIR="$1"
OUTPUT_PATH="$2"
FPS="$3"
QUALITY="$4"

echo "=== render_mp4.sh ==="
echo "Frames dir : $FRAMES_DIR"
echo "Output     : $OUTPUT_PATH"
echo "FPS        : $FPS"
echo "Quality    : $QUALITY"

# Validate FPS is a sane integer
if ! [[ "$FPS" =~ ^[0-9]+$ ]] || [ "$FPS" -lt 1 ] || [ "$FPS" -gt 60 ]; then
    echo "ERROR: Invalid FPS value: $FPS. Must be integer 1–60."
    exit 1
fi

# Quality presets → CRF value (lower = better quality, larger file)
# H.264 CRF: 0 (lossless) – 51 (worst). 18=high, 23=medium, 28=low
case "$QUALITY" in
    high)
        CRF=18
        PRESET="slow"
        ;;
    medium)
        CRF=23
        PRESET="medium"
        ;;
    low)
        CRF=28
        PRESET="fast"
        ;;
    *)
        echo "ERROR: Unknown quality '$QUALITY'. Use: low | medium | high"
        exit 1
        ;;
esac

echo "CRF preset : $CRF ($PRESET)"

# Count frames for verification
FRAME_COUNT=$(ls "$FRAMES_DIR"/frame_*.png 2>/dev/null | wc -l)
echo "Frame count: $FRAME_COUNT"

if [ "$FRAME_COUNT" -lt 1 ]; then
    echo "ERROR: No frames found in $FRAMES_DIR matching frame_*.png"
    exit 1
fi

# FFmpeg render
# -framerate        : input frame rate
# -i                : input pattern (6-digit zero-padded)
# -c:v libx264      : H.264 codec (royalty-free via GPL FFmpeg)
# -crf              : quality (constant rate factor)
# -preset           : encode speed/compression trade-off
# -pix_fmt yuv420p  : maximum compatibility (required for iOS/Android/web players)
# -vf scale         : ensure exactly 1920x1080, pad if needed (keeps aspect ratio)
# -movflags +faststart : move moov atom to start for progressive playback
# -r                : output frame rate (matches input)
# -y                : overwrite output without asking

ffmpeg \
    -framerate "$FPS" \
    -i "$FRAMES_DIR/frame_%06d.png" \
    -c:v libx264 \
    -crf "$CRF" \
    -preset "$PRESET" \
    -pix_fmt yuv420p \
    -vf "scale=1920:1080:force_original_aspect_ratio=decrease,pad=1920:1080:(ow-iw)/2:(oh-ih)/2:black" \
    -movflags +faststart \
    -r "$FPS" \
    -y \
    "$OUTPUT_PATH"

EXIT_CODE=$?

if [ $EXIT_CODE -ne 0 ]; then
    echo "ERROR: FFmpeg exited with code $EXIT_CODE"
    exit $EXIT_CODE
fi

echo "=== Render complete: $OUTPUT_PATH ==="
ls -lh "$OUTPUT_PATH"
