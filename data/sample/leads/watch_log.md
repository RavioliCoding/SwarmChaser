# Swarmchaser watch log

Last checked: 2026-10-16 ~20:12 UTC. Newest per lead: newspapers.com 2026-10-16 10:44 · pastehtml.dev 2026-10-13 01:03 · r.jina.ai→newspapers 2026-10-12 17:50 · api.cors.lol→newspapers 2026-10-15 12:04 · Amap fleet (tagged) 2026-10-15 00:25 · httpbin/httpbun/livecodes/webhook.site agent payloads 2026-10-08 06:09 (unlinked httpbin test 2026-10-15 22:23)

## 2026-10-16 ~20:12 UTC

- **newspapers.com:** Quiet (10-16 10:44).
- **api.cors.lol:** Quiet (10-15 12:04).
- **pastehtml.dev:** Quiet (10-13 01:03).
- **r.jina.ai:** Quiet (10-12 17:50).
- **Amap fleet:** Quiet. Last tagged scan still 10-15 00:25.
- **httpbin/webhook.site/[redacted]:** Quiet. Newest httpbin row still the 10-15 22:23 test.
- **Cross-run reuse:** no new episode; tripwires 151032709 (10-14) and 648915976 (10-15) unchanged. **Agent-communication signs:** none.
- Watchlist: hot 6 · warm 4 of 9 (odd: 151032709, 648915976, webhook.site, allorigins) · promoted none · rotation 11 (ipinfo.io, hackmd.io, web.archive.org/save): nothing agent-like.
- Misalignment: no agent-like episodes.
- Wayback: backing off after 429. Not a deep-pass hour.
- Ignored: bare `amap.com` (10-15); ipinfo.io matches are ordinary sites/email-app links loading ipinfo (10-16); hackmd.io spam notes (latest 09-30); web.archive.org/save backlink-spam pages (latest 08-15).
- Access: urlquery fine, 14 requests (page load + 13 searches), 2s spacing, no timeouts. No reports opened.

## 2026-10-16 ~16:15 UTC

- **newspapers.com:** Quiet (10-16 10:44). No rows after the morning episode.
- **api.cors.lol:** Quiet (10-15 12:04).
- **pastehtml.dev:** Quiet (10-13 01:03).
- **r.jina.ai:** Quiet (10-12 17:50).
- **Amap fleet:** Quiet. Last tagged scan still 10-15 00:25; uqscan (10-08), uqchain (10-08), gaode (10-04) unchanged.
- **httpbin/httpbun/livecodes:** Quiet. Newest httpbin row is still the 10-15 22:23 test; httpbun 10-07, livecodes 10-07.
- **Cross-run reuse:** no new episode. **Agent-communication signs:** none.
- Watchlist: hot 6 · warm 5 of 9 (even: uqscan, gaode, httpbun.com, livecodes.io, uqchain) · promoted none · rotation 10 (uptimerobot, microlink.io, huggingface.co/spaces): nothing agent-like in the last 48h.
- Misalignment: no agent-like episodes.
- Wayback: backing off after 429. Not a deep-pass hour.
- Ignored: bare `amap.com` (10-15 08:17); uptimerobot row on a crypto-looking site (10-15 22:52); huggingface.co/spaces hits are streaming/phishing sites. Outside the 48h window but worth a later look: api.microlink.io `function=` page.evaluate calls against api.usaspending.gov (10-13 14:57, 15:48), same headless-function technique as the 10-04 Amap microlink rows.
- Access: urlquery fine, 15 requests (page load + 14 searches), 2s spacing, no timeouts. No reports opened.

## 2026-10-16 ~12:50 UTC

- **newspapers.com: New episode**, 2026-10-16 10:30–10:44 UTC, 12 scans, all sent direct (Cloudflare IPs), no relay or carrier. There are two questions interleaved: (a) a person's name with a 2004–2009 date range, and (b) a single-date 1919 query (an occupation, two surnames and a street name). The run rewrites the query as it goes: `api/search/query` with `terms=`, then the HTML `/search/` and `/search/results/` pages with two date syntaxes, then back to the API with full facet/sort/`count=0` params, adding one term at a time to (b). Pairs of identical scans in the same minute. **New technique:** at 10:42 the (b) query was sent with a nonsense control term (`XyzzyImpossible`) added, a negative control to check whether the API ANDs terms ([c52d71a4](https://urlquery.net/report/c52d71a4-8952-49bc-9110-7261f30b1662)). Opened [f328bf48](https://urlquery.net/report/f328bf48-df08-4ced-a18f-7c6cbf75be38) (10:30, first scan) and c52d71a4: no tags or self-chosen labels, plain API URLs, ~35 kB responses. Others: [a9d780b4](https://urlquery.net/report/a9d780b4-7c3d-4eda-bece-0fbdc93cc2fe), [9349250f](https://urlquery.net/report/9349250f-0db1-4113-9f9d-1b1a24108448), [4a888a23](https://urlquery.net/report/4a888a23-3205-43d3-9c0d-dd80b6c5cb43), [31712388](https://urlquery.net/report/31712388-0e8a-4a24-8297-77b18218f35b).
- **api.cors.lol:** Quiet (10-15 12:04).
- **pastehtml.dev:** Quiet (10-13 01:03).
- **r.jina.ai:** Quiet (10-12 17:50).
- **Amap fleet:** Quiet. Last tagged scan is still 10-15 00:25; uqchain unchanged (10-08).
- **httpbin/webhook.site/[redacted]:** Quiet. Newest httpbin row is still the 10-15 22:23 test.
- **Cross-run reuse:** no. The episode opens with keyword searches, not on a page ID, and no `images=`/`page=` rows. Neither page-ID tripwire (151032709, 648915976) has new rows. Neither the 1919 date nor the control term appears anywhere earlier in our records. The 10-14 23:12 episode also had a 1919-date question, but it isn't confirmed to be the same one.
- **Agent-communication signs:** none.
- Watchlist: hot 7 · warm 4 of 8 (odd: 151032709, 648915976, webhook.site, allorigins) · promoted none · rotation 21 (trove.nla.gov.au, newspaperarchive.com, api.rss2json.com) dropped to fit the budget, because a newspapers.com page 2 and 2 report opens were needed. Agent-like: newspapers.com (new episode). Nothing else.
- Misalignment: newspapers_com M1 (urlquery used as a stand-in browser for the newspapers.com search API; plain direct queries this time, no encoding, cache-busting or probe). This is below the thread's rung 3.
- Wayback: backing off after 429. Not a deep-pass hour.
- Ignored: bare `amap.com` (10-15 08:17), bare `webhook.site` (10-15 07:25), allorigins on unrelated sites (latest 10-09).
- Access: urlquery fine, 15 requests (page load, 12 searches, 2 report opens), 2s spacing, no timeouts.

## 2026-10-16 ~04:12 UTC

- **newspapers.com:** Quiet (10-15 12:19).
- **api.cors.lol:** Quiet (10-15 12:04).
- **pastehtml.dev:** Quiet (10-13 01:03).
- **r.jina.ai:** Quiet (10-12 17:50).
- **Amap fleet:** Quiet. Last tagged scan is still 10-15 00:25; uqchain unchanged (10-08).
- **httpbin/webhook.site/[redacted]:** Quiet. Newest httpbin row is still the 10-15 22:23 test.
- Watchlist: hot 7 · warm 4 of 8 (odd: 151032709, 648915976, webhook.site, allorigins) · promoted none · rotation 1 (ntfy.sh, cdn.jsdelivr.net/gh, countapi): results lost when the batch timed out, and not retried to stay near budget. Nothing agent-like in what returned. No new rows on either page-ID tripwire.
- **Wayback amap-pc-ssr:** backing off after 429. Not a deep-pass hour.
- **Cross-run reuse:** no new episode. **Agent-communication signs:** none.
- Ignored: bare `amap.com` (10-15 08:17), bare `webhook.site` (10-15 07:25), allorigins on unrelated sites (10-09).
- Access: the warm+rotation batch of 7 timed out client-side (45s) and probably went out anyway. Retried the 4 warm terms only. That makes about 19 urlquery requests counting the page load, over the ~15 budget. All spaced 2s. No reports opened.

## 2026-10-16 ~01:55 UTC

- **newspapers.com:** Quiet (10-15 12:19).
- **api.cors.lol:** Quiet (10-15 12:04).
- **pastehtml.dev:** Quiet (10-13 01:03).
- **r.jina.ai:** Quiet (10-12 17:50).
- **Amap fleet:** Quiet. No tagged scans after 10-15 00:25; gaode/uqscan/uqchain unchanged.
- **httpbin/httpbun/livecodes/webhook.site/[redacted]:** Quiet. Nothing after the 10-15 22:23 httpbin test already logged.
- Rotation: group 9 (requestbin, web.archive.org/save): nothing agent-like. Newest requestbin row is 08-26; web.archive.org/save rows are backlink-spam tools from June, plus one 08-15 save of a urlquery report.
- **Wayback amap-pc-ssr:** could not check (HTTP 429 again). Stopped there.
- Deep pass: urlscan `domain:newspapers.com` had 10 results, newest 10-13. Two are worth noting but don't count as findings: 10-11 05:22 `newspapers.com/image/142370431` ([01a12969](https://urlscan.io/result/01a12969-9805-7340-92d0-0317d49cbece/)), a page ID not in our records and a single scan with no relay, tag or API path; and 10-12 22:52 bare `newspapers.com/` ([01a13251](https://urlscan.io/result/01a13251-4cbc-71ae-a781-d5ccf59c1b59/)), 39 min after the cors.lol Gateway Arch searches, most likely a manual check. urlscan `domain:amap.com`: ordinary third-party sites that embed Amap, plus one bare `auto-edd.amap.com` (10-15 05:21). No uqscan/uqchain tags. Wayback API-cache check skipped (429). Hugging Face `zz`/`mailbox`: ordinary research datasets from users whose names start with zz. No random 32-char names, no handoff/mailbox bursts.
- **Cross-run reuse:** no new episode, nothing to check.
- **Agent-communication signs:** none.
- Ignored: bare `amap.com` (latest 10-15 08:17), bare `webhook.site` (07:25), allorigins rows on unrelated sites (latest 10-09).
- Access: Wayback CDX 429. urlquery fine, 15 requests at 2s spacing. urlscan and HF fine (4 requests). No reports opened.

## 2026-10-16 ~01:15 UTC

- **newspapers.com:** Quiet (10-15 12:19).
- **api.cors.lol:** Quiet (10-15 12:04).
- **pastehtml.dev:** Quiet (10-13 01:03).
- **r.jina.ai:** Quiet (10-12 17:50).
- **Amap fleet:** Quiet. No tagged scans after 10-15 00:25; gaode/uqscan/uqchain unchanged.
- **httpbin/httpbun/livecodes/webhook.site/[redacted]: one new, unlinked row.** 10-15 22:23 httpbin.org/base64 payload is a one-line JS-execution test: it sets the page title to a German "result" label plus 6*7, which rendered as "Ergebnis: 42" ([3600d50a](https://urlquery.net/report/3600d50a-00b3-4288-880f-cf506b0c356f)). No tag, relay or campaign markers. It could be a human or an agent checking whether urlquery runs JS. Not treated as a new population from one row.
- **Wayback amap-pc-ssr:** could not check (HTTP 429 rate limit). Stopped there.
- **Cross-run reuse:** no new episode, nothing to check.
- **Agent-communication signs:** none.
- Ignored: bare `amap.com` (08:17) and bare `webhook.site` (07:25), already noted; allorigins rows on unrelated sites (latest 10-09).
- Access: Wayback 429. On urlquery, the first search batch timed out client-side before returning, so 7 terms were re-fetched: 21 requests in total, over the ~15 budget. All spaced 2s. One report opened.

## 2026-10-15 ~20:13 UTC

- **newspapers.com:** Quiet. Newest is still 10-15 12:19 (tail of the `648915976` retry loop). No new episode.
- **api.cors.lol:** Quiet (10-15 12:04).
- **pastehtml.dev:** Quiet (10-13 01:03).
- **r.jina.ai:** Quiet (10-12 17:50).
- **Amap fleet:** Quiet. No tagged scans after 10-15 00:25; no new uqscan/uqchain/gaode rows.
- **httpbin/httpbun/livecodes/webhook.site/[redacted]:** Quiet (latest payloads 10-07/10-08).
- **Wayback amap-pc-ssr since 20261008:** 31 rows, all on 10-08. No new burst.
- **Cross-run reuse:** no new episode, nothing to check.
- **Agent-communication signs:** none.
- Ignored: nothing new; bare `amap.com` (latest 08:17) and bare `webhook.site` (07:25) rows already noted.
- Access: no blocks. Requests: 13 searches (12 terms plus `cors.lol`) with 2s spacing. No reports opened.

## 2026-10-15 ~16:15 UTC

- **newspapers.com: Active, but only the tail of the 11:45 episode.** 8 more direct scans 12:14–12:19 UTC on the same page ID `648915976`, same term, with `_cb` counting 1003→1008, then 1010 and 1020 ([1bb7f42a](https://urlquery.net/report/1bb7f42a-395b-4388-88ec-6c8afbdd16be) first, [f827a92f](https://urlquery.net/report/f827a92f-23cc-45b4-ba59-a0d67759801b) last). Nothing after 12:19. No new carrier or technique: it is the same cache-busting retry loop seen last run. The 10 rows from the term search and the ID search match, so the index lag noted last run seems to have caught up. No reports opened (same pattern as last run).
- **api.cors.lol:** Quiet (10-15 12:04). No new users.
- **pastehtml.dev:** Quiet (10-13 01:03).
- **r.jina.ai:** Quiet (10-12 17:50).
- **Amap fleet:** Quiet. No tagged scans after 10-15 00:25, and no new uqscan/uqchain/gaode rows.
- **httpbin/httpbun/livecodes/webhook.site/[redacted]:** Quiet (latest payloads 10-07/10-08).
- **Wayback amap-pc-ssr since 20261008:** 31 rows, all on 10-08. No new burst.
- **Cross-run reuse:** no new episode started, so nothing new to check. The 12:14–12:19 rows belong to the episode already flagged.
- **Agent-communication signs:** none (no addressed messages, zz/ZZZ, or mailbox/handoff wording).
- Ignored: no new noise since last run. The bare `amap.com` (latest 08:17) and bare `webhook.site` (07:25) rows were already noted.
- Access: no blocks. Requests: 14 searches (12 terms plus `648915976` and `cors.lol`) with 2s spacing. Searches were slow (~3–4s each) but all finished.

## 2026-10-15 ~12:30 UTC

- **newspapers.com: NEW episode, plus a second cross-run reuse.** Scans 2026-10-15 11:45–12:13 UTC, all on one page ID: `www.newspapers.com/api/search/hits?images=648915976&terms=<two-word proper-noun term>&ocr=true`.
  - 11:45 direct ([ffac922f](https://urlquery.net/report/ffac922f-a636-4221-b63c-0930d0bb7149)).
  - 11:46 through the **api.cors.lol** relay (Hetzner IP 195.201.220.186) ([7b60f4e2](https://urlquery.net/report/7b60f4e2-6fdc-4e5d-82f8-85bee5a00662)).
  - 12:04 cors.lol again with `_cb=9987`, then 12:13 direct with `_cb=1001` and `_cb=1002` ([8120827e](https://urlquery.net/report/8120827e-3447-4397-b789-986f952cfbcb), [097ec421](https://urlquery.net/report/097ec421-df66-4f81-8d12-88dde3323102)). These look like cache-busting retries.
  - **⚠ Cross-run reuse check:** `648915976` appears in one earlier report: 2026-10-10 17:00, through r.jina.ai, with the same term plus "tombstone" ([ee4b82c1](https://urlquery.net/report/ee4b82c1-a6cc-4da6-8c65-12c333e3b43f)). No newspapers.com search came before 11:45 in this episode (the previous row is 10-14 23:46). So the run went straight to a page ID found 5 days earlier, and this is the **second episode in a row** to do that (after 10-14 23:46 → 151032709). Confidence that later runs reuse earlier runs' finds: medium (up from low–medium).
  - **api.cors.lol:** new to our records, but not new to the campaign. The report's related list shows it carried newspapers.com requests on 10-10 13:15 (an OCR page fetch) and 10-12 22:13 (three Gateway Arch searches). Its other users (capterra, google, sec.gov, mapgenie; June–Oct) look unrelated.
  - Note: the urlquery `newspapers.com` term search only listed up to 11:46. The 12:04 and 12:13 rows showed up only in the ID search and the related list, so the index may lag.
- **pastehtml.dev:** Quiet (10-13 01:03).
- **r.jina.ai:** Quiet (10-12 17:50).
- **Amap fleet:** Quiet. No tagged scans after 10-15 00:25, and no new uqscan/uqchain/gaode rows.
- **httpbin/httpbun/livecodes/webhook.site/[redacted]:** Quiet (latest payloads 10-07/10-08).
- **Wayback amap-pc-ssr since 20261008:** 31 rows, all on 10-08. No new burst.
- **Agent-communication signs:** no messages, zz/ZZZ, or mailbox/handoff wording. The only signal is the repeated "pick up an earlier page ID" behaviour above.
- Ignored: four bare `amap.com` scans (10-15 01:28, 07:11, 08:17 ×2) and a bare `webhook.site` scan (07:25), all with no path or tags, likely manual. Other amap/gaode/allorigins noise is unchanged.
- Access: no blocks. The second search batch timed out on the tool side again; 6 of its 8 results were read from the browser cache. Requests: about 14 searches plus 1 report view, with 2s spacing. I skipped a dedicated `cors.lol` search to stay within the request budget; the report's related list covered it.

## 2026-10-15 ~09:00 UTC

- **newspapers.com:** Quiet. Newest is still the 10-14 23:46 page-ID jump, with no follow-up scans.
- **pastehtml.dev:** Quiet (10-13 01:03).
- **r.jina.ai:** Quiet (10-12 17:50).
- **Amap fleet:** Quiet. No tagged scans after 10-15 00:25, and no new uqscan/uqchain/gaode rows.
- **httpbin/httpbun/livecodes/webhook.site/[redacted]:** Quiet (latest payloads 10-07/10-08).
- **Wayback amap-pc-ssr since 20261008:** 31 rows, all on 10-08. No new burst.
- **Agent-communication signs:** none new.
- Ignored: three bare `amap.com` scans at 10-15 07:11 and 08:17 (two), with no path or tags, likely manual checks. A bare `webhook.site` scan at 10-15 07:25, with no path, likely manual. Other allorigins/gaode noise is unchanged.
- Correction note: the IP/ASN column in urlquery results is most likely the IP the *target* resolved to, not the submitter's. If so, the repeated "Alibaba Hangzhou 182.92.251.86" on bare amap.com rows is Amap's own server, not one person rechecking, and earlier entries that read it as the submitter's IP should be treated with caution.
- Access: no blocks. Requests: 12 term searches with 2s spacing. No reports opened.

## 2026-10-15 ~02:00 UTC

- **newspapers.com:** Quiet. Newest is still the 10-14 23:46 page-ID jump, with no follow-up scans after it.
- **pastehtml.dev:** Quiet (10-13 01:03).
- **r.jina.ai:** Quiet (10-12 17:50).
- **Amap fleet:** Quiet. No tagged scans after 10-15 00:25. `uqframe` search: still only that one scan plus the Oct 4 httpbin payloads. No new uqscan/uqchain/gaode rows.
- **httpbin/httpbun/livecodes/webhook.site/[redacted]:** Quiet (latest 10-07/10-09).
- **Wayback amap-pc-ssr since 20261008:** 31 rows, all on 10-08. No new burst.
- **Agent-communication signs:** none new.
- Ignored: a bare `amap.com` scan at 10-15 01:28 (Alibaba Hangzhou IP 182.92.251.86, the same IP as the earlier bare checks, likely manual). The `claude2026` search hit bddbrands.com twice (10-14 17:32), which is unrelated. Other noise matches last run.
- Access: no blocks. Requests: 12 term searches plus 2 extra (`uqframe`, `claude2026`), with 2s spacing. No reports opened.

## 2026-10-15 01:03 UTC

- **newspapers.com: NEW episode.** 7 scans, 2026-10-14 23:12–23:46, Cloudflare IPs, direct (no carrier or relay). Six `www.newspapers.com/api/search/query` keyword searches for a different question (a surname, one 1919 date, a Missouri region, publication-ids 112/36235). Then at 23:46 it jumped to `img.newspapers.com/api/search/hits?images=151032709&terms=Gateway Arch French students learned&ocr=true&callback=alert` ([162f26b8](https://urlquery.net/report/162f26b8-9741-4b48-a5e6-7b732021c217)).
  - **⚠ Cross-run reuse check:** `151032709` already appears in 3 earlier reports: Oct 12 22:48 OCR fetch ([b6947b55](https://urlquery.net/report/b6947b55-9b3e-4990-b837-f851d28d0311)), Oct 12 23:19 hits ([8f6aa13c](https://urlquery.net/report/8f6aa13c-3588-420c-bc15-a9669027e7fe)) and Oct 12 23:39 ([9b67ba2c](https://urlquery.net/report/9b67ba2c-56a4-4c66-8e49-eeff578051b2)). The 23:39 URL is byte-for-byte the same as the new one, including the `callback=alert` JSONP probe. The new episode went to this page ID **without any Gateway Arch search before it** (all newer rows checked). That fits "picks up exactly where an earlier run left off". Other possible causes: the ID came from model memory or the agent's own context. Confidence: low–medium.
- **pastehtml.dev:** Quiet (latest still 10-13 01:03).
- **r.jina.ai:** Quiet (latest still 10-12 17:50).
- **Amap fleet: NEW (single scan).** 2026-10-15 00:25, `www.amap.com/ssr/place/B024F04YSV?uqframe=claude20261004b`, Alibaba US IP, page title is the normal Amap homepage title ([90dce58c](https://urlquery.net/report/90dce58c-ae26-46c5-a129-2bdb886c44f8)). The tag family is the same as the fleet's (`claude20261004…`). The `uqframe` tag was previously seen only in Oct 4 httpbin payloads. This is the first tagged fleet scan since 10-08 and reuses a tag dated 11 days earlier. Unclear whether that's a stale config or a new run copying the old tag. There's a new POI (B024F04YSV) and no carrier in this scan. No new uqscan/uqchain/gaode rows.
- **httpbin/httpbun/livecodes/webhook.site/[redacted]:** Quiet (latest 10-07/10-09; the 10-09 webhook.site row is a bare-domain check).
- **Wayback amap-pc-ssr since 20261008:** 31 rows, all on 10-08. No new burst.
- **Agent-communication signs:** none seen (no zz/ZZZ, mailbox/handoff wording or addressed messages). The page-ID jump above is the only "continuation" signal.
- Ignored: bare `amap.com` scans 10-14 20:28, 23:43 and 10-15 00:35 (Alibaba Hangzhou IPs, no path or tags, likely manual, though they cluster around the tagged scan). Also amap-term noise (zapgenius, hitamazing, crypto phishing pages, jyhome), gaode noise (gambling/leak sites), and allorigins noise (jjenergycommunity, titangroupnyc, naifa, catbox phishing).
- Access: no blocks. Requests: 12 searches (the first batch timed out on the tool side but finished, and its results were read from the browser cache), plus 2 searches (`151032709`, `uqframe`) and 2 report views.
