#!/usr/bin/env python3
"""Merge timeline shortcuts into Shotcut's Flatpak settings."""

import re
from pathlib import Path


def configure():
    path = Path.home() / ".var/app/org.shotcut.Shotcut/config/Meltytech/Shotcut.conf"
    original = path.read_text() if path.exists() else ""
    # Shotcut separates its two shortcuts with ||. Quote the comma for Qt's INI parser.
    shortcuts = {
        "timelineSplitAction": '",||S"',
        "timelineDeleteAction": ".||X",
        "timelineNudgeBackwardAction": "||",
        "timelineNudgeForwardAction": "||",
    }
    section = re.search(r"(?ms)^\[shortcuts\]\n.*?(?=^\[|\Z)", original)
    content = section.group() if section else "[shortcuts]\n"
    if not content.endswith("\n"):
        content += "\n"
    for key, value in shortcuts.items():
        pattern = rf"(?m)^{re.escape(key)}=.*$"
        line = f"{key}={value}"
        if re.search(pattern, content):
            content = re.sub(pattern, lambda _: line, content)
        else:
            content += line + "\n"
    if section:
        updated = original[:section.start()] + content + original[section.end():]
    else:
        updated = original + ("\n" if original else "") + content
    if updated != original:
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(updated)
    print("[configure-shotcut] Comma: Split; period: Ripple Delete (S/X also work).")
    print("[configure-shotcut] Save your project and restart Shotcut to load the shortcuts.")


if __name__ == "__main__":
    configure()
