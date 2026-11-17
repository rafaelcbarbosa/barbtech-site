# barbtech-site

Landing page for **BarbTech Project Management Consulting Services**, served at
`https://barbtech.com` from the home server (`192.168.1.200`) through the existing
Cloudflare Tunnel.

The page positions BarbTech as a senior IT delivery leadership practice available for
interim, fractional, subcontract, and project work. Copy is first person; rates and
availability are not published.

The Recipetor app stays at `https://recipetor.barbtech.com` and is not affected by this site.

## Structure

```
index.html              single-page site: hero, proof, services, models, about, contact
styles.css              design tokens, dark theme, no build step
assets/fonts/           self-hosted Inter and Fraunces variable WOFF2 (latin)
assets/photo/           portrait in 600w/1000w, WebP + JPG
assets/services/        service illustrations (WebP)
assets/                 wordmark, logo mark, favicons, 1200x630 social image
robots.txt
sitemap.xml
deploy/Caddyfile        Caddy site block for 127.0.0.1:8081
deploy/auto-pull.sh     cron pull script for the server
```

Plain static files: no dependencies, no build, no JavaScript. The mobile menu uses a
native `<details>` disclosure.

## Design

- Dark surfaces with a single teal accent (`#3DDCC4`); all tokens live in `:root`.
- Fraunces for display headings, Inter for body and UI, both self-hosted.
- Fluid type via `clamp()`, breakpoints at 640px, 960px, and 1200px.
- WCAG AA contrast for body, muted, and caption text; visible focus rings; reduced-motion
  support.
- `#6E6E78` from the original token set was lightened to `#85858F` so captions pass AA on
  every dark surface.

## Local preview

```sh
python3 -m http.server 8080
# open http://127.0.0.1:8080
```

## Deploy

The server copy lives at `/var/www/barbtech.com` and is served by Caddy on
`127.0.0.1:8081`. Cloudflare Tunnel routes `barbtech.com` and `www.barbtech.com` to it.

Push to `main`; cron pulls the change within a minute:

```cron
* * * * * /var/www/barbtech.com/deploy/auto-pull.sh >> /var/www/barbtech.com/auto-pull.log 2>&1
```

Manual deploy from a workstation:

```sh
tar -C . --exclude=.git -czf - . | ssh coxinha@192.168.1.200 'tar -C /var/www/barbtech.com -xzf -'
```

Caddy block (installed on the server):

```caddyfile
http://:8081 {
    bind 127.0.0.1
    root * /var/www/barbtech.com
    file_server
    encode gzip
}
```

The address is `http://:8081` (any host) with `bind 127.0.0.1`, not
`http://127.0.0.1:8081`. Cloudflare forwards the original `Host` header
(`barbtech.com`), and a literal `127.0.0.1` site address only matches that host,
which returns an empty response.

Reload after changing it:

```sh
sudo systemctl reload caddy
```

When an asset changes, bump its query string in `index.html` (for example
`styles.css?v=4`) so Cloudflare's four-hour edge cache does not serve the old file.

## Repository access

Pushing from the workstation uses the repo-scoped deploy key at
`~/.ssh/barbtech_deploy`, configured per-repo with `core.sshCommand`. The home
server pulls over HTTPS because the repository is public.

## Cloudflare

The tunnel is token-managed (`/etc/cloudflared/token`), so hostnames live in the
dashboard:

- `barbtech.com` → `HTTP` → `127.0.0.1:8081`
- `www.barbtech.com` → `HTTP` → `127.0.0.1:8081`
- Redirect Rule: hostname equals `www.barbtech.com` → `concat("https://barbtech.com",
  http.request.uri.path)` with a 301 and query string preserved.

Cloudflare Email Address Obfuscation rewrites the `mailto:` links, so the address is not
exposed in the served HTML.

## Content follow-ups

- The Interim/Fractional and Separation/Divestiture cards currently use cropped variants of
  the existing illustration set. Replace `assets/services/interim.webp` and
  `assets/services/divestiture.webp` when dedicated art is available.
- `assets/services/cloud.webp` has "CUSTOM SOFTWARE DEVELOPMENT" baked into the cube. Swap
  the file if that wording should not appear on the modernization card.
- Confirm the Executive MBA wording against the diploma. The credential chip currently reads
  "Executive MBA / Executive Development, University of North Carolina at Chapel Hill (2018)".
- Re-check every proof number (51%, 60%, 99.99%, 15+ yrs) and the About claims (teams of
  about 40, multi-million-dollar programs, award-winning divestiture) before publishing new
  claims.

## Email

Contact uses `rafael.barbtech@gmail.com`, so no mail hosting is required. For
`contact@barbtech.com`, enable Cloudflare Email Routing (free) to forward it.
