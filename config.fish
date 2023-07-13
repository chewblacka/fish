if status is-interactive
    # Commands to run in interactive sessions can go here
end

# History
set -gx MCFLY_HISTORY ""
set -gx MCFLY_KEY_SCHEME vim
mcfly init fish | source

### ALIASES ###

# navigation
alias ...='cd ../..'
alias .3='cd ../../..'
alias .4='cd ../../../..'

# confirm before overwriting
alias cp="cp -i"
alias mv='mv -i'
alias rm='rm -i'

alias reboot='doas reboot'⏎  
