#!/usr/bin/env python3
"""
Runs INSIDE the dedicated venv (~/.gimp-plugin-shared-venv/venv).
Called by the GIMP plugin as a subprocess so GIMP's own python
never needs onnxruntime/rembg installed into it.

Usage: bg_remove_worker.py <input_png> <output_png> [accuracy]
  accuracy: fast | medium | high  (default: medium)
"""
import sys
import onnxruntime as ort
from rembg import remove, new_session

ACCURACY_PROFILES = {
    "fast": {
        "alpha_matting": False,
        "post_process_mask": False,
    },
    "medium": {
        "alpha_matting": True,
        "alpha_matting_foreground_threshold": 240,
        "alpha_matting_background_threshold": 10,
        "alpha_matting_erode_size": 10,
        "post_process_mask": False,
    },
    "high": {
        "alpha_matting": True,
        "alpha_matting_foreground_threshold": 240,
        "alpha_matting_background_threshold": 5,
        "alpha_matting_erode_size": 15,
        "post_process_mask": True,
    },
}


def main():
    if len(sys.argv) < 3:
        print("Usage: bg_remove_worker.py <in.png> <out.png> [accuracy]",
              file=sys.stderr)
        sys.exit(1)

    in_path = sys.argv[1]
    out_path = sys.argv[2]
    accuracy = sys.argv[3] if len(sys.argv) > 3 else "medium"
    params = ACCURACY_PROFILES.get(accuracy, ACCURACY_PROFILES["medium"])

    available = ort.get_available_providers()
    if "CUDAExecutionProvider" in available:
        providers = ["CUDAExecutionProvider", "CPUExecutionProvider"]
        print(f"Using GPU (CUDA) — accuracy: {accuracy}", file=sys.stderr)
    else:
        providers = ["CPUExecutionProvider"]
        print("WARNING: CUDAExecutionProvider not available, falling back to CPU.",
              file=sys.stderr)

    session = new_session("isnet-general-use", providers=providers)

    with open(in_path, "rb") as f:
        input_bytes = f.read()

    output_bytes = remove(input_bytes, session=session, **params)

    with open(out_path, "wb") as f:
        f.write(output_bytes)


if __name__ == "__main__":
    main()
