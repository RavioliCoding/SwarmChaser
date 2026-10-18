# SwarmChaser

A small macOS dashboard for **watching, passively and read-only, for autonomous AI agents that use ordinary public web utilities to get around access limits** — and for seeing how far past their task they go.

It reads data that *you* produce (a JSONL log of observations) and turns it into a cockpit: a live network of the services being watched, a run timeline, a misalignment ladder, event threads, and a reader for archived agent activity. No account, no network calls, no external dependencies — it runs entirely on your machine.

> SwarmChaser is a **defensive / research** tool. It only ever *reads* and *displays* already-public records. It does not scan, probe, attack, or contact anything. See [Scope](#scope) and [SECURITY.md](SECURITY.md).

## Quickstart

**Option A — the Mac app (recommended):**

```bash
./app/build.sh
open SwarmChaser.app
```

Requires macOS 13.3 or later and the Xcode Command Line Tools (`xcode-select --install`). The app bundles the sample dataset, so it works the moment it opens; the top bar says **SAMPLE DATA** until you point it at your own folder (see below).

**Option B — in a browser:**

```bash
python3 scripts/serve.py
# then open http://127.0.0.1:8080/dashboard/
```

Binds to localhost only.

## What you're looking at

| Tab | Shows |
|-----|-------|
| Overview | A live "neuron" network — one cloud per watched service — and the latest status at a glance. |
| Timeline | A 3D strand torus of every watch run; drag to spin, click a run. |
| Run log | Every run as an expandable table. |
| Interpretation | A threat posture, auto-written narrative, and hypotheses with confidence. |
| Threads | One storyline per event, each rated on a 0–6 "how far past its task" ladder. |
| Vectors | The ways a blocked agent might route around a limit, and how to watch for each. |
| Transcripts | A plain-text reader for the research notes. |
| Intel | External references and report links. |
| Archives | *(optional)* A reader + activity charts for published swarm datasets. |

Every tab and panel has a one-line plain-words explanation ("simply put"); turn them off in View or with `E` once you know your way around. Press `?` for an on-screen guide. `V` opens View (light / dark / system theme, calm / full detail, explanations).

## Feeding it your own data

The dashboard reads a few files under a **data root** (bundled sample data by default):

```
leads/watch_log.jsonl      one JSON object per line, one per observation run
leads/threads.json         event storylines
leads/interpretation.json  analyst notes for the Interpretation tab
leads/leads.json           what you track: one entry per lead (edit it in the app with + add)
leads/watchlist.json       what to watch
reference/detection_vectors.json   the methods catalogue
```

The schema is documented in [docs/data-format.md](docs/data-format.md). To point the app at your own folder instead of the bundled sample:

```bash
open --env SWARMCHASER_ROOT=/path/to/your/data SwarmChaser.app
```

(`open` doesn't pass your shell's variables to an app, hence `--env`. In the browser it's `SWARMCHASER_ROOT=/path/to/your/data python3 scripts/serve.py`.)

**Adding leads.** Press **+ add** on the Overview leads panel, or **track** on anything under *possible new leads*: activity your log already recorded that no tracked lead covers (rows in a `catch_all` lead, or lead ids your log uses that aren't in `leads.json`). With your own data folder the Mac app saves `leads/leads.json` for you; with the bundled sample or in a browser it gives you the text to paste. Items with nothing new (quiet leads, routine runs, clear alerts) are drawn in a lighter tone so the ones that changed stand out.

How you *produce* `watch_log.jsonl` is up to you — SwarmChaser is just the viewer; it never searches anything itself. The methodology this project was built around is written up in [docs/methodology.md](docs/methodology.md).

## Archives (optional)

The Archives tab reads published third-party swarm datasets. They aren't bundled (they're large and belong to their publishers). To enable the tab:

```bash
python3 scripts/fetch_datasets.py     # downloads from source, then builds the views
```

Each dataset has its own terms — see the source pages linked in `scripts/fetch_datasets.py` before redistributing anything.

## Scope

**It does:** read a local JSONL log and public, already-published records; visualize them; render everything offline; save your lead list (`leads/leads.json`) when you edit it.

**It does not:** make network requests of its own (strict Content-Security-Policy, no outbound `connect-src`), open or follow agent carrier pages, scan or probe any target, contact anyone, or store credentials. External links are filtered by a host policy; known agent carrier/relay hosts are blocked outright.

Use it for defensive research and transparency, within the terms of the sources you observe. Don't use it to target or harass anyone.

## How it's built

- **App shell:** a single Objective-C file (`app/main.m`) wrapping a `WKWebView`, serving the UI and data through a private read-only `swarm://` scheme. No frameworks beyond Cocoa + WebKit.
- **Dashboard:** one self-contained `dashboard/index.html` — all charts are hand-drawn on canvas, no CDN or JS dependencies, strict CSP.
- **Build:** `app/build.sh` (clang; draws the icon, compiles, embeds a data snapshot, bundles the app).

## Credits

Built on public research into autonomous-agent activity, including work published by METR, Transluce, collusion.wiki, and swarmcha.se. SwarmChaser is an independent viewer and is not affiliated with any of them.

## License

MIT — see [LICENSE](LICENSE).
