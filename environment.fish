# theme settings
set -g theme_display_k8s_context no
set -g theme_nerd_fonts yes

# virtualfish settings
set -g VIRTUAL_ENV_DISABLE_PROMPT 1
set -g VIRTUALFISH_PLUGINS "auto_activation compat_aliases"
set -g VIRTUALFISH_HOME "$HOME/.virtualenvs"
set -x TERM "xterm-256color"

# common settings
set -g EDITOR vim
set -gx PATH $path/bin ~/.local/bin $PATH

switch (uname)
case Darwin
	source $path/os/osx/environment.fish
    if test -d $path/os/osx/bin
        set -gx PATH $path/os/osx/bin $PATH
    end
case '*'
	source $path/os/linux/environment.fish
    if test -d $path/os/linux/bin
        set -gx PATH $path/os/linux/bin $PATH
    end
end
