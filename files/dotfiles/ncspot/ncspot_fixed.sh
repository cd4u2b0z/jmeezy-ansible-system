#!/bin/bash
# ncspot wrapper to fix kitty-terminfo compatibility issues

# Force compatible terminal settings
export TERM=screen-256color
export TERMINFO=/usr/share/terminfo

# Clear any existing ANSI state
printf '\033c'

# Run ncspot with forced terminal compatibility  
exec ncspot "$@"