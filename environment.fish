# theme settings
set -g theme_display_k8s_context no
set -g theme_nerd_fonts yes

# virtualfish settings
set -x VIRTUAL_ENV_DISABLE_PROMPT 1
set -g VIRTUALFISH_PLUGINS "auto_activation compat_aliases"
set -x VIRTUALFISH_HOME "$HOME/.virtualenvs"