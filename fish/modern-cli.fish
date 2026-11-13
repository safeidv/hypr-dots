# ╭────────────────────────────────────────────────────────────────╮
# │  Modern CLI · ярлыки и настройки                                │
# │  bat · eza · fd · ripgrep · fzf · btop · dust · procs · duf     │
# ╰────────────────────────────────────────────────────────────────╯

# ── bat: cat с подсветкой синтаксиса ─────────────────────────────
set -gx BAT_THEME Nord
set -gx BAT_STYLE "header,grid,numbers,changes"
set -gx BAT_TABS 4

alias cat 'bat --paging=never'
alias catp 'bat --style=plain --paging=never'   # без номеров/заголовка

# ── eza: информативный ls ────────────────────────────────────────
alias ls 'eza --icons=always --group-directories-first --classify=auto'
alias la 'eza -a --icons=always --group-directories-first'
alias ll 'eza -l --icons=always --group-directories-first --git --time-style=long-iso --header'
alias l  'eza -1 --icons=always --group-directories-first'
alias lt 'eza -aT --level=2 --icons=always --group-directories-first'
alias tree 'eza -aT --icons=always --group-directories-first'

# ── Поиск: ripgrep вместо grep, fd вместо find ───────────────────
alias grep 'command rg --smart-case --hidden --glob "!.git"'
alias f 'fd --hidden --exclude .git'

# ── Система: удобные замены ──────────────────────────────────────
alias ps 'procs'        # ps с цветами и деревом процессов
alias du 'dust'         # du с наглядной диаграммой
alias df 'duf'          # df с человеческим выводом
alias top 'btop'        # top с графиками (тема noctalia/Nord)

# ── fzf: нечёткий поиск с превью ─────────────────────────────────
set -gx FZF_DEFAULT_OPTS "--height=45% --layout=reverse --border=rounded --info=inline-right --prompt='❯ ' --pointer='▶' --marker='✓' --color=fg:#e5e9f0,bg:#2e3440,hl:#f9e08c,fg+:#2e3440,bg+:#8be9f7,hl+:#2e3440,info:#9fe8de,prompt:#8be9f7,pointer:#f28f9a,marker:#b9e88f,spinner:#d9a8ef,header:#a3c4f3,border:#4c566a"
set -gx FZF_DEFAULT_COMMAND 'fd --type f --hidden --exclude .git --strip-cwd-prefix'
set -gx FZF_CTRL_T_COMMAND "$FZF_DEFAULT_COMMAND"
set -gx FZF_CTRL_T_OPTS "--preview 'bat --color=always --style=numbers --line-range=:300 {}'"
set -gx FZF_ALT_C_COMMAND 'fd --type d --hidden --exclude .git --strip-cwd-prefix'
set -gx FZF_ALT_C_OPTS "--preview 'eza --tree --level=2 --icons=always --color=always {}'"

if type -q fzf
    fzf --fish | source     # Ctrl-R история, Ctrl-T файлы, Alt-C каталоги
end
