# OPENSPEC:START
# OpenSpec shell completions configuration
if [ -d "/home/shane/.local/share/bash-completion/completions" ]; then
  for f in "/home/shane/.local/share/bash-completion/completions"/*; do
    [ -f "$f" ] && . "$f"
  done
fi
# OPENSPEC:END

# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support for GNU tools
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# modern file listing (eza preferred, exa fallback)
if command -v eza >/dev/null 2>&1; then
    alias ls='eza --icons --group-directories-first'
    alias ll='eza -lah --icons --group-directories-first'
    alias la='eza -a --icons --group-directories-first'
    alias l='eza -1 --icons --group-directories-first'
elif command -v exa >/dev/null 2>&1; then
    alias ls='exa --icons --group-directories-first'
    alias ll='exa -lah --icons --group-directories-first'
    alias la='exa -a --icons --group-directories-first'
    alias l='exa -1 --icons --group-directories-first'
else
    alias ls='ls --color=auto'
    alias ll='ls -alF'
    alias la='ls -A'
    alias l='ls -CF'
fi

# better cat output (bat preferred, batcat fallback)
if command -v bat >/dev/null 2>&1; then
    alias cat='bat --style=plain --paging=never'
elif command -v batcat >/dev/null 2>&1; then
    alias cat='batcat --style=plain --paging=never'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# shorthand commands
alias g='lazygit'
alias o='opencode'
alias c='codex --dangerously-bypass-approvals-and-sandbox'
alias n='nvim'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# mise version manager - add shims to PATH for editor LSPs
export PATH="$HOME/.local/share/mise/shims:$PATH"
eval "$(~/.local/bin/mise activate bash)"

# opencode
export PATH=/home/shane/.opencode/bin:$PATH

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

export PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"
export PATH="$PATH:$HOME/go/bin"

if command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init bash)"
fi

if command -v starship >/dev/null 2>&1; then
    eval "$(starship init bash)"
fi

# Load secrets (API keys, tokens) from separate untracked file
# To edit: nano ~/.secrets (or copy from ~/.secrets.template)
[ -f ~/.secrets ] && source ~/.secrets

# local machine-only secrets (not tracked in dotfiles repo)
if [ -f "$HOME/.bashrc.local" ]; then
    . "$HOME/.bashrc.local"
fi
export PATH="/home/shane/.local/share/mise/installs/dotnet/8.0.418:/home/shane/.local/share/mise/installs/node/24.13.1/bin:/home/shane/.cargo/bin:/home/shane/.local/bin:/home/shane/.local/bin:/home/shane/.local/share/mise/shims:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/usr/lib/wsl/lib:/mnt/c/Program Files/glzr.io/GlazeWM/cli:/mnt/c/Program Files/Volta/:/mnt/c/Program Files/Alacritty/:/mnt/c/Windows/system32:/mnt/c/Windows:/mnt/c/Windows/System32/Wbem:/mnt/c/Windows/System32/WindowsPowerShell/v1.0/:/mnt/c/Windows/System32/OpenSSH/:/mnt/c/Program Files/dotnet/:/mnt/c/Program Files/Neovim/bin:/mnt/c/Program Files/Microsoft SQL Server/170/Tools/Binn/:/mnt/c/Program Files/Microsoft SQL Server/Client SDK/ODBC/170/Tools/Binn/:/mnt/c/ProgramData/chocolatey/bin:/mnt/c/Program Files/Tailscale/:/mnt/c/Program Files (x86)/GitHub CLI/:/mnt/c/Program Files/nodejs/:/mnt/c/Program Files/glzr.io/Zebar/:/mnt/c/Program Files (x86)/Windows Kits/10/Windows Performance Toolkit/:/mnt/c/Users/skunz/AppData/Roaming/npm:/mnt/c/Users/skunz/AppData/Local/Volta/bin:/mnt/c/Users/skunz/AppData/Local/Microsoft/WindowsApps:/mnt/c/Users/skunz/AppData/Local/Programs/Microsoft VS Code/bin:/mnt/c/Users/skunz/AppData/Local/Programs/Git/cmd:/mnt/c/Users/skunz/.dotnet/tools:/mnt/c/Users/skunz/AppData/Roaming/npm:/mnt/c/Users/skunz/AppData/Local/PowerToys/DSCModules/:/snap/bin:/home/linuxbrew/.linuxbrew/bin:/home/shane/.bun/bin:/home/shane/.opencode/bin:/home/shane/go/bin:/home/shane/bin"

# OpenClaw Completion
source "/home/shane/.openclaw/completions/openclaw.bash"
