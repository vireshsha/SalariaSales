#!/usr/bin/env python3
"""Serve jobs_fallback.json at http://127.0.0.1:8080/jobs_fallback.json

Usage:
  python3 scripts/serve_jobs_fallback.py

Then run the app with:
  USE_LOCAL_JOBS_FALLBACK=1
"""

from http.server import HTTPServer, SimpleHTTPRequestHandler
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1] / "SalariaSales" / "Resources"
PORT = 8080


class Handler(SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=str(ROOT), **kwargs)


if __name__ == "__main__":
    print(f"Serving {ROOT} at http://127.0.0.1:{PORT}/jobs_fallback.json")
    HTTPServer(("127.0.0.1", PORT), Handler).serve_forever()
