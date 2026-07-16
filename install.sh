#!/usr/bin/env bash
set -e

echo "=== Dotfiles Installer ==="
echo "This script sets up zsh, neovim, node, python, and related dev tools on WSL2 Ubuntu."
echo ""

# -------------------------------------------------------------------
# 1. System packages
# -------------------------------------------------------------------
echo "-> Installing base system packages..."
sudo apt update
sudo apt install -y \
  zsh stow git curl wget \
  zip unzip \
  socat \
  wslu \
  libatomic1 \
  ripgrep \
  python3 python3-venv python3-pip \
  build-essential ca-certificates gnupg

# -------------------------------------------------------------------
# 2. GitHub CLI (needed early: this repo is private, must login before clone)
# -------------------------------------------------------------------
if ! command -v gh &> /dev/null; then
  echo "-> Installing GitHub CLI..."
  sudo mkdir -p -m 755 /etc/apt/keyrings
  wget -nv -O- https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null
  sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
  sudo apt update
  sudo apt install gh -y
fi

echo ""
echo "This dotfiles repo is private. You must log in to GitHub CLI before cloning it."
if ! gh auth status &> /dev/null; then
  gh auth login
fi

# -------------------------------------------------------------------
# 3. NVM + Node.js LTS + npm
# -------------------------------------------------------------------
if [ ! -d "$HOME/.nvm" ]; then
  echo "-> Installing NVM..."
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
fi

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

echo "-> Installing Node.js LTS via NVM..."
nvm install --lts
nvm alias default lts/*
nvm use default

# -------------------------------------------------------------------
# 4. pnpm (standalone install, NOT via corepack)
# -------------------------------------------------------------------
if ! command -v pnpm &> /dev/null; then
  echo "-> Installing pnpm (standalone)..."
  curl -fsSL https://get.pnpm.io/install.sh | sh -
fi

# -------------------------------------------------------------------
# 5. Oh My Zsh + Powerlevel10k + plugins
# -------------------------------------------------------------------
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "-> Installing Oh My Zsh..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

if [ ! -d "$ZSH_CUSTOM/themes/powerlevel10k" ]; then
  echo "-> Installing Powerlevel10k..."
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k"
fi

declare -A plugins=(
  ["zsh-autosuggestions"]="https://github.com/zsh-users/zsh-autosuggestions"
  ["zsh-syntax-highlighting"]="https://github.com/zsh-users/zsh-syntax-highlighting.git"
  ["zsh-completions"]="https://github.com/zsh-users/zsh-completions"
)

for plugin in "${!plugins[@]}"; do
  if [ ! -d "$ZSH_CUSTOM/plugins/$plugin" ]; then
    echo "-> Installing zsh plugin: $plugin"
    git clone "${plugins[$plugin]}" "$ZSH_CUSTOM/plugins/$plugin"
  fi
done

# -------------------------------------------------------------------
# 6. Neovim >= 0.11.2 (Ubuntu apt repo is usually outdated, install from
#    the official prebuilt release tarball instead)
# -------------------------------------------------------------------
MIN_NVIM_VERSION="0.11.2"
NEED_NVIM_INSTALL=true

if command -v nvim &> /dev/null; then
  CURRENT_NVIM_VERSION=$(nvim --version | head -n1 | grep -oP '\d+\.\d+\.\d+')
  if [ "$(printf '%s\n' "$MIN_NVIM_VERSION" "$CURRENT_NVIM_VERSION" | sort -V | head -n1)" = "$MIN_NVIM_VERSION" ]; then
    NEED_NVIM_INSTALL=false
    echo "-> Neovim $CURRENT_NVIM_VERSION already satisfies >= $MIN_NVIM_VERSION, skipping."
  fi
fi

if [ "$NEED_NVIM_INSTALL" = true ]; then
  echo "-> Installing latest stable Neovim (>= $MIN_NVIM_VERSION) from official release..."
  NVIM_TARBALL_URL="https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz"
  curl -fLo /tmp/nvim-linux-x86_64.tar.gz "$NVIM_TARBALL_URL"
  sudo rm -rf /opt/nvim
  sudo mkdir -p /opt/nvim
  sudo tar -C /opt/nvim --strip-components=1 -xzf /tmp/nvim-linux-x86_64.tar.gz
  sudo ln -sf /opt/nvim/bin/nvim /usr/local/bin/nvim
  rm /tmp/nvim-linux-x86_64.tar.gz
  nvim --version | head -n1
fi

# -------------------------------------------------------------------
# 7. Nerd Font (MesloLGS NF) for terminal icons (Powerlevel10k / nvim UI)
# -------------------------------------------------------------------
FONT_DIR="$HOME/.local/share/fonts"
if [ ! -f "$FONT_DIR/MesloLGS NF Regular.ttf" ]; then
  echo "-> Installing MesloLGS Nerd Font..."
  mkdir -p "$FONT_DIR"
  cd "$FONT_DIR"
  curl -fLo "MesloLGS NF Regular.ttf" "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf"
  curl -fLo "MesloLGS NF Bold.ttf" "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf"
  curl -fLo "MesloLGS NF Italic.ttf" "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf"
  curl -fLo "MesloLGS NF Bold Italic.ttf" "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf"
  fc-cache -fv
  cd - > /dev/null
fi

# -------------------------------------------------------------------
# 8. Backup existing configs (avoid conflicts with stow)
# -------------------------------------------------------------------
echo "-> Backing up existing configs (if any)..."
timestamp=$(date +%Y%m%d_%H%M%S)
[ -f "$HOME/.zshrc" ] && [ ! -L "$HOME/.zshrc" ] && mv "$HOME/.zshrc" "$HOME/.zshrc.bak.$timestamp"
[ -f "$HOME/.p10k.zsh" ] && [ ! -L "$HOME/.p10k.zsh" ] && mv "$HOME/.p10k.zsh" "$HOME/.p10k.zsh.bak.$timestamp"
[ -d "$HOME/.config/nvim" ] && [ ! -L "$HOME/.config/nvim" ] && mv "$HOME/.config/nvim" "$HOME/.config/nvim.bak.$timestamp"
[ -f "$HOME/.gitconfig" ] && [ ! -L "$HOME/.gitconfig" ] && mv "$HOME/.gitconfig" "$HOME/.gitconfig.bak.$timestamp"

# -------------------------------------------------------------------
# 9. Clone dotfiles repo (private, requires gh auth from step 2)
# -------------------------------------------------------------------
DOTFILES_DIR="$HOME/dotfiles"
if [ ! -d "$DOTFILES_DIR" ]; then
  echo "-> Cloning dotfiles repo..."
  gh repo clone USERNAME/dotfiles "$DOTFILES_DIR"
fi

# -------------------------------------------------------------------
# 10. Stow all packages
# -------------------------------------------------------------------
cd "$DOTFILES_DIR"
mkdir -p "$HOME/.config"
echo "-> Symlinking configs with stow..."
stow zsh
stow nvim
stow git

# -------------------------------------------------------------------
# 11. Set zsh as default shell
# -------------------------------------------------------------------
if [ "$SHELL" != "$(which zsh)" ]; then
  echo "-> Setting zsh as default shell..."
  chsh -s "$(which zsh)"
fi

# -------------------------------------------------------------------
# 12. WSL interop: disable Windows PATH inheritance
# -------------------------------------------------------------------
echo "-> Configuring /etc/wsl.conf (interop.appendWindowsPath = false)..."
if [ ! -f /etc/wsl.conf ]; then
  sudo tee /etc/wsl.conf > /dev/null << 'EOF'
[interop]
appendWindowsPath = false
EOF
else
  if ! grep -q "\[interop\]" /etc/wsl.conf; then
    printf "\n[interop]\nappendWindowsPath = false\n" | sudo tee -a /etc/wsl.conf > /dev/null
  else
    sudo sed -i '/\[interop\]/,/^\[/{s/^appendWindowsPath.*/appendWindowsPath = false/}' /etc/wsl.conf
  fi
fi

echo ""
echo "=================================================================="
echo "  Automated setup finished. A few things still need manual steps"
echo "  on the Windows side (see below), and a WSL restart is required"
echo "  for /etc/wsl.conf changes to take effect."
echo "=================================================================="
echo ""
echo "[1] Restart your terminal (or run: exec zsh) to load the new shell."
echo "[2] Run 'p10k configure' if the Powerlevel10k prompt doesn't look right."
echo "[3] Set your terminal font to 'MesloLGS NF' for icons to render correctly."
echo ""
echo "[4] On Windows, install npiperelay (used for SSH agent forwarding):"
echo "      winget install -e --id jstarks.npiperelay"
echo ""
echo "[5] On Windows, create/update C:\\Users\\<your-user>\\.wslconfig with:"
cat << 'EOF'

    [wsl2]
    networkingMode=mirrored
    dnsTunneling=true
    firewall=true
    autoProxy=true
    memory=16GB
    processors=4
    swap=8GB

    [experimental]
    autoMemoryReclaim=gradual

EOF
echo "[6] Then restart WSL from PowerShell (as your Windows user):"
echo "      wsl --shutdown"
echo ""
