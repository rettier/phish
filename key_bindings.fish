bind \cf '__fzf_find_file'
bind \cr '__fzf_reverse_isearch'
bind \eo '__fzf_cd'
bind \eO '__fzf_cd --hidden'
bind \cg '__fzf_open'
bind \co '__fzf_open --editor'

if bind -M insert >/dev/null 2>/dev/null
        bind -M insert \cf '__fzf_find_file'
        bind -M insert \cr '__fzf_reverse_isearch'
        bind -M insert \eo '__fzf_cd'
        bind -M insert \eO '__fzf_cd --hidden'
        bind -M insert \cg '__fzf_open'
        bind -M insert \co '__fzf_open --editor'
end

if set -q FZF_COMPLETE
    bind \t '__fzf_complete'
end

