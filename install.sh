#!/usr/bin/env bash
# Smart Object Selection — Quick Install
# Requires the shared engine from Remove Background plugin.
# Run install.sh from remove-background first.
# Works on Linux, macOS, Windows (Git Bash).
set -e

case "$(uname -s)" in
    Linux*)
        GIMP_PLUGINS="$HOME/.config/GIMP/3.2/plug-ins"
        VENV_PYTHON_REL="bin/python3"
        ;;
    Darwin*)
        GIMP_PLUGINS="$HOME/Library/Application Support/GIMP/3.2/plug-ins"
        VENV_PYTHON_REL="bin/python3"
        ;;
    CYGWIN*|MINGW*|MSYS*)
        GIMP_PLUGINS="$APPDATA/GIMP/3.2/plug-ins"
        GIMP_PLUGINS="$(echo "$GIMP_PLUGINS" | sed 's|\\|/|g' | sed 's|C:|/c|')"
        VENV_PYTHON_REL="Scripts/python.exe"
        ;;
esac

if readlink -f "$0" &>/dev/null; then
    PLUGIN_DIR="$(dirname "$(readlink -f "$0")")"
else
    PLUGIN_DIR="$(cd "$(dirname "$0")" && pwd)"
fi
PLUGINS_PATH="$GIMP_PLUGINS/smart-object-selection"
SHARED_VENV="$HOME/.gimp-plugin-shared-venv/venv/$VENV_PYTHON_REL"

echo "============================================"
echo " Smart Object Selection — Install"
echo "============================================"

if [ ! -f "$SHARED_VENV" ]; then
    echo ""
    echo "[!] Shared engine not found at ~/.gimp-plugin-shared-venv/venv"

    # Try to find remove-background install.sh in sibling directories
    REMBG_INSTALL=""
    for candidate in \
        "$PLUGIN_DIR/../remove-background/install.sh" \
        "$PLUGIN_DIR/../GIMP-Plugin-Remove-Background/install.sh" \
        "$PLUGIN_DIR/../../remove-background/install.sh" \
        "$PLUGIN_DIR/../../GIMP-Plugin-Remove-Background/install.sh"; do
        if [ -f "$candidate" ]; then
            REMBG_INSTALL="$candidate"
            break
        fi
    done

    if [ -n "$REMBG_INSTALL" ]; then
        echo "[→] Found remove-background installer. Running it first..."
        bash "$REMBG_INSTALL"
    else
        echo "    Run install.sh from https://github.com/dezuhan/GIMP-Plugin-Remove-Background first."
        echo "    Or clone it alongside this repo and re-run."
        exit 1
    fi
fi

echo "[✓] Shared engine found"

mkdir -p "$PLUGINS_PATH"
cp "$PLUGIN_DIR/smart-object-selection.py" "$PLUGINS_PATH/"
cp "$PLUGIN_DIR/run_worker.sh" "$PLUGINS_PATH/"
cp "$PLUGIN_DIR/bg_remove_worker.py" "$PLUGINS_PATH/"
chmod +x "$PLUGINS_PATH/smart-object-selection.py" 2>/dev/null || true
chmod +x "$PLUGINS_PATH/run_worker.sh" 2>/dev/null || true

echo "[✓] Installed to $PLUGINS_PATH"
echo ""
echo "Restart GIMP → Select → Smart Object Selection"
