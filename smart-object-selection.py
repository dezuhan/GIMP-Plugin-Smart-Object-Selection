#!/usr/bin/env python3
"""
GIMP 3.2 plugin: Smart Object Selection
Draw a rough rectangle/lasso around an object, run this plugin, and it
replaces the rough selection with a precise AI object mask.
Always uses high-accuracy mode for best results.
"""
import gi
gi.require_version('Gimp', '3.0')
gi.require_version('GimpUi', '3.0')
from gi.repository import Gimp, GimpUi, GLib, Gio, GObject

import os
import shutil
import subprocess
import sys
import tempfile
import traceback
import time

PLUGIN_DIR = os.path.dirname(os.path.abspath(__file__))
IS_FLATPAK = os.path.exists("/.flatpak-info")
IS_WINDOWS = sys.platform == "win32"

_BASH_EXE = None


def _find_bash():
    """Locate bash.exe on Windows (Git Bash / MSYS2)."""
    global _BASH_EXE
    if _BASH_EXE is not None:
        return _BASH_EXE
    bash = shutil.which("bash")
    if bash:
        _BASH_EXE = bash
        return _BASH_EXE
    for candidate in [
        r"C:\Program Files\Git\bin\bash.exe",
        r"C:\Program Files (x86)\Git\bin\bash.exe",
        r"C:\Git\bin\bash.exe",
        r"C:\msys64\usr\bin\bash.exe",
    ]:
        if os.path.exists(candidate):
            _BASH_EXE = candidate
            return _BASH_EXE
    _BASH_EXE = "bash"
    return _BASH_EXE


def _build_command(script, args):
    if IS_FLATPAK:
        return ["flatpak-spawn", "--host", script] + args
    if IS_WINDOWS:
        return [_find_bash(), script] + args
    return [script] + args


def _run_worker_with_progress(title, args):
    script = os.path.join(PLUGIN_DIR, "run_worker.sh")
    Gimp.progress_init(title)
    proc = subprocess.Popen(
        _build_command(script, args),
        stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True
    )
    while proc.poll() is None:
        Gimp.progress_pulse()
        time.sleep(0.12)
    stdout, stderr = proc.communicate()
    Gimp.progress_end()
    return proc.returncode, stdout, stderr


def _(s):
    return s


class SmartObjectSelect(Gimp.PlugIn):

    def do_query_procedures(self):
        return ["plug-in-smart-object-select"]

    def do_create_procedure(self, name):
        procedure = Gimp.ImageProcedure.new(
            self, name, Gimp.PDBProcType.PLUGIN, self.run, None
        )
        procedure.set_image_types("*")
        procedure.set_sensitivity_mask(Gimp.ProcedureSensitivityMask.DRAWABLE)
        procedure.set_menu_label(_("Smart Object Selection"))
        procedure.add_menu_path("<Image>/Select")
        procedure.set_documentation(
            _("Refine a rough selection into an AI-precise object mask"),
            _("Crops to the selection bounds, runs rembg with "
              "high-accuracy alpha matting to isolate the object, "
              "and converts the alpha into a pixel-precise selection."),
            name,
        )
        procedure.set_attribution("Dzuhan", "Dzuhan", "2026")
        return procedure

    def run(self, procedure, run_mode, image, drawables, config, data):
        try:
            return self._run(procedure, image, drawables)
        except Exception:
            Gimp.message("Smart Object Selection error:\n" + traceback.format_exc())
            return procedure.new_return_values(
                Gimp.PDBStatusType.EXECUTION_ERROR, GLib.Error()
            )

    def _run(self, procedure, image, drawables):
        if not os.path.exists(os.path.join(PLUGIN_DIR, "run_worker.sh")):
            Gimp.message("Worker script not found. Reinstall the plugin files.")
            return procedure.new_return_values(
                Gimp.PDBStatusType.CALLING_ERROR, GLib.Error())

        if not drawables:
            Gimp.message("No active layer selected.")
            return procedure.new_return_values(
                Gimp.PDBStatusType.CALLING_ERROR, GLib.Error())

        drawable = drawables[0]
        ok, non_empty, x1, y1, x2, y2 = Gimp.Selection.bounds(image)

        if x2 - x1 < 4 or y2 - y1 < 4:
            Gimp.message("Selection too small. Draw a rough selection around the object first.")
            return procedure.new_return_values(
                Gimp.PDBStatusType.CALLING_ERROR, GLib.Error())

        Gimp.context_push()
        image.undo_group_start()

        try:
            tmp_dir = tempfile.mkdtemp(prefix="gimp-smart-sel-")
            crop_path = os.path.join(tmp_dir, "crop.png")
            out_path = os.path.join(tmp_dir, "output.png")

            # Export only the active layer's selection region (not whole project)
            crop_img = Gimp.Image.new(x2 - x1, y2 - y1, Gimp.ImageBaseType.RGB)
            crop_layer = Gimp.Layer.new_from_drawable(drawable, crop_img)
            crop_layer.set_offsets(-x1, -y1)
            crop_img.insert_layer(crop_layer, None, 0)
            in_file = Gio.File.new_for_path(crop_path)
            Gimp.file_save(Gimp.RunMode.NONINTERACTIVE, crop_img, in_file, None)
            crop_img.delete()

            rc, stdout, stderr = _run_worker_with_progress(
                "Detecting object with AI (high accuracy)...",
                [crop_path, out_path, "high"]
            )
            if rc != 0 or not os.path.exists(out_path):
                Gimp.message("Smart selection failed:\n" + (stderr or "unknown error"))
                return procedure.new_return_values(
                    Gimp.PDBStatusType.EXECUTION_ERROR, GLib.Error())

            out_file = Gio.File.new_for_path(out_path)
            loaded_img = Gimp.file_load(Gimp.RunMode.NONINTERACTIVE, out_file)
            loaded_layer = loaded_img.get_layers()[0]

            new_layer = Gimp.Layer.new_from_drawable(loaded_layer, image)
            new_layer.set_name("Smart Select Result")
            new_layer.set_offsets(x1, y1)
            image.insert_layer(new_layer, None, -1)
            loaded_img.delete()

            image.select_item(Gimp.ChannelOps.REPLACE, new_layer)
            image.remove_layer(new_layer)

            Gimp.displays_flush()

        finally:
            image.undo_group_end()
            Gimp.context_pop()

        return procedure.new_return_values(Gimp.PDBStatusType.SUCCESS, GLib.Error())


Gimp.main(SmartObjectSelect.__gtype__, __import__("sys").argv)
