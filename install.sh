#!/usr/bin/env bash
# Smart Object Selection — Quick Install
# Works on Linux, macOS, Windows (Git Bash).
set -e

case "$(uname -s)" in
    Linux*)
        GIMP_PLUGINS="$HOME/.config/GIMP/3.2/plug-ins"
        ;;
    Darwin*)
        GIMP_PLUGINS="$HOME/Library/Application Support/GIMP/3.2/plug-ins"
        ;;
    CYGWIN*|MINGW*|MSYS*)
        GIMP_PLUGINS="$APPDATA/GIMP/3.2/plug-ins"
        GIMP_PLUGINS="$(echo "$GIMP_PLUGINS" | sed 's|\\|/|g' | sed 's|C:|/c|')"
        ;;
esac

PLUGIN_DIR="$(dirname "$(readlink -f "$0")")"
PLUGINS_PATH="$GIMP_PLUGINS/smart-object-selection"
SHARED_VENV="$HOME/.gimp-plugin-shared-venv/venv/bin/python3"

echo "============================================"
echo " Smart Object Selection — Install"
echo "============================================"

if [ ! -f "$SHARED_VENV" ]; then
    echo ""
    echo "[!] Shared engine not found at ~/.gimp-plugin-shared-venv/venv"
    echo "    Run install.sh from GIMP-Plugin-Remove-Background first."
    exit 1
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
