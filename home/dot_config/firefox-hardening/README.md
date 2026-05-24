## Firefox hardening
 
Approach: vendor [Betterfox](https://github.com/yokoffing/Betterfox) `user.js`, layer personal overrides, distribute via chezmoi. A `run_onchange_after_` script locates the active profile via `profiles.ini` and writes the combined `user.js`, `chrome/*.css`, `containers.json`, and `xulstore.json` into it.
 
Profile detection precedence (Firefox 67+ aware):
 
1. `[Install...]` block's `Default=<path>` (authoritative when present)
2. `[Profile...]` block with `Default=1` (legacy)
3. Glob fallback: `*.default-release`
Platform-aware Firefox roots:
 
| Platform                  | Profile root                                              |
|---------------------------|-----------------------------------------------------------|
| macOS                     | `~/Library/Application Support/Firefox/`                  |
| Bazzite (Flatpak)         | `~/.var/app/org.mozilla.firefox/.mozilla/firefox/`        |
| Linux (native)            | `~/.mozilla/firefox/`                                     |
 
### Updating Betterfox
 
```sh
chezmoi cd
curl -L -o home/dot_config/firefox-hardening/betterfox.js \
  https://raw.githubusercontent.com/yokoffing/Betterfox/main/user.js
git diff home/dot_config/firefox-hardening/betterfox.js
git commit -am "Update Betterfox"
git push
chezmoi apply -v
```
 
Pin a release tag instead of `main` for reproducibility.
 
### Re-capturing `xulstore.json` and `containers.json`
 
These files are written by Firefox during use. After tweaking toolbar layout, container definitions, or sidebar position on one machine, copy back to the source:
 
```sh
PROFILE=~/.var/app/org.mozilla.firefox/.mozilla/firefox/<id>.default-release
chezmoi cd
cp "$PROFILE/xulstore.json"   home/dot_config/firefox-hardening/xulstore.json
cp "$PROFILE/containers.json" home/dot_config/firefox-hardening/containers.json
git commit -am "Resync Firefox UI state"
git push
```
 
On macOS, `$PROFILE` is `~/Library/Application Support/Firefox/Profiles/<id>.default-release`.
 
Close Firefox before running `chezmoi apply`. Firefox rewrites `prefs.js` on shutdown based on `user.js`; applying mid-session produces inconsistent state.
 
### What is NOT managed via chezmoi
 
Use [Firefox Sync](https://www.mozilla.org/firefox/sync/) for these:
 
- Bookmarks, history, open tabs
- Saved passwords
- Installed extension list
Per-extension data (e.g. uBlock Origin filter lists, Multi-Account Containers site assignments) generally does not sync — use each extension's own export/import.

