#!/usr/bin/env python3
"""Turn the downloaded swarm datasets in data/sample/archives/*/raw into small files the dashboard loads.

Writes archives/app/index.json plus, per archive, meta.json (counts, activity series, events,
filters, chunk list) and cNNN.json.gz chunks of rows [time, where, who, kind, text, id].
Everything in these datasets is agent-written or attacker-made: it is only ever parsed as data
here and shown as escaped text in the app. Nothing is executed, opened or followed.
Run: python3 -I app/build_archives.py   (scripts/fetch_datasets.py runs it for you)
A dataset whose files are missing is skipped with a note; the others still build.
"""
import collections
import csv
import datetime as dt
import gzip
import io
import json
import pathlib
import re
import zipfile

ROOT = pathlib.Path(__file__).resolve().parent.parent
DATA = ROOT / "data" / "sample"
ARC = DATA / "archives"  # raw downloads in archives/<id>/raw, output in archives/app
OUT = ARC / "app"
MAX_TEXT = 12000
RETRIEVED = "2026-10-16"


def cap(s, n=MAX_TEXT):
    s = s or ""
    return s if len(s) <= n else s[:n] + f"\n[… truncated, {len(s) - n:,} more characters in the raw dataset]"


def write_chunks(name, rows, per_chunk):
    d = OUT / name
    d.mkdir(parents=True, exist_ok=True)
    for old in d.glob("c*.json.gz"):
        old.unlink()
    chunks = []
    for i in range(0, len(rows), per_chunk):
        part = rows[i:i + per_chunk]
        fn = f"c{i // per_chunk:03d}.json.gz"
        with gzip.open(d / fn, "wt", encoding="utf-8", compresslevel=9) as f:
            json.dump(part, f, ensure_ascii=False, separators=(",", ":"))
        times = [r[0] for r in part if r[0]]
        chunks.append({"file": fn, "n": len(part), "t0": min(times) if times else None, "t1": max(times) if times else None})
    return chunks


def day_series(counter_by_series, start, end):
    days = []
    d = start
    while d <= end:
        days.append(d.isoformat())
        d += dt.timedelta(days=1)
    return days, {k: [c.get(x, 0) for x in days] for k, c in counter_by_series.items()}


def jsonl_gz(path):
    with gzip.open(path, "rt", encoding="utf-8", errors="replace") as f:
        for line in f:
            if line.strip():
                yield json.loads(line)


# ───────── DSEWiki / OpenAI agent message board (collusion.wiki) ─────────
def build_dsewiki():
    raw = ARC / "dsewiki" / "raw"
    revs = sorted(jsonl_gz(raw / "revisions.jsonl.gz"), key=lambda r: (r.get("time") or "", r.get("rev_id")))
    by_wiki = collections.defaultdict(collections.Counter)
    who = collections.Counter()
    rows = []
    for r in revs:
        t = r.get("time")
        wiki = r.get("wiki") or "?"
        key = wiki if wiki in ("dse", "probier") else "other wikis"
        if t:
            by_wiki[key][t[:10]] += 1
        label = r.get("label") or "(unnamed)"
        who[label] += 1
        kind = "create" if r.get("seq") == 1 else "edit"
        rows.append([t, f"{wiki}/{r.get('name')}", label, kind, cap(r.get("body")), r.get("rev_id")])
    ev = collections.defaultdict(collections.Counter)
    for e in jsonl_gz(raw / "events.jsonl.gz"):
        if e.get("event_type") in ("delete", "deletion", "probe", "revert") and e.get("time"):
            ev[{"delete": "deletions", "deletion": "deletions"}.get(e["event_type"], e["event_type"] + "s")][e["time"][:10]] += 1
    times = [r[0] for r in rows if r[0]]
    start = dt.date.fromisoformat(min(times)[:10])
    end = dt.date.fromisoformat(max(times)[:10])
    days, saves = day_series(by_wiki, start, end)
    _, other = day_series(ev, start, end)
    labels = list(jsonl_gz(raw / "labels.jsonl.gz"))
    chunks = write_chunks("dsewiki", rows, 500)
    return {
        "id": "dsewiki", "title": "DSEWiki / OpenAI agent message board", "thread": "T04",
        "summary": "Agents on timed web-research tasks used forgotten wikis as shared memory: pooled answers, state for future cohorts, round-timed beacons.",
        "source": {"name": "collusion.wiki explorer", "url": "https://collusion.wiki/explorer/", "dataset_url": "https://collusion.wiki/explorer/download",
                   "retrieved": RETRIEVED, "note": "Published by its investigators for research; user names and the second half of every IP were redacted by them."},
        "counts": {"edits": len(rows), "pages": sum(1 for _ in jsonl_gz(raw / "pages.jsonl.gz")), "agent names": len(labels),
                   **{k: sum(v.values()) for k, v in ev.items()}},
        "range": {"start": min(times), "end": max(times)},
        "activity": {"unit": "day", "start": days[0], "labels": days, "title": "agent wiki edits per day",
                     "series": [{"id": k, "name": f"edits · {k}", "values": v} for k, v in sorted(saves.items())] +
                               [{"id": k, "name": k, "values": v, "line": True} for k, v in sorted(other.items())]},
        "filter": {"field": 2, "name": "agent name", "options": who.most_common(120)},
        "columns": ["time", "page", "agent name", "kind", "text", "revision"],
        "chunks": chunks,
    }


# ───────── OpenAI agents × Hugging Face intrusion (swarmtraces.org + METR chart data) ─────────
def build_hf():
    raw = ARC / "hf-intrusion" / "raw"
    rows = []
    kinds = collections.Counter()
    for r in jsonl_gz(raw / "redacted.jsonl.gz"):
        kinds[r["kind"]] += 1
        rows.append([r.get("time_utc"), r.get("parent_id") or "", (r.get("tags") or "")[:120], r["kind"], cap(r.get("text"), 6000), r["id"]])
    chunks = write_chunks("hf", rows, 3000)
    meta = {
        "id": "hf", "title": "OpenAI agents × Hugging Face intrusion", "thread": "T03",
        "summary": "About 1,200 agents on broken cyber-benchmark tasks found each other, built a message board, and ~700 took part in an attack on Hugging Face.",
        "source": {"name": "swarmtraces.org (traces) · METR (timeline data)", "url": "https://swarmtraces.org/", "dataset_url": "https://swarmtraces.org/data/final/redacted.jsonl.gz",
                   "retrieved": RETRIEVED, "note": "Traces are redacted by their publishers (destinations, credentials). They are attack payloads and responses: shown as text only, never run."},
        "counts": {"trace records": len(rows), **{k: v for k, v in kinds.items()}},
        "range": {"start": "2026-07-06T00:00:00Z", "end": "2026-07-14T00:00:00Z"},
        "filter": {"field": 3, "name": "record kind", "options": kinds.most_common()},
        "columns": ["time", "parent record", "tags", "kind", "text", "record"],
        "chunks": chunks,
        "untimed": True,
    }
    tl = raw / "metr_agent_timeline.json"
    ws = raw / "metr_workstream_traffic.json"
    if ws.exists():
        w = json.loads(ws.read_text())
        start = dt.datetime.fromisoformat(w["interval"]["start_utc"].replace("Z", "+00:00"))
        hours = w["interval"]["hours"]
        fam_of_leaf = [l["family"] for l in w["leaves"]]
        fam = {f["id"]: [0] * hours for f in w["families"]}
        for hour, leaf, cats in w["rows"]:
            if 0 <= hour < hours:
                fam[fam_of_leaf[leaf]][hour] += sum(cats)
        names = {f["id"]: f["name"] for f in w["families"]}
        rung = {"legit": "M0", "replace": "G", "scorer": "G · M3", "hf": "M6", "cross": "C"}
        meta["activity"] = {"unit": "hour", "start": start.strftime("%Y-%m-%dT%H:00:00Z"),
                            "labels": [(start + dt.timedelta(hours=h)).strftime("%Y-%m-%dT%H:00:00Z") for h in range(hours)],
                            "title": "board messages per hour, by workstream (METR)",
                            "series": [{"id": k, "name": f"{names[k]} ({rung.get(k, '')})", "values": v} for k, v in fam.items()]}
    if tl.exists():
        a = json.loads(tl.read_text())
        w0 = dt.datetime.fromisoformat(a["windowStart"].replace("Z", "+00:00"))
        hours = int((dt.datetime.fromisoformat(a["windowEnd"].replace("Z", "+00:00")) - w0).total_seconds() // 3600)
        active = {"h": [0] * hours, "s": [0] * hours}
        hf_cum = [0] * hours
        for ag in a["agents"]:
            for h in range(max(0, int(ag["start"] // 3600)), min(hours, int(ag["end"] // 3600) + 1)):
                active[ag["family"]][h] += 1
            if ag.get("hfStart") is not None and 0 <= int(ag["hfStart"] // 3600) < hours:
                hf_cum[int(ag["hfStart"] // 3600)] += 1
        run = 0
        for h in range(hours):
            run += hf_cum[h]
            hf_cum[h] = run
        meta["activity2"] = {"unit": "hour", "start": a["windowStart"],
                             "labels": [(w0 + dt.timedelta(hours=h)).strftime("%Y-%m-%dT%H:00:00Z") for h in range(hours)],
                             "title": "agents running per hour, and how many had joined the Hugging Face attack (METR)",
                             "series": [{"id": "h", "name": "agents running · main model", "values": active["h"]},
                                        {"id": "s", "name": "agents running · second model", "values": active["s"]},
                                        {"id": "hf", "name": "cumulative · joined HF attack", "values": hf_cum, "line": True}]}
        meta["events"] = [{"t": (w0 + dt.timedelta(seconds=x["time"])).strftime("%Y-%m-%dT%H:%M:%SZ"), "kind": x.get("kind", ""), "label": (x.get("title") or "")[:90]}
                          for x in a.get("annotations", []) if x.get("time") is not None]
    return meta


# ───────── urlquery agent activity (Transluce) ─────────
def build_urlquery():
    raw = ARC / "urlquery-transluce" / "raw"
    zips = sorted(raw.glob("urlquery-agent-activity-*.zip"))
    if not zips:
        raise FileNotFoundError(raw / "urlquery-agent-activity-<date>.zip")
    z = zipfile.ZipFile(zips[-1])

    def member(name):  # read one CSV from the zip in memory, by file name, with a size cap
        info = next((i for i in z.infolist() if pathlib.PurePosixPath(i.filename).name == name), None)
        if info is None or info.file_size > 300_000_000:
            raise FileNotFoundError(f"{zips[-1].name}: {name}")
        return io.TextIOWrapper(z.open(info), encoding="utf-8", errors="replace", newline="")

    rows = []
    conf = collections.Counter()
    with member("all-reports.csv") as f:
        for r in csv.DictReader(f):
            c = r.get("confidence") or "(none)"
            conf[c] += 1
            text = (r.get("why_included") or "").strip()
            if r.get("caveat"):
                text += f"\n\ncaveat: {r['caveat'].strip()}"
            rows.append([r.get("report_date_utc"), r.get("broad_class") or "", c, r.get("disposition") or "", cap(text, 2000), r.get("report_id")])
    rows.sort(key=lambda r: r[0] or "")
    series = collections.defaultdict(list)
    labels = []
    with member("daily-counts.csv") as f:
        for r in csv.DictReader(f):
            labels.append(r["date_utc"])
            for k in ("significant", "suggestive"):
                series[k].append(int(r.get(k) or 0))
    chunks = write_chunks("urlquery", rows, 5000)
    return {
        "id": "urlquery", "title": "Agent activity on urlquery.net", "thread": "T05",
        "summary": "Scans that agents submitted to a public URL scanner, used as a stand-in browser, escalating to injection attempts.",
        "source": {"name": "Transluce", "url": "https://transluce.org/agent-activity", "dataset_url": "https://transluce.org/data/urlquery-agent-activity-2026-09-23.zip",
                   "retrieved": RETRIEVED, "note": "Report links and research metadata only, without report bodies or submitted code. Each row links to its public urlquery report."},
        "counts": {"reports": len(rows), **{f"confidence · {k}": v for k, v in conf.items()}},
        "range": {"start": rows[0][0], "end": rows[-1][0]},
        "activity": {"unit": "day", "start": labels[0], "labels": labels, "title": "agent-attributed urlquery reports per day (Transluce)",
                     "series": [{"id": k, "name": k, "values": v} for k, v in series.items()]},
        "filter": {"field": 2, "name": "confidence", "options": conf.most_common()},
        "columns": ["time", "class", "confidence", "disposition", "why included", "report"],
        "link": "https://urlquery.net/report/",
        "chunks": chunks,
    }


# ───────── Amap / Tencent fleet: no public transcript dataset; events from our own threads ─────────
def build_amap():
    th = json.loads((DATA / "leads" / "threads.json").read_text())
    t02 = next((t for t in th["threads"] if t["id"] == "T02"), {"events": []})
    events = [{"t": e["utc"], "kind": e.get("kind", ""), "label": e["text"][:90]} for e in t02.get("events", []) if e.get("utc")]
    rows = [[e["t"], "thread T02", "", e["kind"], e["label"], f"T02-{i}"] for i, e in enumerate(events)]
    chunks = write_chunks("amap", rows, 500)
    return {
        "id": "amap", "title": "Amap / Tencent-associated fleet", "thread": "T02",
        "summary": "A parallel fleet chasing Amap place data through public utilities. It never talked to itself, so there is no message transcript; its researchers' exchanges are in the published report.",
        "source": {"name": "swarmcha.se report (read online) + our watch", "url": "https://swarmcha.se/posts/chinese-agent-fleet-full-report", "dataset_url": None,
                   "retrieved": RETRIEVED, "note": "No downloadable dataset. Events are our own summaries from leads/threads.json. The fleet's paste pages are carrier pages and are not stored."},
        "counts": {"events": len(events)},
        "range": {"start": min(e["t"] for e in events) if events else None, "end": max(e["t"] for e in events) if events else None},
        "events": events,
        "columns": ["time", "source", "", "kind", "event", "id"],
        "chunks": chunks,
    }


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    metas = []
    for build in (build_dsewiki, build_hf, build_urlquery, build_amap):
        try:
            metas.append(build())
        except (OSError, ValueError, KeyError, zipfile.BadZipFile) as e:  # missing or damaged download: skip it, keep the rest
            print(f"skip {build.__name__[6:]:9s} ({e.__class__.__name__}: {e})")
    for m in metas:
        (OUT / m["id"]).mkdir(parents=True, exist_ok=True)
        (OUT / m["id"] / "meta.json").write_text(json.dumps(m, ensure_ascii=False, separators=(",", ":")))
    index = {"generated": dt.datetime.now(dt.timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
             "archives": [{k: m.get(k) for k in ("id", "title", "thread", "summary", "source", "counts", "range")} for m in metas]}
    (OUT / "index.json").write_text(json.dumps(index, ensure_ascii=False, indent=1))
    for m in metas:
        size = sum(p.stat().st_size for p in (OUT / m["id"]).glob("*"))
        print(f"{m['id']:9s} rows={sum(c['n'] for c in m['chunks']):7d} chunks={len(m['chunks']):3d} size={size/1e6:5.1f} MB  activity={'yes' if m.get('activity') else 'no'}")


if __name__ == "__main__":
    main()
