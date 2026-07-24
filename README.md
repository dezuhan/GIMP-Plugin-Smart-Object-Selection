# Smart Object Selection for GIMP 3.2

Draw a rough rectangle or lasso around any object — the AI refines it into a pixel-precise selection. Like Photoshop's Object Selection Tool, powered by [rembg](https://github.com/danielgatis/rembg). Cross-platform: Linux, Windows, macOS.

Requires the **Remove Background** plugin to be installed first (shared AI engine).

## Install

```bash
chmod +x install.sh && ./install.sh
```

This copies the plugin files to GIMP's plug-ins folder. The shared engine must already exist at `~/.gimp-bg-remover/venv`.

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

## License

GNU General Public License v3.0. See [LICENSE](LICENSE).

## Support

If this plugin helps your workflow, consider donating to support further development.

[Support on Ko-fi](https://ko-fi.com/dezuhan)
