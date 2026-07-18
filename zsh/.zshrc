# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load
ZSH_THEME="powerlevel10k/powerlevel10k"

# Which plugins would you like to load?
plugins=(
  git
  node
  npm
  docker
  docker-compose
  vscode
  zsh-autosuggestions
  zsh-syntax-highlighting
  zsh-completions
  history-substring-search
  command-not-found
)

source $ZSH/oh-my-zsh.sh

# User configuration

# Example aliases
alias zshconfig="nvim ~/.zshrc"
alias zshreload="source ~/.zshrc"
alias ohmyzsh="nvim ~/.oh-my-zsh"

# Enable completions
autoload -U compinit && compinit

# History
HISTSIZE=10000
SAVEHIST=10000
setopt HIST_IGNORE_DUPS
setopt SHARE_HISTORY

# Aliases
alias ll="ls -lah"
alias gs="git status"
alias gc="git commit -m"
alias gp="git push"
alias ga="git add"
alias gaa="git add -A"
alias dc="docker compose"
alias py="python3"
alias c="clear"

# ==============================
# NVM (Node Version Manager)
# ==============================
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# ==============================
# pnpm
# ==============================
export PNPM_HOME="/home/akbar/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME/bin:"*) ;;
  *) export PATH="$PNPM_HOME/bin:$PATH" ;;
esac
# pnpm end

# ==============================
# Antigravity IDE launcher (WSL)
# ==============================
antigravity() {
    local linux_path=$(realpath "${1:-.}")

    "/mnt/c/Users/makba/AppData/Local/Programs/Antigravity IDE/bin/antigravity-ide" --folder-uri "vscode-remote://wsl+Ubuntu${linux_path}"
}

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Added by Antigravity CLI installer
export PATH="/home/akbar/.local/bin:$PATH"

# bun completions
[ -s "/home/akbar/.bun/_bun" ] && source "/home/akbar/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

[ -f ~/dotfiles/.secrets.env ] && source ~/dotfiles/.secrets.env
