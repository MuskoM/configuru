function cmdExists() {
    if command -v $@ &> /dev/null; then
        return true
    else
        return false
    fi
}

# If you come from bash you might have to change your $PATH.
export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="steeef"

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
zstyle ':omz:update' mode disabled  # disable automatic updates

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
plugins=(git colored-man-pages gitignore)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='nvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch $(uname -m)"

# Set personal aliases, overriding those provided by Oh My Zsh libs,
# plugins, and themes. Aliases can be placed here, though Oh My Zsh
# users are encouraged to define aliases within a top-level file in
# the $ZSH_CUSTOM folder, with .zsh extension. Examples:
# - $ZSH_CUSTOM/aliases.zsh
# - $ZSH_CUSTOM/macos.zsh
# For a full list of active aliases, run `alias`.


# Tools configuration
# ---
# ---

# comfy 
# ---
if [[ -f $HOME/Devspace/ComfyUI/run_comfy.sh ]]; then
    alias comfy="~/Devspace/ComfyUI/run_comfy.sh"
fi

# bat
# ---
if cmdExists bat; then
    alias cat="bat"

    # Highlight --help using bat
    alias -g -- -h='-h 2>&1 | bat --language=help --style=plain'
    alias -g -- --help='-h 2>&1 | bat --language=help --style=plain'
fi

# eza
# ---
if cmdExists eza; then
    alias ls="eza --icons=auto --hyperlink --group-directories-first"
fi

# dust
# ---
if cmdExists dust; then
    alias du="dust"
fi

# duf
# ---
if cmdExists duf; then
    alias df="duf"
fi

# NVM
# ---
if cmdExists nvm; then
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
fi


# Zoxide
# ---
if cmdExists zoxide; then
    # Override cd aliases to use zoxide
    alias /="z /"
    alias ..="z .."
    alias ...="z ../.."
    alias ....="z ../../.."
    alias .....="z ../../../.."
    alias d="zoxide query -ls"

    eval "$(zoxide init zsh)"
fi

# JJ
# ---
if cmdExists jj; then
    source <(COMPLETE=zsh jj)
fi

# LaTeX simple check if texlive directory exists then it's probable that
# TexLive is installed, probably :)
if [[ -d "/usr/local/texlive/" ]]; then
export PATH="/usr/local/texlive/2025/bin/x86_64-linux:$PATH"
export MANPATH="/usr/local/texlive/2025/texmf-dist/doc/man:$MANPATH"
fi

alias restart-plasma="systemctl restart --user plasma-plasmashell"

export GPG_TTY=$(tty)
export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
gpgconf --launch gpg-agent
gpg-connect-agent updatestartuptty /bye > /dev/null
