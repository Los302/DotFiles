# Lines configured by zsh-newuser-install
HISTFILE=~/.zsh_history
HISTSIZE=4000
SAVEHIST=4000
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '/home/$USER/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall

source ~/.nix-profile/etc/profile.d/hm-session-vars.sh
eval "$(direnv hook zsh)"

alias clearNeo="clear && neofetch"
alias clearScreen="clear && screenfetch"
alias cdOutHouse="cd /home/$USER/mnt/OutHouse/los"
alias cdDotfiles="cd /home/$USER/mnt/OutHouse/los/.dotfiles"
alias cdHtdocs="cd /home/$USER/Documents/htdocs"

