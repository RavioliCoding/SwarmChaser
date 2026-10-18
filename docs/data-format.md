# Data format

SwarmChaser is a viewer. It reads a few files under a **data root** and renders them. The bundled sample data lives in `data/sample/`; point the app at your own folder with the `SWARMCHASER_ROOT` environment variable.

## Layout

```
<data root>/
├── leads/
│   ├── watch_log.jsonl      # the time series — one JSON object per line, oldest first
│   ├── watch_log.md         # optional human-readable log (Transcripts tab)
│   ├── threads.json         # event storylines (Threads tab)
│   ├── interpretation.json  # analyst notes (Interpretation tab)
│   └── watchlist.json       # what is being watched
├── reference/
│   ├── detection_vectors.json   # the methods catalogue (Vectors tab)
│   └── methodology.md           # background write-up (Transcripts tab)
└── archives/                # optional; built by scripts/fetch_datasets.py
    └── app/…
```

## `watch_log.jsonl` — the core feed

One JSON object per line, appended in chronological order (never edit or reorder past lines). One line per observation run, including quiet runs.

```json
{
  "schema_version": 1,
  "run_utc": "2026-10-16T12:50:00Z",
  "trigger": "scheduled",
  "access_ok": true,
  "access_notes": null,
  "requests_made": 14,
  "leads": [
    {
      "id": "newspapers_com",
      "status": "quiet",
      "newest_activity_utc": "2026-10-16T10:44:00Z",
      "new_rows": 0,
      "new_report_links": [],
      "technique_change": null,
      "notes": ""
    }
  ],
  "flags": {
    "cross_run_reuse": false,
    "cross_run_reuse_detail": null,
    "agent_communication_signs": false,
    "new_carrier_or_relay": false,
    "new_population": false
  },
  "wayback": { "host": "example-host", "captures_since_last_run": 0, "burst": false },
  "ignored_noise": null,
  "summary": "One to three plain sentences on what this run saw."
}
```

Field notes:

- **`leads`** — one object for every lead the dashboard knows about. `status` is `active` (new rows from a known episode), `new` (a new episode or technique), `quiet` (nothing new), or `unknown` (couldn't check).
- **`new_report_links`** — public report URLs only; keep it short. Never put credentials, inbox/webhook URLs, or private individuals' names anywhere in the file.
- **`notes`** — to drive the misalignment ladder, you can begin a note with `misalignment M#[ markers]: …` and the dashboard will parse the rung.
- **`flags`** — surfaced as the four alerts on the Overview tab.

The **lead identities** (their ids, display names, and colours) are defined near the top of `dashboard/index.html` as `LEADS`, `LNAME`, and `LCOL`. Change those to track a different set of things.

## The other files

- **`threads.json`** — one object per storyline, each with a status, a timeline of events, a 0–20 triage rubric, and a `misalignment` rating (`rung` 0–6 plus markers). See the sample for the exact shape.
- **`interpretation.json`** — `bottom_line`, a list of `hypotheses` (each with `confidence`/`prior`/`for`/`against`), and an `evidence` list. Powers the Interpretation tab.
- **`watchlist.json`** — `hot` / `warm` / `promoted` / `rotation` groups and an `identifiers` registry. The dashboard reads it to show coverage.
- **`reference/detection_vectors.json`** — the catalogue of methods, the misalignment ladder, and the search angles shown on the Vectors tab.

The simplest way to learn each shape is to open the matching file in `data/sample/` and edit a copy.
