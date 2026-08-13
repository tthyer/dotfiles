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
brew "bash-completion@2"     # @2 is the one for bash 4.2+; plain
                             # bash-completion targets Apple's 3.2 and ships
                             # almost nothing. Same profile.d path either way,
                             # so the miss is silent
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
brew "dockutil"               # macos/dock.sh drives the Dock through this

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

# No SQL GUI client: DataGrip, DBeaver, and TablePlus were all dropped in
# favour of querying through the `amp:databases` skill.

# --------------------------------------------------- GUI: personal
cask "adobe-acrobat-reader"
cask "discord"
cask "telegram"
cask "zoom"                  # ~6 months since last launch; kept deliberately
cask "tidal"
cask "stats"                 # menu-bar system monitor
# WhatsApp and Hidden Bar come from the App Store below, not from casks —
# installing both would leave two copies from different sources.

# --------------------------------------------------- Mac App Store
# Needs `mas` (above) and an App Store login. `mas install` only works for
# apps already in your purchase history, so a fresh Apple ID won't find them.
mas "WhatsApp",   id: 310633997
mas "Tailscale",  id: 1475387142   # GUI app; the CLI is the brew formula above
mas "Hidden Bar", id: 1452453066
mas "UTC Time",   id: 1538245904

# Deliberately not reinstalled — a new Mac ships with these, or offers them
# free from the App Store on demand:
#   Xcode 497799835         the command line tools are enough; install.sh
#                           already runs xcode-select --install
#   Pages 409201541, Numbers 409203825, Keynote 409183694   iWork, last used 2023
#   GarageBand 682658836, iMovie 408981434                  multi-GB, never opened
#   Menu World Time 1446377255                              superseded by UTC Time

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
# The whole JVM stack is gone. gradle, openapi-generator and openjdk went
# together, and java/java-setup.sh with them — it existed only to put that
# JDK on PATH and symlink it into /Library/Java, which cost a sudo prompt
# on every fresh machine.
# brew "gradle"              # no build.gradle anywhere in ~/github — the only
#                            # JVM projects there are Maven, and third-party
# brew "openapi-generator"   # generates the argo-workflows Python SDK, which
#                            # is that project's own tooling and never run
#                            # here. The one mention in the amperon workflow
#                            # skill is documentation about reading userAgent
#                            # strings, not a call.
# brew "openjdk"             # only ever a dependency of the two above

# --- casks ---
# cask "notunes"             # meant to stop the media key launching Apple
#                            # Music; didn't work. Never launched.
# cask "session-manager-plugin"  # AWS SSM plugin for `aws ssm start-session`;
#                            # no calls to it in shell history. Reinstate if
#                            # you need shell access to an EC2 instance.
# cask "nordvpn"             # 184 days since last launch
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
