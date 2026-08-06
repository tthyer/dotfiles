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
tap "stablyai/orca"          # Orca ADE — NOT the plotly `orca` cask in core

# ------------------------------------------------- shell & core CLI
brew "bash"                  # bash 5; install.sh chsh's to this, not Apple's 3.2
brew "bash-completion"
brew "coreutils"
brew "findutils"
brew "gnu-sed"
brew "grep"
brew "parallel"
brew "gnu-time"
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
brew "k9s"                   # the TUI; Headlamp below is the only GUI kept
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

# ------------------------------------------------------------ email
brew "himalaya"              # account config + Keychain helper live in the overlay

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
brew "arp-scan"

# ------------------------------------------------------------ fonts
cask "font-jetbrains-mono"

# ------------------------------------------------------- GUI: core
cask "ghostty"
cask "1password"
cask "google-chrome"
cask "brave-browser"
cask "slack"
cask "docker-desktop"        # supersedes the old `docker` cask
cask "headlamp"
cask "notion-cli"
cask "session-manager-plugin"

# No SQL GUI client: DataGrip, DBeaver, and TablePlus were all dropped in
# favour of querying through the `amp:databases` skill.

# --------------------------------------------------- GUI: personal
cask "adobe-acrobat-reader"
cask "discord"
cask "telegram"
cask "whatsapp"
cask "zoom"
cask "tidal"
cask "notunes"               # stops the media key launching Apple Music
cask "stats"                 # menu-bar system monitor
cask "hiddenbar"
cask "nordvpn"

# ---------------------------------------------------- GUI: virtual
cask "utm"                   # macOS guests on Apple Silicon, for the dry run
# VMware Fusion has no cask — Broadcom moved it behind an account login.
# Download from support.broadcom.com by hand if you still need it.

# ==============================================================
# DROPPED — decided during the 2026-08 migration. Kept as a record so
# these don't get quietly reinstated. Delete once the move is done.
# ==============================================================

# --- formulae ---
# brew "sampler"             # TUI dashboards, 2023
# brew "gogcli"              # GOG downloader
# brew "kubespy"             # k8s object tracing, 2024
# brew "remake"              # GNU make debugger, 2024
# brew "anomalyco/tap/opencode"   # superseded by Orca
# brew "4ier/tap/notion-cli" # v0.4.0, provides `notion`; the cask v0.6.0 wins
# brew "neovim"              # 2 launches ever, 0 files edited

# --- casks ---
# cask "visual-studio-code"  # dropped deliberately — do not reinstate
# cask "anki"                # 3 launches, 2023
# cask "virtualbox"          # can't run macOS guests on ARM; UTM replaces it
# cask "claude"              # desktop app, Apr 2026, minimal use
# cask "bartender"           # Hidden Bar replaced it
# cask "mactex-no-gui"       # several GB of LaTeX
# cask "codeql"
# cask "pants"
# cask "microsoft-office"    # MDM-managed via Company Portal
# cask "microsoft-teams"     # ditto
# cask "warp"                # Ghostty replaced it
# cask "iterm2"              # ditto
# cask "openlens"            # Headlamp kept instead
# cask "lens"                # never launched
# cask "kui"                 # never launched
# cask "datagrip"            # querying goes through the databases skill now
# cask "dbeaver-community"
# cask "tableplus"
# cask "cursor"              # unused since Aug 2025

# --- taps with nothing installed ---
# tap "4ier/tap"             # only provided the dropped notion-cli formula
# tap "anomalyco/tap"        # only provided opencode
# tap "lox/tap"
# tap "powershell/tap"
# tap "grafana/pyroscope"
# tap "pantsbuild/tap"
# tap "manaflow-ai/cmux"     # cmux is in homebrew/cask core now
