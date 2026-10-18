#!/usr/bin/env python3
"""Refresh the data snapshot embedded in dashboard/index.html.

The dashboard always prefers the live files; this copy is only used when they
can't be read (e.g. the page opened as file://). build.sh runs this each build.
"""
import json
import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parent.parent
PAGE = ROOT / "dashboard" / "index.html"
DATA = ROOT / "data" / "sample"  # bundled sample data


def dump(obj):
    return json.dumps(obj, ensure_ascii=False, separators=(",", ":")).replace("</", "<\\/")


def load_runs():
    runs = []
    try:
        lines = (DATA / "leads" / "watch_log.jsonl").read_text().splitlines()
    except OSError:
        return runs
    for line in lines:
        line = line.strip()
        if not line:
            continue
        try:
            runs.append(json.loads(line))
        except ValueError:
            pass  # skip a bad line rather than failing the build
    return sorted(runs, key=lambda r: r.get("run_utc", ""), reverse=True)


def load_json(rel):
    try:
        return json.loads((DATA / rel).read_text())
    except (OSError, ValueError):
        return {}


BLOCKS = {
    "MOCK": load_runs,
    "INTERP": lambda: load_json("leads/interpretation.json"),
    "THREADS": lambda: load_json("leads/threads.json"),
    "VECTORS": lambda: load_json("reference/detection_vectors.json"),
}

page = PAGE.read_text()
for name, get in BLOCKS.items():
    pattern = re.compile(r"/\*@" + name + r"\*/.*?/\*@END\*/", re.S)
    if not pattern.search(page):
        sys.exit(f"embed_snapshot: marker /*@{name}*/ missing in {PAGE}")
    payload = dump(get())
    page = pattern.sub(lambda _m: f"/*@{name}*/{payload}/*@END*/", page, count=1)
PAGE.write_text(page)
print("embedded snapshot refreshed")
