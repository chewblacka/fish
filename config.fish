if status is-interactive
    # Commands to run in interactive sessions can go here
    tide_mark 312222211412
end

function fish_greeting
    if not set -q DISTRO ; distro ; end
    printf "Welcome to Fish Shell. Running on "; set_color yellow; printf $DISTRO; set_color normal
    echo
end

# Mcfly
if command -q mcfly
    set -gx MCFLY_HISTORY ""
    set -gx MCFLY_KEY_SCHEME vim
    mcfly init fish | source
end
# Exclude ~/temp from z history
set -p Z_EXCLUDE "^~/temp/*"

# Direnv - suppress (un)loading messages
export DIRENV_LOG_FORMAT=



### ALIASES ###

abbr llrt ls -lrth
alias reboot='doas reboot'
abbr db distrobox
alias du="du -h"

# Nix
alias packages='sudoedit /etc/nixos/packages.nix'
alias config='sudoedit /etc/nixos/configuration.nix'
abbr ns --set-cursor "nix shell nixpkgs#%"

# Config files
alias fishconfig="$EDITOR ~/.config/fish/config.fish"
alias hxconfig="$EDITOR ~/.config/helix/config.toml"

# git
alias gcm='git switch master'

# navigation
alias ...='cd ../..'
alias .3='cd ../../..'
alias .4='cd ../../../..'

# confirm before overwriting
alias cp="cp -i"
alias mv='mv -i'
alias rm='rm -i'


#### DISTRO SPECIFIC ####

# Tumbleweed
if [ $DISTRO = "TW" ]
    # alias cat = bat
end

# NixOS
if [ $DISTRO = "NixOS" ]
end



### MY FISH FUNCTIONS ###
# distro
# which
# nix
# sudoedit
# whitespace

function distro
    # What distro are we on?
    set os_file "/etc/os-release"
    if test -f $os_file
        if grep -q "NixOS" $os_file
            set -U DISTRO "NixOS"
        else if grep -q "Tumbleweed" $os_file
            set -U DISTRO "TW"
        end
    end
end

function which
    # A which function for Fish shell and NixOS
    if not count $argv > /dev/null
        command which
        return
    end
    # First check to see if its a Fish alias
    if grep "alias $argv[1]=" "$HOME/.config/fish/config.fish" >/dev/null 2>&1 
        echo "alias defined in fish.config:"
        grep --color=never "alias $argv[1]=" "$HOME/.config/fish/config.fish" 
    # else check if its a Fish abbreviation
    else if grep "abbr $argv[1]" "$HOME/.config/fish/config.fish" >/dev/null 2>&1 
        echo "abbreviation defined in fish.config:"
        grep --color=never "abbr $argv[1]" "$HOME/.config/fish/config.fish" 
    # else check if its a Fish function
    else if functions | grep -F -x "$argv[1]" >/dev/null 2>&1
        set l $(functions $argv[1] | count)
        # check if it's longer than 10 lines
        set l $(functions $argv[1] | count)
        # echo "function length: $l"
        if test $l -gt 30 
            echo -e "\e[1mFish function\e[0m ($l lines)"
            read -n 1 key -P "Print it (y/N)? "
            if test "$key" = "y"
                functions $argv[1]
            end
        else
            echo -e "\e[1mFish function:\e[0m"
            functions $argv[1] #| less -R #head -n 10
        end
    # If neither in Fish nor system then error
    else if not command which $argv[1] >/dev/null 2>&1
        echo "Command not found!"
    end
    # If a system command print realpath
    if command which $argv[1] >/dev/null 2>&1
        echo -e "\e[1mSystem command:\e[0m"
        set -f LOC (command which $argv[1])
        set -f RP (realpath (command which $argv[1]))
        if [ RP = LOC ]
            echo "$LOC"
        else
            printf "$LOC \u21AA\n$RP\n"
        end
    end
end

function nix --argument-names cmd
    echo "Fish function nix"
    if not count $argv > /dev/null
        command nix
        return
    else if test $argv[1] = "repl"
        pushd ~/nix-repl
        clear
        command nix repl
        popd
    else
        command nix $argv[1..]
    end
end

function sudoedit --argument-names cmd
    echo "Fish sudoedit funtion"
    set -f FILE $argv[1]
    # If system has built-in sudoedit, use that
    if command -q sudoedit
        echo "System sudoedit command found. Using that."
        command sudoedit $argv[1..]
        return
    end
    # Quit if directory is writeable by user
    if test -w (dirname $FILE)
        echo "The directory is writable. No need to use sudoedit. Aborting"
        return
    end
    # If file doesn't exist, prompt to create
    if not sudo test -e $FILE
        read -P "File $FILE does not exist. Do you wish to create? (y/N): " response
        if test "$response" = "y"
            echo "You chose 'yes'. Proceeding..."
            sudo touch $FILE
        else
            return
        end  
    end
    # Remember file perms, user & group
    set -f PERMS (sudo stat -c "%a" $FILE)
    set -f OWNER (sudo stat -c %U $FILE)
    set -f GROUP (sudo stat -c %G $FILE)
    # Open a file in tmp directory
    set -f TMPFILE (mktemp /tmp/XXXX-$(basename $FILE))
    sudo cp $FILE $TMPFILE
    sudo chown $USER:(id -gn) $TMPFILE
    # Note modified time
    set -f MTIME1 (stat -c %Y $TMPFILE)
    $EDITOR $TMPFILE
    set -f MTIME2 (stat -c %Y $TMPFILE)
    # Save file only if changed
    if [ $MTIME1 != $MTIME2 ]
        echo "File $FILE modified. Saving ..."
        sudo cp $TMPFILE $FILE
        # re-apply owner and group 
        sudo chown $OWNER:$GROUP $FILE 
        # re-apply perms
        sudo chmod $PERMS $FILE
    end
    # Cleanup
    command rm $TMPFILE
end

function whitespace
    # Function to test a text file (e.g. .nix) for trailing spaces
    set -f TMPFILE $(mktemp)
    sed 's/[[:space:]]*$//' $argv[1] > $TMPFILE 
    diff $argv[1] $TMPFILE
    set rs $status
    trash $TMPFILE
    if test "$rs" -eq 1
        echo "Trailing spaces found!"
    else
        echo "No Trailing space. All is good!"
    end
end

function tide_mark
    # Function to declaratively specify Tide settings
    # set tide_config 312212232412
    set tide_config 312114231312
    # tide_config holds the intended config 
    if test $tide_config != $tide_config_
      echo "$tide_config y" | tide configure > /dev/null 2>&1 
      # _tide_config_ holds the previously set config. Invisible to user.
      # Used by TIDE to check if previous differs from intended.
      set -U tide_config_ $tide_config
      echo "Tide settings updated to: $tide_config"
    end
end
