#!/usr/bin/env bash
# Wrapper that sets up native library paths before launching the Python
# worker. ONNX Runtime ships GPU provider DLLs/SOs in its package tree
# (not on the system path), so we add them here.
#
# The GIMP plugin calls this instead of calling the venv python directly.
set -e

# Cross-platform script dir (macOS readlink fallback)
if readlink -f "$0" &>/dev/null; then
    SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
else
    SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
fi

# MSYS2 sets HOME=/home/<user>, but our venv lives in Windows %USERPROFILE%
# Override HOME so the venv path resolves to the real user directory.
if [ -n "$USERPROFILE" ]; then
    export HOME="$(cd "$USERPROFILE" 2>/dev/null && pwd)"
fi

VENV="$HOME/.gimp-plugin-shared-venv/venv"
WORKER="$SCRIPT_DIR/bg_remove_worker.py"

case "$(uname -s)" in
    Linux)
        VENV_PYTHON="$VENV/bin/python3"
        NVIDIA_LIBS="$(find "$VENV" -path '*/nvidia/*/lib' -type d 2>/dev/null | tr '\n' ':')"
        export LD_LIBRARY_PATH="${NVIDIA_LIBS}${LD_LIBRARY_PATH}"
        ;;
    CYGWIN*|MINGW*|MSYS*)
        VENV_PYTHON="$VENV/Scripts/python.exe"
        # DirectML DLLs
        DML_PATH="$VENV/Lib/site-packages/onnxruntime/capi"
        [ -d "$DML_PATH" ] && export PATH="$DML_PATH:$PATH"
        ;;
    Darwin*)
        VENV_PYTHON="$VENV/bin/python3"
        # CoreML may need .dylib path on macOS
        COREML_PATH="$VENV/lib/python3*/site-packages/onnxruntime/capi"
        COREML_DIR="$(echo $COREML_PATH 2>/dev/null | head -1)"
        [ -d "$COREML_DIR" ] && export DYLD_LIBRARY_PATH="$COREML_DIR:${DYLD_LIBRARY_PATH}"
        ;;
esac

exec "$VENV_PYTHON" "$WORKER" "$@"
