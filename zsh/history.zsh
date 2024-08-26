HISTFILE=~/.histfile
HISTSIZE=100000
SAVEHIST=100000

setopt hist_ignore_dups     # Do not record an event that was just recorded again
setopt hist_ignore_all_dups # Delete an old recorded event if a new event is a duplicate
setopt hist_ignore_space    # Do not record an event starting with a space
setopt hist_save_no_dups    # Do not write a duplicate event to the history file
setopt inc_append_history   # Write to the history file immediately, not when the shell exits
setopt share_history        # Share history between terminals
setopt extendedglob         # Extended globbing. Allows using regular expressions with *
setopt nocaseglob           # Case insensitive globbing
setopt numericglobsort      # Sort filenames numerically when it makes sense

