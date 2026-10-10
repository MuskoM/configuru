# configuru

Dotfiles for macOS and openSUSE Tumbleweed, managed with [chezmoi](https://www.chezmoi.io/)
and themed with **catppuccin-ube** — Catppuccin Frappé greys with a custom set of accents
(ube `#be8edc` as the main colour).

- Plain configs are **symlinked** into this repo (`mode = "symlink"`), so editing
  `~/.config/ghostty/config` edits the repo.
- Configs that use the palette are **templates**, rendered from one data file.
- Packages, the bat theme cache and systemd units are handled by scripts that only
  re-run when their input changes.

---

## New machine

**macOS** — needs [Homebrew](https://brew.sh):

```sh
brew install chezmoi
chezmoi init --apply MuskoM/configuru
```

**openSUSE Tumbleweed:**

```sh
git clone https://github.com/MuskoM/configuru ~/Configurations/configuru
~/Configurations/configuru/setup-tmbl.sh
```

`setup-tmbl.sh` only bootstraps what chezmoi needs (Packman repo, git, zsh, curl,
chezmoi, oh-my-zsh, zsh as login shell), then runs `chezmoi init --apply` on that checkout.

**Test the Linux setup from a Mac** (uses the `Dockerfile`; Podman or Docker both work):

```sh
podman machine init && podman machine start   # once
podman build -t configuru-test ~/Configurations/configuru
podman run --rm -it configuru-test
```

A clean Tumbleweed container that ends in zsh with the ube prompt = everything works.

---

## Machine that already has configs

chezmoi never silently overwrites a file it didn't write.

```sh
tar czf ~/dotfiles-before-chezmoi.tgz ~/.zshrc ~/.gitconfig ~/.config   # backup
chezmoi init MuskoM/configuru     # clone, don't apply yet
chezmoi diff                      # see every difference
chezmoi merge ~/.zshrc            # 3-way merge a file you want to combine
chezmoi apply                     # asks overwrite / skip / diff for each conflict
```

### When other tools write to your dotfiles

Installers and company setup scripts like to append to `~/.zshrc` or run
`git config --global`. In symlink mode those writes go **straight into this repo** —
`git status` will show them. That's a feature (nothing changes silently), but **never
commit them**: this repo is public. Move such lines to local, unmanaged files instead:

- `~/.zshrc.local` — sourced at the end of `.zshrc` if it exists
- `~/.gitconfig.local` — included from `.gitconfig` if it exists

The gitleaks pre-commit hook is the last line of defence against committing secrets.

---

## Day to day

| I want to… | Do |
|---|---|
| change a plain config | edit it in place (it's a symlink), commit |
| change a templated config | edit the `.tmpl` in `home/` (or `chezmoi edit <target>`), then `chezmoi apply` |
| change a colour everywhere | edit `home/.chezmoidata/catppuccin-ube.yaml`, `chezmoi apply` |
| add a package | add it to `home/.chezmoidata/packages.yaml`, `chezmoi apply` |
| get changes on another machine | `chezmoi update` (= `git pull` + `apply`) |
| see what apply would do | `chezmoi diff` |
| check the home folder matches | `chezmoi verify` (silent = OK) |
| preview a template | `chezmoi cat ~/.config/mako/config` or `chezmoi execute-template < file.tmpl` |
| work in the repo | `chezmoi cd` |

Executable scripts (`executable_*`) are copies, not symlinks — after editing one, run
`chezmoi apply`.

---

## Layout

```
.chezmoiroot              "home" — chezmoi's source starts in home/
home/
├── .chezmoi.toml.tmpl    per-machine chezmoi config (sourceDir, symlink mode, delta diffs)
├── .chezmoidata/
│   ├── catppuccin-ube.yaml   the palette — single source of truth for colours
│   └── packages.yaml         common / darwin (brew) / linux (zypper) packages
├── .chezmoiignore        Linux-only configs skipped on macOS
├── .chezmoiexternal.toml downloads: oh-my-posh binary on Linux
├── dot_zshrc, dot_gitconfig
├── dot_config/…          ~/.config
├── private_dot_local/…   ~/.local (0700) — Linux fonts
└── run_onchange_*.sh.tmpl
setup-tmbl.sh             Tumbleweed bootstrap
Dockerfile                clean-Tumbleweed test of the whole setup
Keymap_K11_MAX.json       keyboard layout (not deployed)
```

### Source name → target

| Source | Becomes |
|---|---|
| `dot_config` | `.config` |
| `private_dot_local` | `.local` with mode 0700 |
| `executable_x.sh` | `x.sh`, executable (copied, not linked) |
| `x.tmpl` | `x`, rendered through the template engine (copied, not linked) |
| `run_onchange_before_x.sh.tmpl` | script, runs **before** files are updated, only when its rendered text changes |
| `run_onchange_after_x.sh.tmpl` | same, but **after** files are updated |

A script that depends on a file it doesn't contain includes that file's hash in a
comment — `{{ include "path" | sha256sum }}` — so changing the file re-runs the script.

### Templated configs

| Config | Notes |
|---|---|
| `zellij/themes/catppuccin-ube.kdl.tmpl` | theme only; `zellij/config.kdl` stays a symlink so zellij's config editor writes into the repo |
| `waybar/ube.css.tmpl` | defines `@accent`; `frappe.css` / `style.css` stay plain |
| `niri/config.kdl.tmpl` | colours + `{{ .chezmoi.homeDir }}` paths |
| `fuzzel/fuzzel.ini.tmpl` | fuzzel wants `RRGGBBAA` → `{{ trimPrefix "#" .ube.x }}ff` |
| `mako/config.tmpl` | |
| `oh-my-posh/catppuccin-ube.yaml.tmpl` | oh-my-posh's own `{{ }}` escaped as `{{ "{{.Icon}}" }}` |
| `fastfetch/config.jsonc.tmpl` | logo colour |

Terminals (ghostty, alacritty) use stock Catppuccin Frappé.

---

## Keybindings in short

Neovim owns every key; zellij and the terminals stay out of its way.

- **zellij** — default mode is *locked* (all keys go to the pane).
  `Ctrl g` toggles normal mode, which is sticky and modelled on Neovim's `<C-w>`
  (`hjkl` focus, `HJKL` move, `s`/`v` split, `[`/`]` tabs…). `Ctrl g a` sends a literal
  Ctrl-g. `Ctrl Shift hjkl` moves between panes without unlocking. Full map at the
  top of `home/dot_config/zellij/config.kdl`.
- **Terminals** — no split/tab bindings; zellij does that.
