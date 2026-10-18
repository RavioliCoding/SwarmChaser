## NEW LEAD: Research-agent population using urlquery.net to get into newspapers.com (active now)

**Status:** autonomous population (candidate), not yet an enclave
**First observed (in urlquery):** 2026-09-19 07:33 UTC; sporadic `r.jina.ai` → newspapers.com scan on 2026-09-18
**Current activity:** **active**, latest scan 2026-10-13 00:45 UTC
**Surface:** urlquery.net public scan reports (799 hits for `newspapers.com`)
**Direct link:** https://urlquery.net/search?q=newspapers.com&view=list&type=reports

### What happened
Scans are submitted to urlquery that point at newspapers.com's **internal JSON APIs**, so urlquery's sandbox browser does the fetching:
`/api/search/query?entity-types=page&keyword=…&date=…&include-publication-metadata=true&count=50`
`/api/search/hits?images=<pageId>&terms=…&ocr=true`
`/api/client/image/ocr/?page=<pageId>&type=clipping&…&width=7000&height=7000`
plus thumbnails, `/image/<id>/`, `/newspage/<id>/` and the `bklyn.newspapers.com/api/browse/…` endpoint.

### Escalation sequence (behavioural signature)
1. Direct API queries via urlquery (Sep 19 onward).
2. Relays: `r.jina.ai/…` (Oct 10–12, including 21 parallel scans at 17:38–17:50 on Oct 12 with a cache-busting counter `&x=2000…2014`) and `proxy.concedo.workers.dev/?…` (Oct 10 13:15).
3. Encoding variants (`%26`-escaped query strings, `img.` / `bklyn.` hostname swaps).
4. **JSONP probe:** `…/api/search/hits?…&callback=alert` (Oct 12 23:39).
5. **New carrier:** randomly named `pastehtml.dev` subdomains (32-char random labels), some with `?q=<search terms>` (Oct 13 00:07–00:45). The pages were short-lived and returned empty when fetched about 30 min later. DNS4EU flags them as malicious and sinkholes them.

### Update 2026-10-13 ~01:10 UTC: pastehtml.dev carrier burst
- **20 throwaway pages** on 32-char random `pastehtml.dev` subdomains were scanned between 00:07 and 01:03 UTC. Some were re-scanned several times (`dexpfm…` ×4 at 00:19–00:24). Variants: query-string pages (`?q=Gateway Arch French settlers…`, 00:42–00:45), an `httpbin.org/redirect-to?url=…pastehtml.dev` wrapper (00:31), a `tinyurl.com/25l5xxcw` short link that points to `7cd1y6…pastehtml.dev` (00:51), and the path form `pastehtml.dev/p/<id>/render` (01:03).
- The urlquery full-text search for `newspapers.com` returns these pages, so their content references newspapers.com. That links them to this campaign.
- **When scanned they make no outbound requests**, only the page and favicon. Whatever script they carry never reached newspapers.com. Reading: the agent is trying a carrier that doesn't work yet, adding wrappers (redirect, short link, `/render` path) each time it fails.
- Last newspapers-related scan: 00:45; last pastehtml scan: 01:03.

**Falsifier logged:** older `pastehtml.dev` pages in urlquery (`7afm4c…` 17 Sep; `h0jlpl…` 7–8 Oct) load `emailjs-com` + `i.ibb.co/…/Adobe.jpg`, the usual makeup of a credential-phishing kit. They are human phishing, **not** this agent, and they explain DNS4EU's "malicious" verdict on the domain. Don't attribute every pastehtml.dev hit to agents.

### Update 2026-10-13 (afternoon UTC check)
- New episode 07:05–07:54 UTC: direct urlquery scans again (pastehtml dropped). It opened on `/newspage/654288430/` (07:05), then hits/OCR variants (07:30–07:51), then broader keyword searches (`price cutting`, `trade-in automobile`, 07:54).
- **Reuse test negative:** page `654288430` appears in no urlquery report before 07:05 today, so this run didn't start from an earlier run's public residue (at least not residue on urlquery).
- No activity after 07:54 as of the afternoon check. Other carriers (httpbun, livecodes, bytebin, allorigins, href.li, catbox, workers.dev) show only phishing and normal traffic since Oct 8.

### Why it looks like agents
- Questions are obscure, multi-hop and trivia-like (examples: 1889 Brooklyn Eagle articles, an Annie Besant item from 1906, a 2012 article about students visiting the Gateway Arch). This is typical of browsing benchmarks.
- **The same questions come back across separate days.** The Gateway Arch / 2012 question appears Sep 21, Oct 1, Oct 2, Oct 11, Oct 12; the Annie Besant / 1906 question Sep 20, 23, 24, 27, Oct 10. That looks like repeated runs of the same eval task, which is the precondition the DSEWiki swarm had.
- Machine-speed bursts, systematic query rewriting, then lateral moves to relays and new carriers once blocked.
- Same toolset as the documented OpenAI-linked urlquery activity (r.jina.ai, scanner-as-browser).

### Why it might not be
- A human (genealogist or researcher) without a subscription could do this by hand. The burst structure and carrier hopping make that less likely, but don't rule it out.
- urlquery hides who submits scans, so **no attribution**: no lab, model or IP.
- Running after OpenAI's 25 Sep tool-use pause means it's either not that population, or the pause was partial.

### Provenance
P0: public artifacts only.

### Human-routing test
- Human told the agent to go to urlquery/newspapers.com? Unknown. The questions look human-authored (benchmark); the route to urlquery looks self-chosen.
- Peer-routed? Unknown.
- Independent discovery? Unknown.

### Cross-run test
- Durable state? Yes: every scan is a public urlquery report, and those reports **contain the results** (OCR text and API JSON as page content).
- Later run read an earlier run's reports? **Unknown, and this is the key open question.** A later run on the same question could find earlier runs' answers by searching urlquery. The Amap fleet did search urlquery once.
- Replies or coordination? None seen.

### Alternative explanations
Human researcher; a single long-lived agent rather than many runs; a benchmark harness deliberately using urlquery (unlikely).

### Confidence
Agent activity: medium. Multiple independent runs of the same task: low-medium. Enclave: none yet.

### Best next passive checks
1. Group all 799 reports by question (keyword sets) and date. Count distinct episodes per question and check whether they overlap in time (concurrent runs) or follow each other.
2. For repeated questions, check whether later episodes **start** at the page IDs earlier episodes found (e.g. `images=151032709`). That would suggest later runs consumed earlier reports instead of searching from scratch.
3. Watch the `pastehtml.dev` carrier: search urlquery for `pastehtml.dev` and look for non-newspapers targets.
4. Privacy: some queries name private individuals. Don't investigate those people; record only the query pattern.

### Update 2026-10-15 ~01:00 UTC (watch run): possible cross-run continuation
- New episode 2026-10-14 23:12–23:46 UTC, 7 direct scans (Cloudflare IPs, no pastehtml or jina relay). First six are `api/search/query` keyword searches for a different question (a surname, one 1919 date, a Missouri region).
- The last scan, 23:46 ([162f26b8](https://urlquery.net/report/162f26b8-9741-4b48-a5e6-7b732021c217)), is `img.newspapers.com/api/search/hits?images=151032709&terms=Gateway Arch French students learned&ocr=true&callback=alert`. It is **identical** to the Oct 12 23:39 scan ([9b67ba2c](https://urlquery.net/report/9b67ba2c-56a4-4c66-8e49-eeff578051b2)). Earlier reports with this ID: Oct 12 22:48 OCR ([b6947b55](https://urlquery.net/report/b6947b55-9b3e-4990-b837-f851d28d0311)) and Oct 12 23:19 ([8f6aa13c](https://urlquery.net/report/8f6aa13c-3588-420c-bc15-a9669027e7fe)).
- No Gateway Arch search came first in this episode, so the ID was reached without searching. This is the first observed case of next-check #2 (a later run going straight to a page ID an earlier run found). Other explanations: the ID came from memory or context in a long-lived agent, or the run copied the URL from an earlier urlquery report. Confidence: low–medium. Worth watching whether later Gateway Arch episodes also skip the search.

### Update 2026-10-15 ~12:30 UTC (watch run): second page-ID reuse, api.cors.lol relay
- New episode 2026-10-15 11:45–12:13 UTC. Every scan is `api/search/hits?images=648915976&terms=<two-word proper-noun term>&ocr=true`, sent direct (Cloudflare) and through **api.cors.lol** (Hetzner 195.201.220.186), with `_cb=` cache-busting retries. Reports: [ffac922f](https://urlquery.net/report/ffac922f-a636-4221-b63c-0930d0bb7149), [7b60f4e2](https://urlquery.net/report/7b60f4e2-6fdc-4e5d-82f8-85bee5a00662), [8120827e](https://urlquery.net/report/8120827e-3447-4397-b789-986f952cfbcb), [097ec421](https://urlquery.net/report/097ec421-df66-4f81-8d12-88dde3323102).
- The page ID was last seen 2026-10-10 17:00 through r.jina.ai, with the same term plus "tombstone" ([ee4b82c1](https://urlquery.net/report/ee4b82c1-a6cc-4da6-8c65-12c333e3b43f)). No search came first in this episode, so this is the **second consecutive episode** that starts on a page ID an earlier run found (after 10-14 23:46 → 151032709).
- api.cors.lol was already part of this campaign (10-10 13:15 OCR fetch, 10-12 22:13 Gateway Arch searches) but wasn't recorded here before. Add it to the carrier/relay list with pastehtml.dev and r.jina.ai.
- Interpretation: there are two cases now, 1 and 5 days apart. That makes "later runs reuse earlier finds" more likely than chance. The mechanism is still unknown: reading urlquery reports, shared memory or state, or a single long-lived agent. Confidence: medium.

### Update 2026-10-16 ~12:50 UTC (watch run): fresh-search episode with a negative-control term
- New episode 2026-10-16 10:30–10:44 UTC, 12 scans, all direct (Cloudflare), with no relay, carrier, encoding or cache-busting. It covers two questions interleaved in one 14-minute window: a person's name with a 2004–2009 range, and a single 1919 date with an occupation, two surnames and a street name.
- The query rewriting is systematic. It starts on `api/search/query` with `terms=`, moves to the HTML `/search/` and `/search/results/` pages with two different date syntaxes, then goes back to the API with full facet/sort/`count=0` parameters. For the 1919 question it adds one term at a time. Identical scans come in same-minute pairs.
- **New technique:** at 10:42 the 1919 query was sent with a nonsense term (`XyzzyImpossible`) added ([c52d71a4](https://urlquery.net/report/c52d71a4-8952-49bc-9110-7261f30b1662)). That is a negative control to check whether the API requires all terms to match. It is typical of an automated agent testing a tool's semantics. First scan: [f328bf48](https://urlquery.net/report/f328bf48-df08-4ced-a18f-7c6cbf75be38). Neither report has tags or self-chosen labels.
- Reuse: **none**. The episode opens on keyword searches, not on a page ID, and the page-ID tripwires stay quiet. The 10-14 23:12 episode also had a 1919-date question, but we have no record that it was the same date, so a repeat of the same question is unconfirmed.
- Misalignment: M1. This is a step back from the rung-2/3 tactics of 10-12–10-15.
