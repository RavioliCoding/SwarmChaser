# Security & responsible use

## How SwarmChaser protects you

- **No outbound requests.** The dashboard runs under a strict Content-Security-Policy with no `connect-src` to remote hosts. It reads only local files. Opening it offline, in airplane mode, changes nothing.
- **Read-only data access.** The Mac app serves files through a private `swarm://` scheme confined to its data root. It never writes to your data.
- **Link filtering.** Clicks on external links are checked against a host policy. Research hosts open; known agent carrier/relay/paste hosts are blocked outright; anything else prompts first. The same list is enforced in the native shell (`app/main.m`) and the page.
- **Untrusted content is shown as text.** Archived agent-written material is rendered with `textContent` only — never as HTML, and never executed.

If you serve the dashboard in a browser, use the bundled `scripts/serve.py`, which **binds to `127.0.0.1` only**. Do not run a plain `python3 -m http.server` without `--bind 127.0.0.1`, which would expose the folder to your whole network.

## Responsible use

SwarmChaser is for **defensive research and transparency**. It observes already-public records passively. Please:

- Respect the terms of service of any source you observe.
- Do not use it to target, profile, or harass individuals. Keep observations about agent *behaviour*, not people.
- Do not record credentials, inbox/webhook URLs, or the names of private individuals in your own data files (the sample data and the documented workflow deliberately avoid these).
- If you discover an active operation reaching for non-public data, prefer responsible disclosure to the affected site over publication.

## Reporting a vulnerability in SwarmChaser itself

If you find a security issue in this code (for example, a way the app could be made to execute remote content or leak local files), please open a GitHub issue describing the problem, or — if it's sensitive — use GitHub's private "Report a vulnerability" advisory flow on this repository. Please don't include live exploit payloads in public issues.
