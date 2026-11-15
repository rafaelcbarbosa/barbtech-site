# barbtech-site

Company landing page for **BarbTech Project Management Consulting Services**, served at
`https://barbtech.com` from the home server (`192.168.1.200`) through the existing
Cloudflare Tunnel.

The Recipetor app stays at `https://recipetor.barbtech.com` and is not affected by this site.

## Structure

```
index.html              single-page landing site
styles.css              dark theme, no build step
assets/                 logo, wordmark, favicons, social image
assets/services/        six service illustrations (WebP)
robots.txt
sitemap.xml
deploy/Caddyfile        Caddy site block for 127.0.0.1:8081
deploy/auto-pull.sh     cron pull script for the server
```

Plain static files: no dependencies, no build, no JavaScript.

## Local preview

```sh
python3 -m http.server 8080
# open http://127.0.0.1:8080
```

## Deploy

The server copy lives at `/var/www/barbtech.com` and is served by Caddy on
`127.0.0.1:8081`. Cloudflare Tunnel routes `barbtech.com` and `www.barbtech.com` to it.

Manual deploy from a workstation:

```sh
tar -C . --exclude=.git -czf - . | ssh coxinha@192.168.1.200 'tar -C /var/www/barbtech.com -xzf -'
```

Caddy block (already installed on the server):

```caddyfile
http://127.0.0.1:8081 {
    root * /var/www/barbtech.com
    file_server
    encode gzip
}
```

Reload after changing it:

```sh
sudo systemctl reload caddy
```

### Auto-deploy from GitHub

Once the GitHub repository exists:

```sh
ssh coxinha@192.168.1.200
sudo mkdir -p /var/www/barbtech.com
sudo chown coxinha:coxinha /var/www/barbtech.com
git clone git@github.com:rafaelcbarbosa/barbtech-site.git /var/www/barbtech.com
```

Then add a crontab entry (mirrors Recipetor):

```cron
* * * * * /var/www/barbtech.com/deploy/auto-pull.sh >> /var/www/barbtech.com/auto-pull.log 2>&1
```

## Cloudflare Tunnel

The tunnel is token-managed (`/etc/cloudflared/token`), so hostnames are added in the
Cloudflare dashboard:

1. Zero Trust → Networks → Tunnels → the existing tunnel → **Public hostname**.
2. Add `barbtech.com` → `HTTP` → `127.0.0.1:8081`.
3. Add `www.barbtech.com` → `HTTP` → `127.0.0.1:8081`.

Before adding them, delete the existing proxied A records for `@` and `www` that point at
Google Sites. Cloudflare creates the tunnel CNAME records automatically.

Add a Redirect Rule so `www` resolves to the apex:

- If hostname equals `www.barbtech.com`
- Then redirect to `https://barbtech.com` (301, preserve path and query)

## Cut over from Google Sites

1. Remove `barbtech.com` and `www.barbtech.com` under the Google Sites custom-domain settings
   so Google releases the domain.
2. Confirm DNS now points at the tunnel for both hostnames.
3. Visit `https://barbtech.com` and `https://www.barbtech.com`.

## Email

The contact link points to `rafael.barbtech@gmail.com`, so no mail hosting is required. If you
later want `contact@barbtech.com`, enable Cloudflare Email Routing (free) to forward it.
