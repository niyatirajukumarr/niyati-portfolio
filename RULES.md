# RULES.md — engineering rules for this project

Non-negotiable. Applies to every commit, every branch, every deploy.
Operating posture: **zero trust** — nothing is assumed safe because it is "internal", "temporary", or "just a portfolio".

---

## 1. Secrets management

**Never commit a secret.** Not in code, not in a comment, not in a commented-out block, not "just for a second".

- All credentials live in environment variables, injected at deploy time (Vercel/Netlify project settings), never in the repo.
- `.env` and `.env.*` are git-ignored and must never be force-added.
- Keys belong to one environment only. A key that touched a laptop is a dev key, never a prod key.
- If a secret is ever committed: **rotate it first**, then purge history. Rewriting history without rotating is theatre — assume it was scraped the moment it was pushed.
- Public-by-design values (the contact email shown on the site, public Drive links) are not secrets, but treat every "harmless" identifier as attack surface for enumeration.

## 2. Pre-commit gate (enforced, not optional)

A commit must be blocked if it fails either check. Enable the hooks once per clone:

```bash
git config core.hooksPath .githooks
```

`.githooks/pre-commit` runs, in order:

1. `scripts/scan-secrets.sh` — pattern scan of **staged content** for AWS keys, GitHub PATs, Google API keys, Slack tokens, OpenAI/Anthropic keys, private key blocks, and generic `password:`/`token=` assignments. Also blocks any staged `.env`.
2. `scripts/lint.sh` — static checks on HTML: `target="_blank"` without `rel="noopener"`, `<img>` without `alt`, inline event handlers, and any `http://` resource.

Never bypass with `--no-verify`. If the hook is wrong, fix the hook in its own commit and say why.

CI re-runs both checks on every push and PR, scanning **full history** — so a bypassed local hook still fails the build.

## 3. Code practices

- **Small commits, imperative messages.** "Fix rank numeral overlap on showreel cards", not "updates".
- **No dead code.** Delete it; git remembers.
- **No unpinned third-party scripts.** Prefer self-hosting. Anything remote is a supply-chain dependency — if it must be remote, pin the version and add SRI.
- **Accessibility is correctness**: alt text, focus states, `prefers-reduced-motion` honoured, contrast that survives a dark background.
- **Verify before claiming done.** Render it, screenshot it, click the thing. "It should work" is not a status.

## 4. Security baseline for this site

Static site, small surface — but the surface is not zero.

| Control | Where | Status |
| --- | --- | --- |
| Content-Security-Policy | `<meta>` in `index.html` | `default-src 'none'`, explicit allow-list only |
| `X-Content-Type-Options: nosniff` | `vercel.json` / `_headers` | enabled |
| `X-Frame-Options: SAMEORIGIN` | `vercel.json` / `_headers` | anti-clickjacking |
| `Referrer-Policy` | meta + headers | `strict-origin-when-cross-origin` |
| `Permissions-Policy` | headers | camera/mic/geo/payment denied |
| HSTS | headers | 1 year, includeSubDomains |
| `rel="noopener"` on all `target="_blank"` | `index.html` | lint-enforced (blocks reverse tabnabbing) |

CSP allow-list is deliberately narrow: images from self/`data:`/Drive thumbnails, frames from `drive.google.com` only, fonts embedded as `data:` so no external font origin is trusted.

## 5. Red-team pass (run after every meaningful build)

Proportionate, not performative. For a static site the real risks are:

1. **Injection** — any place user-controlled or third-party text reaches `innerHTML`. Today the `WORKS` array is author-controlled, so there is no vector; **the moment that data comes from a form, an API, or a URL parameter, switch to `textContent` or sanitise.** Re-check this on every change to the render functions.
2. **Third-party embed** — the Drive iframe runs Google's code in a frame. CSP `frame-src` pins it to `drive.google.com`. Never widen to `*`.
3. **Link hygiene** — every outbound link keeps `rel="noopener"`. Enforced by lint.
4. **Data exposure** — the Drive videos are "anyone with the link". That is a deliberate choice, not an accident: anyone who finds a link can watch and download. Do not put anything private behind an "unlisted" link and call it access control.
5. **Dependency drift** — currently zero runtime dependencies. Keep it that way; each one added is a new trust relationship to justify.

Record findings in the PR. Fix or explicitly accept with a reason — silence is not a pass.

## 6. Balance

Do not over-engineer. This is a portfolio, not a bank. The rules above are cheap to keep and expensive to retrofit — that is exactly why they are enforced now. Anything heavier (auth, WAF, pen-test vendor, threat model docs) is out of scope until this site handles user data or takes money.
