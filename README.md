# Smart Object Selection for GIMP 3.2

Draw a rough rectangle or lasso around any object — the AI refines it into a pixel-precise selection. Like Photoshop's Object Selection Tool, powered by [rembg](https://github.com/danielgatis/rembg). Cross-platform: Linux, Windows, macOS.

## Dependencies

This plugin shares the AI engine with [Remove Background](https://github.com/dezuhan/GIMP-Plugin-Remove-Background).
Install **remove-background first** — it sets up `~/.gimp-plugin-shared-venv/venv` with all required packages.

| Layer | Dependency | Required | Notes |
|-------|-----------|:--------:|-------|
| Plugin | Remove Background | Required | Shared venv at `~/.gimp-plugin-shared-venv` |
| pip | `rembg` | Required | Via shared venv |
| pip | `onnxruntime-*` | Required | Via shared venv (auto-detected per GPU) |
| pip | `pillow` | Required | Via shared venv |
| pip | `numpy` | Required | Via shared venv |
| Plugin files | `bg_remove_worker.py` | Required | Identical to remove-background's worker |
| Plugin files | `run_worker.sh` | Required | Identical wrapper script |

This plugin adds **no extra dependencies** beyond what Remove Background already installs.
It is a thin orchestration layer: crop to selection bounds → rembg → alpha-to-selection.

For full dependency and hardware/provider details, see the [Remove Background README](https://github.com/dezuhan/GIMP-Plugin-Remove-Background).

## Install

**Prerequisite:** [Remove Background](https://github.com/dezuhan/GIMP-Plugin-Remove-Background) must be installed first — it provides the shared AI engine at `~/.gimp-plugin-shared-venv`.

### Automatic (recommended)

**Linux / macOS:**
```bash
chmod +x install.sh && ./install.sh
```

**Windows:** Install [Git Bash](https://git-scm.com/downloads/win), right-click the plugin folder → **Git Bash Here**, then:
```bash
chmod +x install.sh && ./install.sh
```

If the shared engine is missing, `install.sh` will automatically find and run the Remove Background installer from a sibling directory.

---

### Manual Install

#### Linux / macOS

```bash
# 1. Ensure Remove Background is already installed
ls ~/.gimp-plugin-shared-venv/venv/bin/python3  # should exist

# 2. Copy plugin files
PLUGINS=~/.config/GIMP/3.2/plug-ins/smart-object-selection
mkdir -p "$PLUGINS"
cp smart-object-selection.py run_worker.sh bg_remove_worker.py "$PLUGINS/"
chmod +x "$PLUGINS/smart-object-selection.py"
chmod +x "$PLUGINS/run_worker.sh"

# 3. Restart GIMP → Select → Smart Object Selection
```

#### Windows

Run all commands in **Git Bash**:

```bash
# 1. Ensure Remove Background is already installed
ls ~/.gimp-plugin-shared-venv/venv/Scripts/python.exe  # should exist

# 2. Copy plugin files
PLUGINS="$APPDATA/GIMP/3.2/plug-ins/smart-object-selection"
PLUGINS="$(echo "$PLUGINS" | sed 's|\\\\|/|g' | sed 's|C:|/c|')"
mkdir -p "$PLUGINS"
cp smart-object-selection.py run_worker.sh bg_remove_worker.py "$PLUGINS/"

# 3. Restart GIMP → Select → Smart Object Selection
```

## Usage

1. Use **Rectangle Select (R)** or **Free Select (F)** to draw a rough boundary around an object
2. Go to **Select > Smart Object Selection**
3. The AI replaces your rough selection with a precise object mask

**Tip:** assign a keyboard shortcut:
- **Edit > Keyboard Shortcuts** → search "Smart Object Selection" → assign `Ctrl+Shift+O`

## How it works

```
Rough selection → Crop → rembg → Alpha → Selection
```

## Related Plugins

- [Remove Background](https://github.com/dezuhan/GIMP-Plugin-Remove-Background) — AI background removal (required)
- [AI Upscaler](https://github.com/dezuhan/GIMP-Plugin-AI-Upscaler) — Real-ESRGAN upscaling

## License

GNU General Public License v3.0. See [LICENSE](LICENSE).

## Support

If this plugin helps your workflow, consider donating to support further development.

[Support on Ko-fi](https://ko-fi.com/dezuhan)
