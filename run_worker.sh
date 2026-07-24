#!/usr/bin/env bash
# Wrapper so onnxruntime can find the pip-installed nvidia CUDA/cuDNN
# runtime libraries, which don't sit on the normal system LD_LIBRARY_PATH.
# The GIMP plugin calls this instead of calling venv/bin/python3 directly.
set -e

# Cross-platform script dir (macOS readlink fallback)
if readlink -f "$0" &>/dev/null; then
    SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
else
    SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
fi
VENV="$HOME/.gimp-plugin-shared-venv/venv"
WORKER="$SCRIPT_DIR/bg_remove_worker.py"

# Linux: add NVIDIA CUDA libs to LD_LIBRARY_PATH
if [ "$(uname -s)" = "Linux" ]; then
    NVIDIA_LIBS="$(find "$VENV" -path '*/nvidia/*/lib' -type d 2>/dev/null | tr '\n' ':')"
    export LD_LIBRARY_PATH="${NVIDIA_LIBS}${LD_LIBRARY_PATH}"
fi

exec "$VENV/bin/python3" "$WORKER" "$@"
