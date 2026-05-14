# Path to Oh My Zsh installation
export ZSH="$HOME/.oh-my-zsh"

# Theme
ZSH_THEME="philips"

# Plugins
plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
  zsh-completions
  docker
  kubectl
  python
  node
  npm
  command-not-found
  colored-man-pages
  extract
  sudo
  history
  dirhistory
)

# Completion setup
fpath+=${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions/src
autoload -U compinit && compinit

source $ZSH/oh-my-zsh.sh

# ── User Configuration ──────────────────────────────────────────

# Preferred editor
export EDITOR='vim'

# Aliases
alias ll='ls -lah --color=auto'
alias la='ls -A --color=auto'
alias l='ls -CF --color=auto'
alias gs='git status'
alias gp='git push'
alias gl='git log --oneline --graph --decorate -15'
alias gd='git diff'
alias gc='git commit'
alias gco='git checkout'
alias gca='git commit --amend'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias cls='clear'
alias py='python3'
alias pip='pip3'

# History settings
HISTSIZE=50000
SAVEHIST=50000
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS
setopt HIST_SAVE_NO_DUPS
setopt SHARE_HISTORY
setopt INC_APPEND_HISTORY

# Misc options
setopt AUTO_CD
setopt CORRECT
setopt NO_BEEP

# PATH additions
export PATH="$HOME/.local/bin:$HOME/go/bin:$PATH"

# Added by get-aspire-cli.sh
export PATH="$HOME/.aspire/bin:$PATH"

# Use Podman as the container runtime for .NET Aspire projects
export ASPIRE_CONTAINER_RUNTIME=podman
