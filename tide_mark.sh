#!/usr/bin/env fish
# A fish function to declaratively specify 
# Your Tide settings
# And randomize over any unset options

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