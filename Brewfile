# Brewfile — public, generic packages.
#
#   brew bundle --file=Brewfile
#
# Work-only packages live in the private overlay's Brewfile.work.
# Package names aren't sensitive; the split here is about what's useful
# without an Amperon laptop, not about secrecy.
#
# Regenerate a comparison against this machine with:
#   brew bundle check --file=Brewfile --verbose

# ---------------------------------------------------------------- taps
tap "hashicorp/tap"          # terraform
tap "4ier/tap"               # notion-cli
tap "anomalyco/tap"          # opencode
tap "stablyai/orca"          # Orca ADE — NOT the plotly `orca` cask in core

# ------------------------------------------------- shell & core CLI
brew "bash"                  # bash 5; install.sh chsh's to this, not Apple's 3.2
brew "bash-completion"
brew "coreutils"
brew "findutils"
brew "gnu-sed"
brew "grep"
brew "parallel"
brew "direnv"
brew "tree"
brew "watch"
brew "wget"
brew "jq"
brew "ijq"                   # interactive jq
brew "yq"
brew "ripgrep"
brew "tmux"                  # Ghostty status bar shim only — see config/tmux/
brew "worktrunk"
brew "gh"
brew "act"                   # run GitHub Actions locally
brew "actionlint"
brew "shellcheck"
brew "dos2unix"
brew "tldr"
brew "glances"
brew "mas"                   # Mac App Store CLI — lets `brew bundle` capture MAS apps

# ------------------------------------------------- kubernetes & argo
brew "kubernetes-cli"
brew "kubectx"
brew "kubeconform"
brew "kubescape"
brew "kustomize"
brew "helm"
brew "argo"
brew "argocd"
brew "k9s"
brew "minikube"
brew "skaffold"
brew "colima"
brew "crane"

# ------------------------------------------------------------- cloud
brew "awscli"
brew "azure-cli"
brew "tailscale"
brew "hashicorp/tap/terraform"

# ------------------------------------------------ data & databases
brew "duckdb"
brew "mysql@8.4"
brew "parquet-cli"

# --------------------------------------------------- geo & weather
brew "gdal"
brew "eccodes"               # GRIB decoding; pulls the hdf5/netcdf/proj stack

# ----------------------------------------------- languages & build
brew "go"
brew "node"
brew "nvm"                   # sourced by shell/bashrc
brew "python@3.11"
brew "python@3.12"
brew "uv"
brew "pipx"
brew "pipdeptree"
brew "cmake"
brew "gradle"
brew "openjdk"               # java/java-setup.sh symlinks this into place
brew "openapi-generator"
brew "gomplate"

# -------------------------------------------------------- AI agents
brew "llm"
cask "codex"
cask "cmux"                  # status pills wired up in shell/bashrc
cask "stablyai/orca/orca"    # fully qualified: bare `orca` is plotly's, deprecated

# ----------------------------------------------------- docs & text
brew "pandoc"
brew "docutils"
brew "grip"                  # local GitHub-flavoured markdown preview
brew "graphviz"
brew "xdot"
brew "exif"
brew "exiftool"
brew "yt-dlp"

# ------------------------------------------------- network & system
brew "nmap"
brew "gnupg"

# ------------------------------------------------------------ fonts
cask "font-jetbrains-mono"

# ------------------------------------------------------- GUI: core
cask "ghostty"
cask "1password"
cask "google-chrome"
cask "brave-browser"
cask "slack"
cask "docker-desktop"        # supersedes the old `docker` cask
cask "dbeaver-community"
cask "notion-cli"
cask "session-manager-plugin"

# --------------------------------------------------- GUI: personal
cask "adobe-acrobat-reader"
cask "discord"
cask "telegram"
cask "whatsapp"
cask "zoom"
cask "anki"
cask "tidal"
cask "notunes"               # stops the media key launching Apple Music
cask "stats"                 # menu-bar system monitor
cask "hiddenbar"
cask "nordvpn"

# ---------------------------------------------------- GUI: virtual
cask "virtualbox"
# VMware Fusion has no cask — Broadcom moved it behind an account login.
# Download from support.broadcom.com by hand if you still need it.

# ==============================================================
# TRIAGE — decide before the migration, then delete this block.
#
# Install dates come from `brew info`, which records when a package was
# INSTALLED, not when it was last used. macOS doesn't update atime on
# read, so no last-used signal exists. Treat these as prompts, not proof.
# ==============================================================

# --- looks abandoned; dates are last install ---
# brew "sampler"             # 2023-09
# brew "remake"              # 2024-03
# brew "arp-scan"            # 2024-06
# brew "kubespy"             # 2024-07
# brew "gnu-time"            # 2024-11
# brew "gogcli"              # GOG downloader
# brew "himalaya"            # CLI email — still reading mail this way?
# brew "neovim"              # 2 launches ever, 0 files edited; see plan Phase 1
# brew "anomalyco/tap/opencode"   # superseded by Orca?
# brew "4ier/tap/notion-cli"      # you also use `ntn` from ~/.local/bin

# --- superseded terminals ---
# cask "warp"                # Ghostty replaced it
# cask "iterm2"              # ditto

# --- five kubernetes UIs; you probably want one or two ---
# cask "openlens"
# cask "kui"
# cask "headlamp"
#   (k9s above is the TUI and is staying)

# --- awaiting your call ---
# cask "visual-studio-code"  # settings.json touched Jun 4; still used post-Orca?
# cask "claude"              # desktop app, separate from the Claude Code CLI
# cask "datagrip"            # app data from Oct 2024
# cask "tableplus"           # third SQL client alongside DataGrip + DBeaver
# cask "sublime-text"        # dropping, confirmed
# cask "codeql"
# cask "pants"
# cask "mactex-no-gui"       # large; still writing LaTeX?
# cask "microsoft-office"    # or is this MDM-managed by Company Portal?
# cask "microsoft-teams"     # ditto
