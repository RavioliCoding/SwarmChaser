#!/usr/bin/env python3
"""Download the public swarm datasets and build the Archives view (optional).

    python3 scripts/fetch_datasets.py

These datasets are published by third parties under their own terms; this script
downloads them from source into data/sample/archives/<id>/raw/ and does not
redistribute them. It then runs app/build_archives.py to produce the files the
Archives tab reads. Downloaded data is untrusted: it is only ever parsed as data.

Optional extra: METR's hourly timeline for the Hugging Face archive is not a download
of its own. If you save it as hf-intrusion/raw/metr_agent_timeline.json and
metr_workstream_traffic.json, the builder adds those charts; without them it skips them.
"""
import pathlib
import subprocess
import sys
import urllib.request

sys.stdout.reconfigure(line_buffering=True)  # keep our lines in order with the builder's output
ROOT = pathlib.Path(__file__).resolve().parent.parent
RAW = ROOT / "data" / "sample" / "archives"
DSE = "https://collusion.wiki/explorer/download/"
SOURCES = {
    **{f"dsewiki/raw/{f}": DSE + f for f in ("revisions.jsonl.gz", "events.jsonl.gz", "pages.jsonl.gz", "labels.jsonl.gz", "manifest.json.gz")},
    "hf-intrusion/raw/redacted.jsonl.gz": "https://swarmtraces.org/data/final/redacted.jsonl.gz",
    "urlquery-transluce/raw/urlquery-agent-activity-2026-09-23.zip": "https://transluce.org/data/urlquery-agent-activity-2026-09-23.zip",
}
MAX_BYTES = 60_000_000  # largest file today is ~15 MB; refuse anything far bigger
UA = "SwarmChaser/1.0 (dataset fetch)"


def fetch(url, dest):
    if not url.startswith("https://"):
        raise ValueError("https only")
    part = dest.with_name(dest.name + ".part")
    req = urllib.request.Request(url, headers={"User-Agent": UA})
    with urllib.request.urlopen(req, timeout=60) as r, open(part, "wb") as f:
        if not r.geturl().startswith("https://"):
            raise ValueError(f"redirected off https to {r.geturl()}")
        got = 0
        while chunk := r.read(1 << 16):
            got += len(chunk)
            if got > MAX_BYTES:
                raise ValueError(f"larger than {MAX_BYTES // 1_000_000} MB; not saved")
            f.write(chunk)
    part.chmod(0o644)
    part.replace(dest)  # only a complete download gets the real name
    return got


print("Fetching public datasets (see each source's terms before redistributing).")
for rel, url in SOURCES.items():
    dest = RAW / rel
    dest.parent.mkdir(parents=True, exist_ok=True)
    if dest.exists():
        print("  have", rel)
        continue
    print("  get ", url)
    try:
        print(f"       {fetch(url, dest) / 1e6:.1f} MB")
    except Exception as e:
        dest.with_name(dest.name + ".part").unlink(missing_ok=True)
        print(f"    could not fetch ({e}); that archive will be skipped.")

print("Building archive views...")
subprocess.run([sys.executable, "-I", str(ROOT / "app" / "build_archives.py")], check=False)
print("Done. Rebuild the app (./app/build.sh) or run scripts/serve.py to see the Archives tab.")
