alias ..='cd ..'
alias ccd='builtin cd'
alias mkdir='mkdir -p'
alias nano='vim'
alias cat='/usr/bin/ccat'
alias ccat='command cat'
alias meh='echo "¯\\_(ツ)_/¯"'
alias pubip='curl ipecho.net/plain; and echo'
alias htf='fish_logo; and echo "       All hail the Fish"'

# json
alias j='python -c "import sys, json; print json.dumps(json.load(sys.stdin), sort_keys=True, indent=2)" | cat'
alias pj='python -c "import sys, ast, json; print json.dumps(ast.literal_eval(sys.stdin.read().strip()))" | j'
alias cj='c | j'

# tmux
alias t='tmx'
alias res='cp $path/tmux/resurrect/last ~/.tmux/resurrect/last'

# ansible
alias play='ansible-playbook'
alias playask='ansible-playbook --ask-become-pass'
alias playsudo='ansible-playbook --extra-vars 'ansible_ssh_user=root''

# kubernetes
alias kaf='kubectl apply -f'
alias k='kubectl'

# kubernetes helpers
alias kname='kubectl config set-context (kubectl config current-context) --namespace '
alias kaf='kubectl apply -f'
alias k='kubectl'

# add os depending alias file
switch (uname)
case Darwin
	source $path/os/osx/alias.fish
case '*'
	source $path/os/linux/alias.fish
end
