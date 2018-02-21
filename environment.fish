set -g theme_display_k8s_context no
set -g theme_nerd_fonts yes
set -x VIRTUAL_ENV_DISABLE_PROMPT 1


switch (uname)
case Darwin
	source $path/os/osx/environment.fish
case '*'
	source $path/os/linux/environment.fish
end

# add user specified alias
if test -e ~/.environment.fish
	source ~/.environment.fish
end

