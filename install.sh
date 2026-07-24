#!/usr/bin/env bash
# Smart Object Selection — Quick Install
# Requires the shared engine (~/.gimp-plugin-shared-venv/venv) installed first.
# Run install.sh from remove-background if you haven't already.
set -e

PLUGIN_DIR="$(dirname "$(readlink -f "$0")")"
PLUGINS_PATH="$HOME/.config/GIMP/3.2/plug-ins/smart-object-selection"
SHARED_VENV="$HOME/.gimp-plugin-shared-venv/venv/bin/python3"

echo "============================================"
echo " Smart Object Selection — Install"
echo "============================================"

if [ ! -f "$SHARED_VENV" ]; then
    echo ""
    echo "[!] Shared engine not found at ~/.gimp-plugin-shared-venv/venv"
    echo "    Run install.sh from remove-background first."
    exit 1
fi
echo "[✓] Shared engine found"

mkdir -p "$PLUGINS_PATH"
cp "$PLUGIN_DIR/smart-object-selection.py" "$PLUGINS_PATH/"
cp "$PLUGIN_DIR/run_worker.sh" "$PLUGINS_PATH/"
cp "$PLUGIN_DIR/bg_remove_worker.py" "$PLUGINS_PATH/"
chmod +x "$PLUGINS_PATH/smart-object-selection.py"
chmod +x "$PLUGINS_PATH/run_worker.sh"

echo "[✓] Installed to $PLUGINS_PATH"
echo ""
echo "Restart GIMP → Select → Smart Object Selection"
