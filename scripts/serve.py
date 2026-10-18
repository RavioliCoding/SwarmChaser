#!/usr/bin/env python3
"""Serve SwarmChaser in a browser (an alternative to the Mac app).

    python3 scripts/serve.py        # then open the printed URL

Binds to localhost only. Maps the dashboard and the sample-data folders into one
tree so the page's relative fetches resolve, mirroring how the Mac app bundles them.
Point it at your own data with SWARMCHASER_ROOT=/path/to/data (a folder holding leads/ and reference/).

Hardening: every path must stay inside its folder (no ../ or encoded escapes), the Host
header must be localhost (so a web page can't reach this server by DNS rebinding), and
folders are never listed.
"""
import http.server
import os
import pathlib
import socketserver
import urllib.parse

ROOT = pathlib.Path(__file__).resolve().parent.parent
DATA = pathlib.Path(os.environ.get("SWARMCHASER_ROOT") or ROOT / "data" / "sample").resolve()
SAMPLE = not os.environ.get("SWARMCHASER_ROOT")  # data files get X-SwarmChaser-Data: sample, so the page can label them
PORT = int(os.environ.get("PORT", "8080"))
HOSTS = {f"127.0.0.1:{PORT}", f"localhost:{PORT}", f"[::1]:{PORT}"}


class Handler(http.server.SimpleHTTPRequestHandler):
    def translate_path(self, path):
        rel = urllib.parse.unquote(path.split("?", 1)[0].split("#", 1)[0]).lstrip("/")
        if rel in ("", "dashboard", "dashboard/"):
            rel = "dashboard/index.html"
        first, _, rest = rel.partition("/")
        base, rel = (ROOT / "dashboard", rest) if first == "dashboard" else (DATA, rel)
        self.sample = SAMPLE and base == DATA
        target = (base / rel).resolve()
        return str(target) if target.is_relative_to(base) and target.is_file() else ""  # "" → 404

    def send_head(self):
        if self.headers.get("Host", "") not in HOSTS:
            self.send_error(403, "SwarmChaser only answers to localhost")
            return None
        if not self.translate_path(self.path):
            self.send_error(404)
            return None
        return super().send_head()

    def end_headers(self):
        self.send_header("Cache-Control", "no-store")
        self.send_header("X-Content-Type-Options", "nosniff")
        if getattr(self, "sample", False):
            self.send_header("X-SwarmChaser-Data", "sample")
        super().end_headers()


socketserver.TCPServer.allow_reuse_address = True
with socketserver.TCPServer(("127.0.0.1", PORT), Handler) as httpd:
    print(f"SwarmChaser → http://127.0.0.1:{PORT}/dashboard/   (Ctrl-C to stop)")
    httpd.serve_forever()
