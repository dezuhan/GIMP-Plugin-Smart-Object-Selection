#!/usr/bin/env bash
# Wrapper so onnxruntime can find the pip-installed nvidia CUDA/cuDNN
# runtime libraries, which don't sit on the normal system LD_LIBRARY_PATH.
# The GIMP plugin calls this instead of calling venv/bin/python3 directly.
set -e

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
VENV="$HOME/.gimp-plugin-shared-venv/venv"
WORKER="$SCRIPT_DIR/bg_remove_worker.py"

NVIDIA_LIBS="$(find "$VENV" -path '*/nvidia/*/lib' -type d 2>/dev/null | tr '\n' ':')"
export LD_LIBRARY_PATH="${NVIDIA_LIBS}${LD_LIBRARY_PATH}"

exec "$VENV/bin/python3" "$WORKER" "$@"
