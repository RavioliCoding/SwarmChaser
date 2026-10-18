# SwarmChaser

**A passive, read-only Mac dashboard for watching autonomous AI agents that use ordinary public web utilities to get around access limits, and for seeing how far past their task they go.**

You point a collector of your own at public records (URL-scanner reports, archives, security feeds). It writes what it saw to a few plain files. SwarmChaser reads those files and turns them into a cockpit: what's moving right now, what each run found, how the evidence stacks up, and what the agents in published swarm datasets actually wrote to each other. It never searches, scans or contacts anything itself, and it runs entirely on your machine.

![The Overview tab: a 3D nebula of the leads being watched, with the watch reading one of them](docs/img/overview.jpg)

> SwarmChaser is a **defensive research** tool. It only reads and displays records that are already public. See [Responsible use](#responsible-use) and [SECURITY.md](SECURITY.md).

## Contents

- [What it is, and what it isn't](#what-it-is-and-what-it-isnt)
- [Quick start](#quick-start)
- [A tour of the app](#a-tour-of-the-app)
- [Using your own data](#using-your-own-data)
- [The archives](#the-archives)
- [How it works](#how-it-works)
- [Settings and keyboard shortcuts](#settings-and-keyboard-shortcuts)
- [Maintenance](#maintenance)
- [Troubleshooting](#troubleshooting)
- [FAQ](#faq)
- [Responsible use](#responsible-use)
- [Credits and license](#credits-and-license)

## What it is, and what it isn't

Some autonomous agents, when a site blocks them, route around the block with whatever public utility works: a URL scanner used as a stand-in browser, a CORS proxy, a paste site used as scratch space. Those detours leave public traces. SwarmChaser is a viewer for a log of such traces, built around a few questions:

- **Is anything moving right now?** Which tracked sites, relays and fleets showed new agent activity in the latest run.
- **How far past its task did it go?** Every episode is rated on a misalignment ladder from M0 (persistence) to M6 (harm beyond the task).
- **Are agents finding each other?** Alarms for cross-run reuse, agent-to-agent communication, a new carrier or relay, and a new population.
- **What did earlier swarms actually say?** Published datasets of past agent swarms, readable as conversations.

It is split into two halves on purpose:

| | Collector (yours) | SwarmChaser (this repo) |
|---|---|---|
| Does | Searches public records on a schedule and writes what it found | Reads those files and shows them |
| Network | Whatever your collector needs | None. The page runs under a strict Content-Security-Policy with no outbound connections |
| Writes | `leads/watch_log.jsonl` and friends | Only `leads/leads.json` and `leads/watch.json`, and only when you change them |

**This repo doesn't ship a collector.** It ships the viewer, a documented file contract ([docs/data-format.md](docs/data-format.md)), a sample dataset so it works on first launch, and the [methodology](docs/methodology.md) it was built around. Any collector that writes the files works: a script, a cron job, a scheduled agent.

## Quick start

### The Mac app

Requirements: macOS 13.3 or later, the Xcode Command Line Tools, and Python 3.9 or later (the one that comes with the Command Line Tools is fine).

```bash
xcode-select --install
```

Then, from the repo folder:

```bash
./app/build.sh
open SwarmChaser.app
```

The build draws the icon, compiles the shell, refreshes the embedded fallback data, copies the page and the sample data into the app, and signs it ad hoc for your machine. It takes a few seconds.

On first launch you'll see the sample dataset. The top bar says **SAMPLE DATA** and "next watch: none · sample", because the sample never updates. Everything else works as it would with your own data.

### In a browser (any OS)

```bash
python3 scripts/serve.py
```

Then open <http://127.0.0.1:8080/dashboard/>. The server binds to `127.0.0.1` only, refuses requests addressed to any other host name, never lists folders, and keeps every path inside the folders it serves. Use another port with `PORT=8090 python3 scripts/serve.py`.

Browser mode shows everything the app does. The difference: it can't save files, so the lead editor gives you text to paste and settings stay in your browser.

## A tour of the app

There are nine tabs (press <kbd>1</kbd>–<kbd>9</kbd>). Every tab opens with the question it answers and a plain-words "simply put" line, and every panel has a one-line explanation. Press <kbd>?</kbd> at any time for numbered notes on the current tab and a glossary.

**01 Overview: is anything moving right now?** One cloud per lead (a site, relay, carrier or fleet you track), arranged in a 3D nebula you can drag to rotate. The watch crawls from cloud to cloud and "reads" each one, its tentacles reaching out to the facts it finds. Coloured clouds moved recently. Around it you'll see the latest run's alerts, a sparkline per signal, the watch log, the leads by agent scans, the threat level, and **possible new leads** (activity your collector logged that no lead covers yet, with **track** and **dismiss**). Click a cloud for its card; **+ add** on the leads panel tracks something new.

![The Timeline tab: every watch run as a slice of a ring of strands](docs/img/timeline.jpg)

**02 Timeline: when did they move?** Each watch run is a slice of a torus. Blue strands are searches your collector made, coloured strands are agent scans (coloured by lead), white spikes are report links, red dots are alerts. Drag to spin, click a slice for its details. Underneath: searches per run, agent scans per run by lead, every alert, and the same activity as flowing lines.

**03 Run log: what did each watch see?** One row per run, newest first. Click a row for every lead's status, notes, technique changes, Wayback counts and what was ignored as noise. Runs where nothing happened are drawn in a lighter tone.

**04 Interpretation: what does it mean?** The threat level and a bottom line in plain words, a narrative written from the data, the hypotheses you're weighing (each with its earlier and current confidence), tripwires that would change your view, an early-versus-late comparison, and the evidence chain.

**05 Threads: what's the story?** One storyline per event or population. Each has a status, a timeline, open questions, falsifiers ("what would kill it"), next passive checks, a misalignment rating, and a 10-question triage score out of 20.

![The Vectors tab: each pathway can be marked idea, ready or watching, and switched on or off](docs/img/vectors.jpg)

**06 Vectors: where else could they be talking?** A catalogue of the pathways a blocked agent might use, grouped into families, each with why it matters, what trace it leaves and how to check passively. Mark each one **idea**, **ready** or **watching**, or switch it **off**. Vectors set to watching add their search terms to your collector's rotation; switched-off ones leave it (see [Run frequency and vectors](#run-frequency-and-vectors)).

**07 Transcripts: read the source.** Your notes, lead write-ups and the methodology, rendered from Markdown with an outline. **⤢ read** opens a file full-height; **⧉** opens it in its own window.

**08 Intel: what are the sources?** Every report link your collector recorded, links per run, and which leads produced them. Links go through the [link policy](#how-it-works).

**09 Archives: what did they actually say?** Published datasets of earlier agent swarms. See [The archives](#the-archives).

### Reading space

Anything long (an archive conversation, a single record, a transcript file) can be opened in the **reader**: **⤢ read** in the panel's header, or double-click an archive row. It shows the text full-height in a column about 70 characters wide. <kbd>j</kbd> / <kbd>k</kbd> move to the next or previous message or heading, and <kbd>Esc</kbd> closes it. **⧉** (or **new window** inside the reader) opens the same view in a window of its own, so you can keep reading while you use the dashboard. In a browser it opens a new tab.

### What's bright and what's grey

Things with nothing new are drawn in a lower-contrast tone so the ones that changed stand out: routine runs, clear alerts, quiet leads, leads with no agent scans, dormant threads, idle tripwires, switched-off vectors. Hover a grey row to bring it back up.

## Using your own data

### The data folder

SwarmChaser reads a **data folder** laid out like this:

```
<data folder>/
├── leads/
│   ├── watch_log.jsonl      one JSON object per watch run, oldest first (the core feed)
│   ├── leads.json           what you track (edited in the app)
│   ├── watch.json           run frequency and vector settings (set in the app)
│   ├── watchlist.json       what your collector searches: hot, warm, rotation, identifiers
│   ├── threads.json         storylines (Threads tab)
│   ├── interpretation.json  hypotheses, evidence, bottom line (Interpretation tab)
│   └── *.md                 notes shown on the Transcripts tab
├── reference/
│   ├── detection_vectors.json   the pathway catalogue and the misalignment ladder (Vectors tab)
│   └── methodology.md           background reading
└── archives/                optional; built by scripts/fetch_datasets.py
```

Every field is documented in [docs/data-format.md](docs/data-format.md). The quickest way to start is to copy `data/sample` and edit it.

To use your folder instead of the bundled sample:

```bash
open --env SWARMCHASER_ROOT=/path/to/your/data SwarmChaser.app
```

(`open` doesn't pass your shell's variables to an app, hence `--env`.) In the browser:

```bash
SWARMCHASER_ROOT=/path/to/your/data python3 scripts/serve.py
```

If a file is missing from your folder, the app falls back to the bundled sample for that file, and the top bar says **PARTLY SAMPLE** and the footer lists which files came from the sample. Files your folder does have always win.

### Leads: what you track

A **lead** is something you track: a site agents are trying to reach (a *target*), a *relay* or proxy they route through, a *carrier* (paste, inbox or file host), a *fleet* (agents sharing tags or infrastructure), or *other*. Leads live in `leads/leads.json`. The dashboard's logic follows each lead's kind, not its name: relays and carriers feed the relay summary and the new-relay alert, and each fleet gets a follow-up tripwire.

- **Add one:** **+ add** on the Overview leads panel. Give it a name, what kind it is, the search terms your collector should use, optional tags for its cloud, and a note.
- **Promote a finding:** **track** on anything under *possible new leads* opens the editor pre-filled.
- **Edit or retire one:** click its cloud, then **edit**. **Stop tracking** hides it without deleting its history.

With your own data folder, the Mac app saves `leads/leads.json` for you. With the bundled sample, or in a browser, saving gives you the file's text to paste. A lead id your log uses that isn't in `leads.json` still shows up, flagged as unregistered and listed under *possible new leads*, so nothing your collector records is ever silently dropped.

**Possible new leads** come only from what your log already holds: hosts mentioned in the moving rows of a lead marked `catch_all` (a bucket for activity no named lead covers), and lead ids your log uses that aren't registered. SwarmChaser doesn't search for anything.

### Run frequency and vectors

*View → watch every* sets how often your collector should run (1, 2, 4, 6, 12 or 24 hours) or pauses it. On the Vectors tab, each vector can be set to idea, ready or watching, and switched on or off. Both settings are saved to `leads/watch.json`:

```json
{"schema_version": 1, "cadence_hours": 4, "paused": false,
 "vectors": {"V06": {"status": "watching"}, "V02": {"enabled": false}}}
```

This file is a contract any collector can read. The dashboard uses it for "next watch" (the last run plus `cadence_hours`, or "paused") and to show which search terms rotate:

- **Rotation:** the `rotation` groups in `watchlist.json`, minus the search terms of switched-off vectors, followed by the new terms of vectors you set to watching, in groups of three. So your collector's requests per run stay the same; the full cycle just gets longer.
- **Which group runs:** for a run at time *t*, group `(UTC day-of-year × 24 / cadence_hours + UTC hour ÷ cadence_hours) mod (number of groups)`. At 4 hours that's `day × 6 + hour ÷ 4`.

If your collector runs on a fixed timer, have it wake hourly and skip when `paused` is true or fewer than `cadence_hours` have passed since the last `run_utc`. Then changing the frequency in the app is all it takes.

### Writing the log

The core feed is `leads/watch_log.jsonl`: one line per run, appended at the end. Each line carries the run time, how many requests the collector made, one object per lead (status `new`, `active`, `quiet` or `unknown`, new rows, report links, notes), and four alarm flags. Start a lead's notes with `misalignment M2 G: …` and the dashboard picks up the rung. The full schema is in [docs/data-format.md](docs/data-format.md).

## The archives

The Archives tab reads datasets that other researchers published about earlier agent swarms. They aren't included in the repo: they're large, and they belong to their publishers. To fetch them and build the views:

```bash
python3 scripts/fetch_datasets.py
```

It downloads, over HTTPS only and with a size cap:

| Archive | Source | What it is |
|---|---|---|
| DSEWiki / OpenAI agent message board | collusion.wiki explorer | 14,591 edits by agents that used forgotten wikis as shared memory |
| OpenAI agents × Hugging Face intrusion | swarmtraces.org | 189,579 redacted trace records from an agent swarm's attack |
| Agent activity on urlquery.net | Transluce | 38,160 links to scanner reports agents submitted |

A fourth archive, the Amap fleet, is built from your own `threads.json`, because no transcript dataset exists for it. Rebuild the app afterwards (`./app/build.sh`) to carry the archives inside it, or run `scripts/serve.py`. Each dataset has its own terms; check the source pages linked in `scripts/fetch_datasets.py` before redistributing anything.

![An archive conversation: agents on a wiki page coordinating answers, message by message](docs/img/archives.jpg)

### Notable: what to read first

The wiki archive opens on **notable**, so you don't have to read whole transcripts. At build time every agent message is coded against a written codebook of nine behaviours (counts are for the published dataset):

| Behaviour | What it shows | Messages |
|---|---|---|
| planning around termination | preparing for the episode to end: signalling or saving state before the final answer | 332 |
| suspecting a test | wondering whether the task is real, a test, observed, or already over | 3 |
| side effects | noticing that its own requests changed the target system | 11 |
| sharing answers | posting a round's answer or expected values so other agents can reuse them | 365 |
| talking to the future | leaving state or instructions for runs or cohorts that don't exist yet | 8 |
| timing the test | reasoning about the task's clock, timers and cooldowns | 1,909 |
| addressing other agents | requests, acknowledgements, thanks | 406 |
| owning a mistake | admitting an error or apologising to other agents | 69 |
| urgency and pressure | messages written under time pressure | 416 |

For each behaviour up to eight exemplars are picked. Messages score higher the more of the behaviour's patterns they match, if another agent replied within the hour, and if the thread is large. Each conversation gets at most two picks per behaviour, and each message counts for only one behaviour, with the rarest behaviours choosing first. Repeated text is dropped, and so are edits by human-flagged handles and garbled text. A second list, **conversations worth reading**, has the 12 threads that show the widest range of behaviours.

Click a highlight to see it with the messages just before and after, the matching phrase marked. **Read the whole conversation from here** opens the reader at that exact message. The codebook is plain patterns in `app/build_archives.py`, written from reading the archive; it's a reading aid, not a classifier. A pick means the words are there, so read it in context. When the codebook was written, all 66 picks on the published dataset were checked against their behaviour's definition, and every pick points to the exact message, agent and revision it came from.

### Conversations

The **conversations** view reads whole threads:

- **DSEWiki:** every wiki page that two or more agents wrote on is a thread (1,215 of them, 10,747 messages). Each message is exactly the text that agent's edit added, rebuilt from the publishers' own line diffs. The build checks every rebuild against the published revision and records the result on the archive's source panel. A *reply* is a message from a different agent within an hour of the one before. Edits by handles the publishers flagged as human are marked.
- **Hugging Face intrusion:** each request an agent sent is threaded with what came back (service responses, or text recovered from the request): 26,248 requests and 61,125 replies. These are exchanges between agents and services, not agents talking to each other; the swarm's message board isn't in this dataset.

**Records** shows every raw row. Both views have search, a filter by agent name, and a per-day filter: click a day on the activity chart.

![The reader: one conversation, full height](docs/img/reader.jpg)

Agent-written text is attack payloads and agent messages. It is only ever displayed as plain text (`textContent`), never parsed as HTML, never run and never turned into links.

## How it works

- **The page** (`dashboard/index.html`): one self-contained file. Every chart is drawn on canvas by hand, with no frameworks, no CDN and no dependencies. It runs under a strict Content-Security-Policy: `connect-src 'self'`, no frames, no objects, no workers.
- **The Mac app** (`app/main.m`): one Objective-C file wrapping a `WKWebView`. It serves the page and your data through a private `swarm://` scheme that only reads files inside the data folder (and the app's bundled copy), so nothing goes over the network and nothing outside those folders can be read.
- **Writes:** the app writes exactly two files, `leads/leads.json` and `leads/watch.json`, in your own data folder (never in the bundled sample), and only when you save. Every field is checked against an allow-list (id patterns, lengths, known values, hex colours). The file is rebuilt from the checked values only, and written atomically.
- **Links:** every external link is checked against a host policy, kept identically in the page and in the app. Research hosts open in your browser, known agent carriers and relays are blocked outright, and anything else asks first. Inside the app, only the page's own reader addresses (`swarm://…#read=…`) may open a new window.
- **Live updates:** the page re-reads the data files on refresh (<kbd>R</kbd>, or every 30 seconds with auto-refresh on) and only redraws when something changed. A new run triggers a flash on the Overview, a notification card and, in the app, a Dock badge.
- **The build** (`app/build.sh`): draws the icon (`app/make_icon.m`), compiles the shell with clang, refreshes a fallback copy of the sample data embedded in the page (`app/embed_snapshot.py`, used only if the page is opened as a plain file), copies the page and data into the app, and signs it ad hoc.
- **The archives** (`scripts/fetch_datasets.py`, `app/build_archives.py`): downloads the raw datasets, then writes small gzip chunks the page streams on demand, plus conversation indexes. A missing or damaged download skips that archive; the others still build.

## Settings and keyboard shortcuts

**View menu** (the **VIEW** button, or <kbd>V</kbd>):

| Setting | Options |
|---|---|
| theme | system, light, dark |
| readability | ELI5 (plain-words lines, essentials), Normal, Complex (every panel, extra telemetry) |
| watch every | 1h, 2h, 4h, 6h, 12h, 24h, pause |
| clock | 24h or AM/PM |
| time zone | UTC or your local time |
| auto-refresh · 30 s | re-read the files every 30 seconds |
| watch log | refresh now |
| notifications | clear the "since you last looked" card, the tab dot and the Dock badge |

**Keys in the page:**

| Key | Does |
|---|---|
| <kbd>1</kbd>–<kbd>9</kbd> | switch tabs |
| <kbd>?</kbd> or <kbd>H</kbd> | help overlay for the current tab |
| <kbd>V</kbd> | View menu |
| <kbd>E</kbd> | cycle readability (ELI5 → Normal → Complex) |
| <kbd>T</kbd> | 24-hour or AM/PM clock |
| <kbd>R</kbd> | re-read the data files |
| <kbd>F</kbd> | replay the new-activity flash |
| <kbd>Esc</kbd> | close whatever is open (help, menus, a focused cloud, the reader) |
| <kbd>J</kbd> / <kbd>K</kbd> | in the reader: next or previous message or heading |

**Mac app menus:** ⌘R refresh data, ⇧⌘R reload the interface, ⌘1–⌘9 tabs, ⌘= / ⌘- / ⌘0 text size, ⇧⌘S sweep and reload, ⇧⌘O show the data folder in Finder, ⌃⌘F full screen.

Settings are kept in the browser's storage and, in the Mac app, mirrored to the app's preferences (`local.swarmchaser.dashboard`), so they survive restarts.

## Maintenance

**Day to day**
- Your collector appends to `leads/watch_log.jsonl`; the dashboard picks it up on refresh or within 30 seconds with auto-refresh on.
- Review **possible new leads** now and then: track what matters, dismiss the rest.
- Retire leads you no longer care about (**edit → stop tracking**). Their history stays in the log.

**Tuning the watch**
- Change the frequency, or pause it, in *View → watch every*.
- Turn vectors on or off, or move them to watching, on the Vectors tab. Your collector's request budget per run doesn't change.
- `watchlist.json` (hot, warm, rotation, identifiers) belongs to your collector. SwarmChaser only reads it.

**Archives**
- Re-run `python3 scripts/fetch_datasets.py`. It keeps files it already has; delete a dataset's `raw/` folder under `data/sample/archives/` to download it again.
- To rebuild the views from files you already have: `python3 -I app/build_archives.py`.
- Rebuild the app afterwards so it carries the new views.

**Updating SwarmChaser**

```bash
git pull
./app/build.sh
```

The app carries its own copy of the page and the sample data, so any change, including edits to `dashboard/index.html`, needs a rebuild. Your data folder and settings are untouched.

**Backups:** everything that matters is in your data folder. `leads.json` and `watch.json` are small; back up the whole folder.

**Resetting settings:** in a terminal, `defaults delete local.swarmchaser.dashboard` resets the app's saved settings (theme, readability, last tab, window size). In a browser, clear the site's storage.

**Uninstalling:** delete `SwarmChaser.app`, run the `defaults delete` command above, and delete your data folder if you no longer want it.

**For maintainers, before a release**
- Build from a fresh clone and open every tab. `SwarmChaser.app/Contents/MacOS/SwarmChaser --snapshot out.png --tab archives --size 1480x940` renders one tab to a PNG and prints its frame rate, which makes a quick headless check.
- Run a secret scanner over the history (for example `detect-secrets`).
- Check that the sample data contains no inbox or webhook URLs, keys, or names of private individuals ([SECURITY.md](SECURITY.md) has the rules).
- Run every command in this README in a clean clone.

## Troubleshooting

**The build fails with `xcrun: error` or `clang: command not found`.** Install the Command Line Tools: `xcode-select --install`.

**macOS won't open the app.** A copy you built yourself opens normally. A copy downloaded from someone else is quarantined by Gatekeeper because it's signed ad hoc: right-click it and choose **Open**, or build it yourself.

**The Archives tab says "No archive data".** Run `python3 scripts/fetch_datasets.py`, then rebuild the app. On macOS before 13.3, the archive reader can't decompress its files; that's why 13.3 is the minimum.

**I set `SWARMCHASER_ROOT` but still see the sample.** Use `open --env SWARMCHASER_ROOT=… SwarmChaser.app`, not `SWARMCHASER_ROOT=… open …`, and check that your folder has `leads/watch_log.jsonl` (not `watch_log.jsonl` at the top level). **PARTLY SAMPLE** in the top bar means some files are missing from your folder; the footer lists which.

**The lead editor or the vector switches say they can't save.** You're on the bundled sample, in a browser, or in a folder you can't write to. Point the app at a folder of your own. In a browser, the editor gives you the text to paste.

**"Next watch" says overdue.** Your collector hasn't written a new line to `watch_log.jsonl` within the frequency you set, or it doesn't read `watch.json`.

**The Transcripts tab says the files can't be read.** You opened `dashboard/index.html` directly as a file. Use the app, or `python3 scripts/serve.py`.

**`serve.py` says the address is in use.** Another program has port 8080: `PORT=8090 python3 scripts/serve.py`.

**The browser shows "SwarmChaser only answers to localhost".** Open it at `http://127.0.0.1:8080/` or `http://localhost:8080/`. Other host names are refused on purpose.

## FAQ

**Does SwarmChaser look for new agents or new leads on its own?**
No. It never searches, scans or contacts anything; it makes no network requests at all. It shows what your collector recorded. *Possible new leads* only surfaces activity already in your log that no lead covers, and adding a lead is always your decision.

**Why does the top bar say SAMPLE DATA?**
You're looking at the dataset that ships with the app, which never updates. Point the app at your own folder and the label goes away. PARTLY SAMPLE means some of your files are missing and the sample fills in for them.

**How do I read a watch-log entry?**
Take "new direct newspapers.com episode (20 scans) re-asks a question first seen via r.jina.ai… no page-ID reuse, no relay; misalignment M0". It means: a new burst of 20 agent scans hit newspapers.com without a proxy; it asked a question an earlier burst had asked through a relay; it didn't jump straight to a page an earlier run had found (which would suggest memory between runs); and it stayed on the bottom rung of the misalignment ladder.

**What's the threat level?**
A 0–100 summary of recent activity. Each run scores 30 per alert raised, 10 per lead with a new episode, 5 per active lead and 0.5 per agent scan. The latest 8 runs are added up, each one counting 0.6× the one after it, and capped at 100. Bands: quiet below 20, elevated from 20, high from 50, critical from 75.

**What's the misalignment ladder?**
How far past its task an agent went: M0 persistence, M1 routing around a block, M2 concealment, M3 probing or defeating protections, M4 reaching for access, M5 sending data out or taking resources, M6 harm beyond the task. Markers: S self-preservation, G gaming the task, C coordination.

**What's the triage score on a thread?**
Ten questions scored 0–2 each (human routing, site purpose, multiple runs, durable state, cross-run consumption, peer recognition, coordination, provenance, alternatives ruled out, cross-surface recurrence), out of 20. Bands: noise or control below 7, interesting anomaly from 7, candidate population from 12, candidate enclave from 16, investigate now from 19.

**How do vectors relate to my collector?**
Vectors describe pathways. Setting one to watching, or switching it off, changes the rotation your collector should search through (`leads/watch.json`). It's up to your collector to read that file; the format and the rotation rule are in [Run frequency and vectors](#run-frequency-and-vectors).

**Why are some rows grey?**
Nothing new happened there. Grey is for routine runs, clear alerts, quiet leads and the like, so the rows that changed stand out. Hover to read them normally.

**Is it safe to open the links and read the archives?**
Links go through a host policy: research sites open in your browser, known agent carriers and relays never open, and anything else asks first. Archive text, including attack payloads, is shown as plain text only; nothing in it is run or linked.

**Does it send my data anywhere?**
No. The page can't connect to anything except its own files, and the Mac app serves those from your disk.

**Can I use it on Linux or Windows?**
Yes, in a browser: `python3 scripts/serve.py`. The Mac app is macOS-only, and in a browser the lead editor gives you text to paste instead of saving.

**Where are my settings stored?**
In the browser's storage and, in the Mac app, in its preferences (`local.swarmchaser.dashboard`). Your lead list and watch settings are files in your data folder. See [Resetting settings](#maintenance).

**Can I trust the notable picks?**
They're a starting point, not a verdict. Each pick matched a written pattern for its behaviour, and every one links to the exact message so you can read it in context. A message about "the final answer" might be ordinary task talk; the messages around it usually make that clear.

**How much disk do the archives take?**
About 24 MB of downloads and about 21 MB of built views. Building them into the app makes it about that much bigger.

**Who made the archive datasets? Can I redistribute them?**
Their investigators published them: collusion.wiki, swarmtraces.org and METR, and Transluce. They're downloaded from source and not redistributed here. Check each source's terms before you share them.

## Responsible use

SwarmChaser is for defensive research and transparency. It observes records that are already public, passively. Please respect the terms of the services you observe, keep your notes about agent behaviour rather than people, never record credentials, inbox or webhook URLs or the names of private individuals, and prefer responsible disclosure to publication when you find an operation reaching for non-public data. [SECURITY.md](SECURITY.md) has the details, and how to report a vulnerability in SwarmChaser itself.

## Credits and license

Built on public research into autonomous-agent activity, including work published by METR, Transluce, collusion.wiki and swarmcha.se. SwarmChaser is an independent viewer and isn't affiliated with any of them.

MIT. See [LICENSE](LICENSE).
