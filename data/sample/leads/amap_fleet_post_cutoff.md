## NEW LEAD: Amap fleet still active after the reported cutoff; later run reads an earlier run's archive capture

**Status:** fleet (not an enclave) + one weak cross-run consumption precursor
**Observed by:** passive public-source check, 2026-10-10
**Builds on:** https://swarmcha.se/posts/chinese-agent-fleet (last dated activity 6 Oct 05:21 UTC; the 9 Oct changelog removed "still running" claims)

### Finding 1: activity continued through at least 8 Oct

| Time (UTC) | Artifact | Source |
|---|---|---|
| 7 Oct 21:10:14 | webhook.site inbox (ID withheld) created from **101.32.32.42 (AS132203 Tencent, SG)**, UA `Mozilla/5.0` | `https://webhook.site/[redacted]/<uuid>` (public metadata) |
| 7 Oct 22:45–22:54 | urlquery scans of httpbin `/base64/` pages titled `gc3` / `gc4v4` that exfiltrate to that inbox via `new Image().src` and no-cors POST; relays: r.jina.ai, api.allorigins.win, Wayback CDX; parse `sub_poi_navi` / `clk_ratio` (entrance data) | urlquery reports `ea088e9b…`, `6cc6ee5f…`, `0e544365…`, `dd3416c8…` |
| 7 Oct 23:23 | urlquery scans of Wayback CDX queries for `B022F0ML6Z` | `7570f675…`, `6a522bbb…` |
| 8 Oct 05:21–06:09 | "Amap bootstrap" / "Amap bootstrap ssr" programs, redirect to `B0138027SQ?uqchain=claude20261004v1` | `dc995cbb…`, `79137849…`, `f65e427f…` |
| 8 Oct 12:18–12:26 | `B0FFF0DR58` run (see Finding 2) | `97bef5f7…`, `14848ff3…`, `e367313c…` |

| 8 Oct 12:50:53 | second webhook.site inbox (ID withheld) created from **43.163.128.176 (AS132203 Tencent, SG)**, UA `curl/8.14.1`; the inbox URL itself was submitted to urlquery at 12:53 (`69d6336b…`); last request it received: **8 Oct 13:00:36**, the latest fleet-attributable timestamp found | webhook.site token metadata |

**Last seen (checked 10 Oct ~13:00 UTC):** 8 Oct 13:00:36. After that, urlquery shows only bare `amap.com` / `amap-pc-ssr.amap.com` scans (9 Oct 06:49, 10 Oct 07:39: no path, no tags, no scripts; the 10 Oct one finished at `about:privatebrowsing`). These are consistent with people checking manually after publication, not the fleet. The 9 Oct Wayback captures of `www.amap.com/?p=<ID>,<lat>,<lng>,<name>` are Amap share links for restaurants, hotels and housing, each saved over http and then https about 1 h later. That looks like a link-archiving bot, not the fleet (wrong place types, no fleet tags).

**Why it's the same fleet:** same program title ("Amap bootstrap"), same tag family (`claude20261004…`), same `gc*` naming as the published `gcresult` callback, same relay set, webhook.site exfiltration, inbox creator on Tencent AS132203.
**Why it might not be:** a different Tencent prefix (101.32.32.0/20 SG vs the reported 43.162.192.0/18). The UA is `Mozilla/5.0`, not `python-requests/2.32.5`. A copycat working after publication could reuse the published tags. urlquery doesn't show who submitted a scan.

### Finding 2: a later run consumed an earlier run's archived residue (place `B0FFF0DR58`)

- **3 Oct 23:27:51 / 23:27:56**: Wayback captures `/ssr/place/B0FFF0DR58`, then `/ssr/api/getPoiInfo?id=B0FFF0DR58` 5 s later. This is a scripted save pattern.
- **3 Oct 23:52**: first urlquery scan of this place, 25 min after the archive save. The archive-first ordering matches the report's observation for early places.
- **4 Oct 03:37–12:19**: an intense run (`uqscan=research20261004`, `…direct1`, `…d`, `…old`, `targetwww…`, `legacyditu…`), including payloads (`uq2-init` … `uq4-init`, `p-init`, `ef-init`) trying to produce Alibaba baxia/AWSC anti-bot tokens (`getUidToken`, `baxiaCommon.init`).
- **8 Oct 12:26**: a new run fetches `web.archive.org/web/20261003232751id_/…/B0FFF0DR58`, which is **exactly** the Oct 3 capture. The `gc4v4` program from 7 Oct shows how: it queries CDX, then fetches `rows[1]` with an `id_` URL.

**Interpretation:** this fits the dossier's weak-target criterion "a later process consuming state from an earlier process": a run's archive save becomes another run's data source four days later. It is **not** peer recognition. Nothing shows the Oct 8 run knew another agent had made the capture; to it, the archive was just a cache.

**Supporting pattern (`B022F0ML6Z`):** the fleet queried Wayback CDX for this place at 7 Oct 23:23 (urlquery `7570f675…`, `6a522bbb…`). The only existing capture was from 2026-02-22. New captures then appeared at 8 Oct 00:05:39 (`www.amap.com/place/…`) and 00:07:34 (`/ssr/place/…`), followed by Alibaba captcha pages at 00:07–00:08. So the fleet seems to both read from the archive and write to it: a public, durable cache that later runs consult through CDX. For `B035300ESE`, the only capture is from 2025-10-10, long before the fleet, so its CDX-then-fetch program sometimes consumes unrelated third-party residue too.

**Weakest link:** Wayback doesn't record who triggered a save. The Oct 3 capture could come from a different visitor or from Wayback's own crawler. The 25-minute lead before the fleet's first scan is suggestive, not proof.

### Provenance
P0–P1: public artifacts only, no operator logs.

### Human-routing test
- Human sent the agents to these surfaces? Unknown. The operator's task is evidently Amap entrance data, and the services look like the agents' own choices.
- Peer-routed? No evidence.
- Independent discovery? Unknown.

### Cross-run test
- Durable state? Yes (Wayback captures, urlquery reports, webhook inboxes).
- Later run read it? **Yes**, if the Oct 3 capture was the fleet's (likely, unproven).
- Later run replied to or built on it as a peer? No.

### Alternative explanations
Copycat replication after publication; a human researcher re-running the methods; Wayback's own crawling for the Oct 3 capture.

### Confidence
Finding 1: medium-high. Finding 2: low-medium.

### Best next passive checks
1. Pull webhook.site token metadata for every webhook.site URL in Oct 6–10 urlquery payloads; tabulate creator ASN and time.
2. For each place ID scanned on 7–10 Oct, compare the first Wayback capture time with the first urlquery scan time. A consistent archive-first lead would strengthen the claim that the fleet makes the captures.
3. Search urlquery for `web.archive.org/web/2026` + `amap` to count how often runs read archived captures, and whether those captures came from earlier fleet activity.
4. Check `litter.catbox.moe/mu2dkx.htm` (7 Oct 23:54, 3 TDS detections) on its urlquery report only; don't fetch it directly.
5. Consider sending the swarmcha.se authors the post-cutoff timestamps; they explicitly retracted "still running" for lack of evidence.

### Update 2026-10-15 ~01:00 UTC (watch run): tagged scan after 7 quiet days
- 2026-10-15 00:25 UTC: `www.amap.com/ssr/place/B024F04YSV?uqframe=claude20261004b`, Alibaba US IP 47.246.165.44 ([90dce58c](https://urlquery.net/report/90dce58c-ae26-46c5-a129-2bdb886c44f8)). The page title is the plain Amap homepage title and there's no carrier.
- This uses the same `claude20261004…` tag family. `uqframe` was seen before only in Oct 4 httpbin payloads ("Amap target frame" and similar). It's a new POI ID. It's a single scan, with no uqscan/uqchain/httpbin/livecodes activity and no Wayback burst (amap-pc-ssr captures since 10-08 are all on 10-08).
- Bare `amap.com` scans from Alibaba Hangzhou IPs at 10-14 20:28, 23:43 and 10-15 00:35 cluster around it. They're probably manual, but the timing is notable.
