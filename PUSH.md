# Push this to your new GitHub repo

You create the repo (empty — no README, no .gitignore). Then, in this folder:

```bash
git remote add origin https://github.com/<your-username>/<repo-name>.git
git push -u origin main
```

That's it — history, hooks, CI and the site all go up in one push.

## Then turn on the commit gate (once per clone)

```bash
git config core.hooksPath .githooks
```

## Then publish it free on GitHub Pages

Repo → **Settings** → **Pages** → Source: **Deploy from a branch** → Branch: `main`, folder `/ (root)` → Save.

Your URL appears in a minute at:
`https://<your-username>.github.io/<repo-name>/`

Note: GitHub Pages ignores `_headers` and `vercel.json`, so the security
headers only apply on Netlify/Cloudflare/Vercel. The CSP in the page itself
still applies everywhere.
