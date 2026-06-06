#!/usr/bin/env python3
"""Static lint for DoriDesignSystem color assets.

Rules:
  - Brand/*.colorset    : must define a dark appearance
  - Brand/*.colorset    : dark RGB == light RGB (brand color preservation)
  - Semantic/*.colorset : must define a dark appearance

Exit 0 on pass, 1 on any violation. Reports every violation before exiting.
"""

from __future__ import annotations

import json
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent
ASSETS_ROOT = (
    REPO_ROOT
    / "Projects"
    / "Core"
    / "DoriDesignSystem"
    / "Resources"
    / "Colors.xcassets"
)
CATEGORIES = ("Brand", "Semantic")


def normalize_component(raw: str) -> int:
    """Convert a colorset component string to a 0-255 integer.

    Accepts both hex (`0xFF`) and float (`0.500`) forms.
    """
    raw = raw.strip()
    if raw.lower().startswith("0x"):
        return int(raw, 16)
    return round(float(raw) * 255)


def rgb_tuple(color: dict) -> tuple[int, int, int]:
    c = color["components"]
    return (
        normalize_component(c["red"]),
        normalize_component(c["green"]),
        normalize_component(c["blue"]),
    )


def is_dark(entry: dict) -> bool:
    for appearance in entry.get("appearances") or []:
        if appearance.get("appearance") == "luminosity" and appearance.get("value") == "dark":
            return True
    return False


def is_light(entry: dict) -> bool:
    # "light" is implicit when no appearances are declared.
    return not entry.get("appearances")


def fmt_rgb(rgb: tuple[int, int, int]) -> str:
    return "#{:02X}{:02X}{:02X}".format(*rgb)


def lint_colorset(path: Path, category: str) -> list[str]:
    rel = path.relative_to(REPO_ROOT)
    try:
        data = json.loads(path.read_text())
    except json.JSONDecodeError as exc:
        return [f"{rel}: failed to parse Contents.json ({exc})"]

    entries = data.get("colors") or []
    light = next((e for e in entries if is_light(e)), None)
    dark = next((e for e in entries if is_dark(e)), None)

    violations: list[str] = []

    if dark is None:
        violations.append(f"{rel} is missing dark appearance")
        return violations

    if category == "Brand":
        if light is None:
            violations.append(f"{rel} is missing light appearance")
            return violations
        light_color = light.get("color") or {}
        dark_color = dark.get("color") or {}
        if light_color.get("color-space") != dark_color.get("color-space"):
            violations.append(
                f"{rel} color-space mismatch "
                f"(light={light_color.get('color-space')}, dark={dark_color.get('color-space')})"
            )
            return violations
        light_rgb = rgb_tuple(light_color)
        dark_rgb = rgb_tuple(dark_color)
        if light_rgb != dark_rgb:
            violations.append(
                f"{rel} dark RGB differs from light "
                f"(light={fmt_rgb(light_rgb)}, dark={fmt_rgb(dark_rgb)})"
            )

    return violations


def main() -> int:
    if not ASSETS_ROOT.is_dir():
        print(f"assets root not found: {ASSETS_ROOT}", file=sys.stderr)
        return 1

    all_violations: list[str] = []
    for category in CATEGORIES:
        category_dir = ASSETS_ROOT / category
        if not category_dir.is_dir():
            continue
        for contents in sorted(category_dir.glob("**/*.colorset/Contents.json")):
            all_violations.extend(lint_colorset(contents, category))

    if all_violations:
        for v in all_violations:
            print(v, file=sys.stderr)
        print(f"\n{len(all_violations)} violation(s)", file=sys.stderr)
        return 1

    print("color assets lint: OK")
    return 0


if __name__ == "__main__":
    sys.exit(main())
