# NIYATI — Midnight Cut

A cinematic, dark-mode portfolio for Niyati — video editor, ex-operations lead, and 3D web builder.
Single self-contained HTML file. No build step, no dependencies, no framework.

**Live:** _(add your URL after the first deploy)_

---

## What it is

A two-screen experience:

- **Start screen** — a title-card splash, a giant Anton wordmark, a loadout of skills, a character sheet with a "Player 01" portrait, a three-level career journey with XP bars, and a ranked "Trending on Niyati" poster row.
- **Showreel** — a full-screen Netflix-style wall of all 14 edits with oversized rank numerals; tap any card to play it in a lightbox.

Both live in one file. The showreel is an in-page view (routed on `#work`), so the back button works and there is nothing to host separately.

## Stack

Nothing. Deliberately.

- Hand-written HTML, CSS, and vanilla JS
- Fonts (Anton, Archivo, JetBrains Mono, Instrument Serif) **embedded as base64** — no external font origin, works offline
- Portrait embedded as a `data:` URI
- Videos streamed from Google Drive via `/preview` embeds

Total: one `index.html`. Open it anywhere and it renders.

## Run it

```bash
# just open it
open index.html

# or serve it
python3 -m http.server 8000   # → http://localhost:8000
```

## Deploy

Any static host. The file is self-contained, so "upload" is the whole process.

- **Netlify Drop** — drag `index.html` onto <https://app.netlify.com/drop>. Live in seconds.
- **Vercel** — `vercel --prod` from this folder. `vercel.json` sets the security headers.
- **GitHub Pages** — Settings → Pages → deploy from `main` / root.
- **Cloudflare Pages** — connect the repo, no build command, output directory `/`.

`_headers` covers Netlify/Cloudflare; `vercel.json` covers Vercel. Both apply the same security headers.

## Contributing / working on it

Enable the commit hooks **once per clone** — they are not automatic:

```bash
git config core.hooksPath .githooks
```

Every commit then runs a secret scan and a static lint before it is allowed through. CI repeats both on push, scanning full history. See **[RULES.md](./RULES.md)** — it is the contract, not a suggestion.

```
.
├── index.html              the entire site
├── RULES.md                engineering + security rules (read this)
├── vercel.json             security headers for Vercel
├── _headers                security headers for Netlify / Cloudflare
├── .githooks/pre-commit    blocks secrets + lint failures
├── scripts/scan-secrets.sh staged-content secret scan
├── scripts/lint.sh         HTML hygiene checks
└── .github/workflows/ci.yml  same checks in CI
```

## Editing the showreel

Videos are defined in one array near the bottom of `index.html`:

```js
const WORKS=[
  {title:"Reel that hit 23k views", drive:"<google-drive-file-id>"},
  {title:"Bike edits", drive:"<id>", card:1},   // card:1 → film-strip poster
];
```

- `drive` is the file ID from the Drive share link. The file must be **anyone with the link → viewer**, or nobody else can play it.
- `card:1` swaps Drive's auto-thumbnail for a designed film-strip poster. Use it when a clip opens on a black fade-in or a white flash, which is what Drive grabs as frame 0.
- Order in the array is the rank order on screen.

## Known trade-offs

- **Drive-hosted video** means Google's player chrome and a dependency on those files staying shared. Self-hosting the MP4s removes both — at the cost of repo size and bandwidth.
- **Embedded fonts** make the file ~320 KB. That buys offline rendering and zero third-party font tracking. Worth it here.
- Sandboxed preview environments may block the Drive iframe; the player carries an "open in a new tab" fallback for exactly that case.

---

Built by Niyati.
