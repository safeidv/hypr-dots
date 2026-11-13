alias sl='streamlink --twitch-low-latency '
alias leafyrino="Leafyrino"
zoxide init fish | source
source /usr/share/cachyos-fish-config/cachyos-config.fish

# overwrite greeting
# potentially disabling fastfetch
#function fish_greeting
#    # smth smth
#end

# Pi
fish_add_path "$HOME/.local/bin"

# >>> grok installer >>>
fish_add_path $HOME/.grok/bin
# <<< grok installer <<<

# Added by LM Studio CLI (lms)
set -gx PATH $PATH /home/safeidv/.lmstudio/bin
# End of LM Studio CLI section

# >>> modern cli aliases >>>
source ~/.config/fish/modern-cli.fish
# <<< modern cli aliases <<<

# >>> starship prompt >>>
if command -q starship
    starship init fish | source
end
# <<< starship prompt <<<

